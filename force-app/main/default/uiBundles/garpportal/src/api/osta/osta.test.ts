import { beforeEach, describe, expect, it, vi } from "vitest"

const fetchMock = vi.fn()

vi.mock("@salesforce/platform-sdk", () => ({
	createDataSDK: async () => ({ fetch: fetchMock }),
}))

const { saveOsta } = await import("@/api/osta/osta")

function envelope(data: Record<string, unknown>, httpStatus = 200) {
	return new Response(
		JSON.stringify({
			status: httpStatus < 400 ? "Success" : "Error",
			statusCode: httpStatus,
			errorMessage:
				httpStatus >= 400 ? ((data.statusMessage as string) ?? null) : null,
			data,
		}),
		{ status: httpStatus, headers: { "content-type": "application/json" } },
	)
}

const valid = {
	idType: "Passport",
	idLocation: "China",
	idNumber: "G12345678",
	idExpireDate: "04/09/2030",
	ostaConsent: true,
}

beforeEach(() => {
	fetchMock.mockReset()
})

describe("saveOsta", () => {
	it("sends all five fields", async () => {
		fetchMock.mockResolvedValue(
			envelope({ statusCode: 200, statusMessage: "OSTA Information Updated" }),
		)

		await saveOsta(valid)
		expect(JSON.parse(fetchMock.mock.calls[0][1].body as string)).toEqual(valid)
	})

	/**
	 * Apex answers a single 501 "Missing required information" for any of the
	 * five. Checking here first is the only way the member is told which one.
	 */
	it("names the missing field instead of letting Apex answer 501", async () => {
		for (const key of [
			"idType",
			"idLocation",
			"idNumber",
			"idExpireDate",
		] as const) {
			await expect(saveOsta({ ...valid, [key]: "" })).rejects.toMatchObject({
				status: 400,
			})
		}
		expect(fetchMock).not.toHaveBeenCalled()
	})

	/** Apex tests `ostaConsent != true`, so false and absent are both refusals. */
	it("refuses without consent", async () => {
		await expect(
			saveOsta({ ...valid, ostaConsent: false }),
		).rejects.toMatchObject({ status: 400 })
		expect(fetchMock).not.toHaveBeenCalled()
	})

	it("surfaces the server's own refusal", async () => {
		fetchMock.mockResolvedValue(
			envelope(
				{
					statusCode: 501,
					statusMessage: "The expiry date could not be read. Use MM/DD/YYYY.",
				},
				501,
			),
		)

		await expect(saveOsta(valid)).rejects.toMatchObject({
			messages: ["The expiry date could not be read. Use MM/DD/YYYY."],
		})
	})
})
