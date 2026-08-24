import { beforeEach, describe, expect, it, vi } from "vitest"

const fetchMock = vi.fn()

vi.mock("@salesforce/platform-sdk", () => ({
	createDataSDK: async () => ({ fetch: fetchMock }),
}))

const { deleteCvAttachment, uploadCvAttachment } = await import(
	"@/api/work-experience/attachments"
)
const { deleteExperience, saveExperience } = await import(
	"@/api/work-experience/save-experience"
)
const { saveCvAddress } = await import("@/api/work-experience/save-address")
const { submitCv } = await import("@/api/work-experience/submit")

/**
 * The envelope as `GARP_Portal_API.respond` writes it.
 *
 * `errorMessage` is filled from a field named `statusMessage` on the payload
 * and from nowhere else — which is the whole reason attachments need their own
 * error path, since `AttachmentResult` calls its field `message`.
 */
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

const validInput = {
	startDateMonth: 1,
	startDateYear: 2020,
	endDateMonth: 11,
	endDateYear: 2025,
	isCurrentPosition: false,
	company: "Abrdn plc",
	title: "Analyst",
	description: "Risk work.",
	manager: null,
	jobFunction: "Risk Management",
	riskSpecialty: null,
	jobType: "Full Time",
	educationalRole: null,
}

beforeEach(() => {
	fetchMock.mockReset()
})

describe("saveExperience", () => {
	it("posts the input under an `experience` member, never at the top level", async () => {
		fetchMock.mockResolvedValue(
			envelope({ statusCode: 200, statusMessage: null, newExperienceId: "a1Q" }),
		)

		await saveExperience("FRM", validInput)

		const body = JSON.parse(fetchMock.mock.calls[0][1].body as string)
		expect(body).toEqual({ programType: "FRM", experience: validInput })
	})

	/**
	 * A refusal arrives as a real non-2xx carrying `statusMessage`, which the
	 * router lifts into the envelope. The member must see Apex's own sentence.
	 */
	it("surfaces the server's own refusal message on a 501", async () => {
		fetchMock.mockResolvedValue(
			envelope(
				{
					statusCode: 501,
					statusMessage: "Work experience dates are incomplete or invalid.",
					newExperienceId: null,
				},
				501,
			),
		)

		await expect(saveExperience("FRM", validInput)).rejects.toMatchObject({
			messages: ["Work experience dates are incomplete or invalid."],
		})
	})

	it("refuses a missing start date before it reaches the network", async () => {
		await expect(
			saveExperience("FRM", { ...validInput, startDateYear: null }),
		).rejects.toMatchObject({ status: 400 })
		expect(fetchMock).not.toHaveBeenCalled()
	})

	/** A current role ends today, decided by Apex — no end date is required. */
	it("allows a current position with no end date", async () => {
		fetchMock.mockResolvedValue(
			envelope({ statusCode: 200, statusMessage: null, newExperienceId: null }),
		)

		await expect(
			saveExperience("FRM", {
				...validInput,
				isCurrentPosition: true,
				endDateMonth: null,
				endDateYear: null,
			}),
		).resolves.toMatchObject({ statusCode: 200 })
	})

	it("refuses an end date that is missing on a past role", async () => {
		await expect(
			saveExperience("FRM", { ...validInput, endDateMonth: null }),
		).rejects.toMatchObject({ status: 400 })
		expect(fetchMock).not.toHaveBeenCalled()
	})
})

describe("deleteExperience", () => {
	it("refuses a blank id before it reaches the network", async () => {
		await expect(deleteExperience("   ")).rejects.toMatchObject({ status: 400 })
		expect(fetchMock).not.toHaveBeenCalled()
	})
})

