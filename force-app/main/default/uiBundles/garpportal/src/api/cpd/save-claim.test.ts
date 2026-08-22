import { beforeEach, describe, expect, it, vi } from "vitest"

const fetchMock = vi.fn()

vi.mock("@salesforce/platform-sdk", () => ({
	createDataSDK: async () => ({ fetch: fetchMock }),
}))

const { AppError } = await import("@/api/client")
const { attestCpdCycle, deleteCpdClaim, saveCpdClaim } = await import(
	"@/api/cpd/save-claim"
)

/** The memberportal envelope, as `GARP_Portal_API.respond` writes it. */
function envelope(data: unknown, httpStatus = 200) {
	return new Response(
		JSON.stringify({
			status: httpStatus < 400 ? "Success" : "Error",
			statusCode: httpStatus,
			errorMessage: null,
			data,
		}),
		{ status: httpStatus, headers: { "content-type": "application/json" } },
	)
}

const validClaim = {
	activityType: "at1",
	credits: 2,
	dateOfCompletionString: "2026-03-04",
}

beforeEach(() => {
	fetchMock.mockReset()
})

describe("CPD writes", () => {
	/**
	 * The trap this guard exists for. `SaveResult` carries no `statusCode`, so
	 * the envelope reports 200 / "Success" even for a refused write and the only
	 * honest signal is `data.status`. Without the check the UI reports success
	 * and the server's reason is lost.
	 */
	it("throws the server message when a 200 response says the write failed", async () => {
		fetchMock.mockResolvedValue(
			envelope({ status: "Failed", msg: "Claim not found", claimId: null }),
		)

		await expect(saveCpdClaim(validClaim)).rejects.toMatchObject({
			messages: ["Claim not found"],
		})
	})

	it("falls back to a readable message when the server sends none", async () => {
		fetchMock.mockResolvedValue(
			envelope({ status: "Failed", msg: null, claimId: null }),
		)

		await expect(saveCpdClaim(validClaim)).rejects.toMatchObject({
			messages: ["The activity could not be saved."],
		})
	})

	it("returns the saved claim id on success", async () => {
		fetchMock.mockResolvedValue(
			envelope({ status: "Success", msg: null, claimId: "cl1" }),
		)

		await expect(saveCpdClaim(validClaim)).resolves.toMatchObject({
			status: "Success",
			claimId: "cl1",
		})
	})

	it("sends the claim as the POST body, dates as ISO", async () => {
		fetchMock.mockResolvedValue(
			envelope({ status: "Success", msg: null, claimId: "cl1" }),
		)

		await saveCpdClaim({ ...validClaim, claimId: "cl9", areaOfStudy: "A;B" })

		const [path, init] = fetchMock.mock.calls[0]
		expect(path).toBe("/services/apexrest/memberportal/cpdClaim")
		expect(init.method).toBe("POST")
		expect(JSON.parse(init.body)).toMatchObject({
			claimId: "cl9",
			activityType: "at1",
			credits: 2,
			dateOfCompletionString: "2026-03-04",
			areaOfStudy: "A;B",
		})
	})

	it("refuses to call the server without an activity type or date", async () => {
		await expect(
			saveCpdClaim({ ...validClaim, activityType: "" }),
		).rejects.toBeInstanceOf(AppError)
		await expect(
			saveCpdClaim({ ...validClaim, dateOfCompletionString: "" }),
		).rejects.toBeInstanceOf(AppError)
		expect(fetchMock).not.toHaveBeenCalled()
	})

	it("applies the same guard to delete", async () => {
		fetchMock.mockResolvedValue(
			envelope({ status: "Failed", msg: "CPD Claim not found", claimId: null }),
		)

		await expect(deleteCpdClaim("cl1")).rejects.toMatchObject({
			messages: ["CPD Claim not found"],
		})
	})

	it("applies the same guard to attest", async () => {
		fetchMock.mockResolvedValue(
			envelope({
				status: "Failed",
				msg: "Candidate Requirement not found",
				claimId: null,
			}),
		)

		await expect(attestCpdCycle("a1")).rejects.toMatchObject({
			messages: ["Candidate Requirement not found"],
		})
	})

	it("still surfaces a genuine transport failure", async () => {
		fetchMock.mockResolvedValue(envelope({}, 500))

		await expect(deleteCpdClaim("cl1")).rejects.toBeInstanceOf(AppError)
	})
})
