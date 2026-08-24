import { beforeEach, describe, expect, it, vi } from "vitest"

const fetchMock = vi.fn()

vi.mock("@salesforce/platform-sdk", () => ({
	createDataSDK: async () => ({ fetch: fetchMock }),
}))

// The base64 read is exercised by its own tests; here the file is a stub.
vi.mock("@/lib/read-file-base64", () => ({
	readFileAsBase64: async () => "Zm9v",
}))

const { fetchErrataForm } = await import("@/api/errata/errata-form")
const { attachErrataFile, submitErrata, submitErrataWithFile } = await import(
	"@/api/errata/submit-errata"
)

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

const submission = {
	programType: "FRM",
	studyMaterial: "FRM Part I Books",
	book: "Quantitative Analysis",
	pageNumber: "142",
	errorDescription: "The variance formula is wrong.",
	correction: null,
}

beforeEach(() => {
	fetchMock.mockReset()
})

describe("fetchErrataForm", () => {
	/**
	 * Reporting needs an activated contract on an errata-capable programme.
	 * Apex says so with a 403 that still describes itself in `data` — a
	 * business answer, so the page shows an empty state rather than an error.
	 */
	it("resolves null for a 403 that carries a payload", async () => {
		fetchMock.mockResolvedValue(
			envelope(
				{ statusCode: 403, statusMessage: "Errata Access Denied", errataPicklistOption: {} },
				403,
			),
		)
		await expect(fetchErrataForm("frm")).resolves.toBeNull()
	})

	/** An empty body means the request could not run — that is a real failure. */
	it("throws for a 403 with no payload", async () => {
		fetchMock.mockResolvedValue(
			new Response(
				JSON.stringify({
					status: "Error",
					statusCode: 403,
					errorMessage: "Forbidden",
					data: {},
				}),
				{ status: 403, headers: { "content-type": "application/json" } },
			),
		)
		await expect(fetchErrataForm("frm")).rejects.toMatchObject({ status: 403 })
	})

	/** A programme whose labels match no search term returns an empty map at 200. */
	it("keeps an empty option map rather than treating it as missing", async () => {
		fetchMock.mockResolvedValue(
			envelope({ statusCode: 200, statusMessage: "Success", errataPicklistOption: null }),
		)
		await expect(fetchErrataForm("raij")).resolves.toMatchObject({
			errataPicklistOption: {},
		})
	})
})

describe("submitErrata", () => {
	it("posts the submission as the body and returns the new id", async () => {
		fetchMock.mockResolvedValue(
			envelope({ statusCode: 200, statusMessage: "Success", errataId: "a0X1" }),
		)

		const result = await submitErrata(submission)
		expect(JSON.parse(fetchMock.mock.calls[0][1].body as string)).toEqual(
			submission,
		)
		expect(result.errataId).toBe("a0X1")
	})

	/** One 501 covers all five required fields, so the message must surface. */
	it("surfaces the server's refusal", async () => {
		fetchMock.mockResolvedValue(
			envelope(
				{ statusCode: 501, statusMessage: "Required information missing", errataId: null },
				501,
			),
		)
		await expect(submitErrata(submission)).rejects.toMatchObject({
			messages: ["Required information missing"],
		})
	})
})

describe("attachErrataFile", () => {
	it("refuses a blank id or file before it reaches the network", async () => {
		await expect(attachErrataFile("  ", "a.png", "Zm9v")).rejects.toMatchObject({
			status: 400,
		})
		await expect(attachErrataFile("a0X1", "a.png", "")).rejects.toMatchObject({
			status: 400,
		})
		expect(fetchMock).not.toHaveBeenCalled()
	})

	it("sends the id, name and raw base64", async () => {
		fetchMock.mockResolvedValue(
			envelope({ statusCode: 200, statusMessage: "Success", fileId: "00P1" }),
		)
		await attachErrataFile("a0X1", "shot.png", "Zm9v")
		expect(JSON.parse(fetchMock.mock.calls[0][1].body as string)).toEqual({
			errataId: "a0X1",
			fileName: "shot.png",
			fileText: "Zm9v",
		})
	})
})

describe("submitErrataWithFile", () => {
	const file = { name: "shot.png" } as File

	it("skips the attach call entirely when there is no file", async () => {
		fetchMock.mockResolvedValue(
			envelope({ statusCode: 200, statusMessage: "Success", errataId: "a0X1" }),
		)

		await expect(submitErrataWithFile(submission)).resolves.toEqual({
			errataId: "a0X1",
			attachmentError: null,
		})
		expect(fetchMock).toHaveBeenCalledTimes(1)
	})

	it("attaches the file after the report is filed", async () => {
		fetchMock
			.mockResolvedValueOnce(
				envelope({ statusCode: 200, statusMessage: "Success", errataId: "a0X1" }),
			)
			.mockResolvedValueOnce(
				envelope({ statusCode: 200, statusMessage: "Success", fileId: "00P1" }),
			)

		await expect(submitErrataWithFile(submission, file)).resolves.toEqual({
			errataId: "a0X1",
			attachmentError: null,
		})
		const attachBody = JSON.parse(fetchMock.mock.calls[1][1].body as string)
		expect(attachBody).toMatchObject({ errataId: "a0X1", fileName: "shot.png" })
	})

	/**
	 * The trap. Once `submitErrata` returns, the report EXISTS — so a failed
	 * attachment must RESOLVE, not reject. Rejecting would report a failed
	 * submission and invite a retry that files a duplicate erratum.
	 */
	it("still succeeds when the attachment fails, carrying the reason", async () => {
		fetchMock
			.mockResolvedValueOnce(
				envelope({ statusCode: 200, statusMessage: "Success", errataId: "a0X1" }),
			)
			.mockResolvedValueOnce(
				envelope(
					{ statusCode: 501, statusMessage: "Required information missing", fileId: null },
					501,
				),
			)

		await expect(submitErrataWithFile(submission, file)).resolves.toEqual({
			errataId: "a0X1",
			attachmentError: "Required information missing",
		})
	})

	/** No id means nothing to attach to — do not call attach with a blank id. */
	it("does not attach when the server returned no report id", async () => {
		fetchMock.mockResolvedValue(
			envelope({ statusCode: 200, statusMessage: "Success", errataId: null }),
		)

		await expect(submitErrataWithFile(submission, file)).resolves.toEqual({
			errataId: null,
			attachmentError: null,
		})
		expect(fetchMock).toHaveBeenCalledTimes(1)
	})
})