describe("attachment errors", () => {
	/**
	 * The trap. `AttachmentResult.message` is not `statusMessage`, so the router
	 * leaves the envelope's `errorMessage` null and the only description of the
	 * failure is inside `data`. Reading the envelope instead — which is what the
	 * backend team's own client does — replaces every distinct reason with one
	 * generic sentence.
	 */
	it("reads the failure text from data.message, not the envelope", async () => {
		fetchMock.mockResolvedValue(
			new Response(
				JSON.stringify({
					status: "Error",
					statusCode: 404,
					errorMessage: null,
					data: {
						status: "error",
						message: "Work Experience not found",
						statusCode: 404,
						attachments: [],
					},
				}),
				{ status: 404, headers: { "content-type": "application/json" } },
			),
		)

		await expect(
			uploadCvAttachment("a1Q", "cv.pdf", "Zm9v"),
		).rejects.toMatchObject({
			messages: ["Work Experience not found"],
			status: 404,
		})
	})

	it("falls back to a readable sentence when the server sends no message", async () => {
		fetchMock.mockResolvedValue(
			new Response(
				JSON.stringify({
					status: "Error",
					statusCode: 500,
					errorMessage: null,
					data: { status: "error", statusCode: 500, attachments: [] },
				}),
				{ status: 500, headers: { "content-type": "application/json" } },
			),
		)

		await expect(
			deleteCvAttachment("00P"),
		).rejects.toMatchObject({ messages: ["This file could not be removed."] })
	})

	/** Size is null on the upload response; the list is where it is populated. */
	it("keeps a null size rather than inventing one", async () => {
		fetchMock.mockResolvedValue(
			envelope({
				status: "success",
				message: "File uploaded successfully",
				statusCode: 200,
				attachments: [{ id: "00P", name: "cv.pdf", url: "/x", size: null }],
			}),
		)

		const result = await uploadCvAttachment("a1Q", "cv.pdf", "Zm9v")
		expect(result.attachments[0].size).toBeNull()
	})

	it("refuses an empty file before it reaches the network", async () => {
		await expect(
			uploadCvAttachment("a1Q", "cv.pdf", ""),
		).rejects.toMatchObject({ status: 400 })
		expect(fetchMock).not.toHaveBeenCalled()
	})
})

describe("saveCvAddress", () => {
	const mailing = {
		company: "Northgate",
		street: "12 Example Road",
		city: "London",
		state: "Greater London",
		postalCode: "EC1A 1BB",
		country: "United Kingdom",
		phone: "+44 20 7946 0000",
	}

	/**
	 * Apex deserializes the RAW body into `CvAddressInput`, so the payload is
	 * the body itself. Wrapping it in another key would deserialize to a
	 * null `mailingAddress` and return 501 "Missing required parameters".
	 */
	it("posts the payload as the body, not wrapped in another key", async () => {
		fetchMock.mockResolvedValue(
			envelope({ statusCode: 200, statusMessage: null, newExperienceId: null }),
		)

		await saveCvAddress({ mailingAddress: mailing })

		const body = JSON.parse(fetchMock.mock.calls[0][1].body as string)
		expect(body).toEqual({ mailingAddress: mailing })
	})

	/**
	 * The OSTA block is written only when sent. Apex assigns all six OSTA
	 * columns inside `if (input.ostaAddress != null)`, so sending an empty one
	 * would erase a China-sitting candidate's address.
	 */
	it("omits ostaAddress entirely when there is none", async () => {
		fetchMock.mockResolvedValue(
			envelope({ statusCode: 200, statusMessage: null, newExperienceId: null }),
		)

		await saveCvAddress({ mailingAddress: mailing, ostaAddress: null })

		const body = JSON.parse(fetchMock.mock.calls[0][1].body as string)
		expect(body).not.toHaveProperty("ostaAddress")
	})

	it("surfaces the server's refusal", async () => {
		fetchMock.mockResolvedValue(
			envelope(
				{
					statusCode: 501,
					statusMessage: "Your address could not be saved.",
					newExperienceId: null,
				},
				501,
			),
		)

		await expect(
			saveCvAddress({ mailingAddress: mailing }),
		).rejects.toMatchObject({ messages: ["Your address could not be saved."] })
	})
})

describe("submitCv", () => {
	/**
	 * Apex re-checks the months against `totalTimeAllotted`, while the page's
	 * button is gated on `isValidExperienceSubmission`. The two are computed
	 * differently, so this 501 can arrive from a page that offered the button
	 * and the member has to be told why.
	 */
	it("surfaces the 501 when Apex re-checks the months and refuses", async () => {
		fetchMock.mockResolvedValue(
			envelope(
				{
					statusCode: 501,
					statusMessage:
						"Work Experience is not more than the required 24 months",
					newExperienceId: null,
				},
				501,
			),
		)

		await expect(submitCv("FRM")).rejects.toMatchObject({
			messages: ["Work Experience is not more than the required 24 months"],
			status: 501,
		})
	})

	it("sends the programme type", async () => {
		fetchMock.mockResolvedValue(
			envelope({
				statusCode: 200,
				statusMessage: "CV Submit Status Updated",
				newExperienceId: null,
			}),
		)

		await submitCv("ERP")
		expect(JSON.parse(fetchMock.mock.calls[0][1].body as string)).toEqual({
			programType: "ERP",
		})
	})
})
