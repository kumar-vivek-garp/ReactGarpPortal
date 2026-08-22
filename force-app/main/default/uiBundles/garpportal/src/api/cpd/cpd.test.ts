import { beforeEach, describe, expect, it, vi } from "vitest"

const fetchMock = vi.fn()

vi.mock("@salesforce/platform-sdk", () => ({
	createDataSDK: async () => ({ fetch: fetchMock }),
}))

const { AppError } = await import("@/api/client")
const { fetchCpd } = await import("@/api/cpd/cpd")

function json(body: unknown, status: number) {
	return new Response(JSON.stringify(body), {
		status,
		headers: { "content-type": "application/json" },
	})
}

const CPD_VIEW = {
	statusMessage: "Success",
	statusCode: 200,
	cpdCycle: "2026/2027",
	frmTotalNeeded: 40,
	frmCompleted: 12,
	erpTotalNeeded: null,
	erpCompleted: null,
	scrTotalNeeded: null,
	scrCompleted: null,
	raiTotalNeeded: null,
	raiCompleted: null,
	creditsRemaining: 28,
}

beforeEach(() => {
	fetchMock.mockReset()
})

describe("fetchCpd", () => {
	it("returns the view on success", async () => {
		fetchMock.mockResolvedValue(
			json(
				{ status: "Success", statusCode: 200, errorMessage: null, data: CPD_VIEW },
				200,
			),
		)
		await expect(fetchCpd()).resolves.toMatchObject({ cpdCycle: "2026/2027" })
	})

	/**
	 * The member simply has no CPE contract. Apex answers 401 but still explains
	 * itself in `data`, so this is a value, not an error — no toast, no card.
	 */
	it("resolves null for a 401 that carries a refusal payload", async () => {
		fetchMock.mockResolvedValue(
			json(
				{
					status: "Error",
					statusCode: 401,
					errorMessage: "CPD Contract not found",
					data: { statusMessage: "CPD Contract not found", statusCode: 401 },
				},
				401,
			),
		)
		await expect(fetchCpd()).resolves.toBeNull()
	})

	/**
	 * The regression this guard exists for. A signed-out member gets the same
	 * 401 with nothing in `data`; treating that as "no CPD programme" would hide
	 * an expired session behind a friendly empty state.
	 */
	it("throws for a 401 with an empty payload — an expired session, not a refusal", async () => {
		fetchMock.mockResolvedValue(
			json({ status: "Error", statusCode: 401, errorMessage: null, data: {} }, 401),
		)
		await expect(fetchCpd()).rejects.toBeInstanceOf(AppError)
	})

	it("throws for a 401 that is not a memberportal envelope at all", async () => {
		fetchMock.mockResolvedValue(
			json([{ errorCode: "INVALID_SESSION_ID", message: "Session expired" }], 401),
		)
		await expect(fetchCpd()).rejects.toBeInstanceOf(AppError)
	})

	/** 403 "No Membership Found" is a real failure and must keep toasting. */
	it("throws for 403 even though it carries a payload", async () => {
		fetchMock.mockResolvedValue(
			json(
				{
					status: "Error",
					statusCode: 403,
					errorMessage: "No Membership Found",
					data: { statusMessage: "No Membership Found", statusCode: 403 },
				},
				403,
			),
		)
		await expect(fetchCpd()).rejects.toMatchObject({
			messages: ["No Membership Found"],
		})
	})

	it("throws when the service is unreachable", async () => {
		fetchMock.mockResolvedValue(undefined)
		await expect(fetchCpd()).rejects.toBeInstanceOf(AppError)
	})
})
