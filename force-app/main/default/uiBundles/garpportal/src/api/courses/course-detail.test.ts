import { beforeEach, describe, expect, it, vi } from "vitest"

const fetchMock = vi.fn()

vi.mock("@salesforce/platform-sdk", () => ({
	createDataSDK: async () => ({ fetch: fetchMock }),
}))

const { fetchCourseDetail } = await import("@/api/courses/course-detail")

/** A refusal, as `GARP_Portal_API.respond` writes it — payload and all. */
function refusal(statusMessage: string, httpStatus: number) {
	return new Response(
		JSON.stringify({
			status: "Error",
			statusCode: httpStatus,
			errorMessage: statusMessage,
			data: { statusMessage, statusCode: httpStatus, courseDetailInfo: null },
		}),
		{ status: httpStatus, headers: { "content-type": "application/json" } },
	)
}

beforeEach(() => {
	fetchMock.mockReset()
})

describe("fetchCourseDetail", () => {
	/**
	 * All three of Apex's refusals are ordinary answers, not failures. The
	 * third is the surprising one: a 401 on a course the member genuinely
	 * holds, because the enrolment has no sitting behind it.
	 */
	it.each([
		["Invalid Course Type", 501],
		["Contract not found", 401],
		["Exam Attempt not found", 401],
	])("resolves null for %s (%i)", async (message, status) => {
		fetchMock.mockResolvedValue(refusal(message, status))
		await expect(fetchCourseDetail("FRR25")).resolves.toBeNull()
	})

	/** An empty body means the request never ran — that is a real failure. */
	it("throws for a 401 with no payload", async () => {
		fetchMock.mockResolvedValue(
			new Response(
				JSON.stringify({
					status: "Error",
					statusCode: 401,
					errorMessage: "Unauthorized",
					data: {},
				}),
				{ status: 401, headers: { "content-type": "application/json" } },
			),
		)
		await expect(fetchCourseDetail("FRR25")).rejects.toMatchObject({
			status: 401,
		})
	})

	it("sends the course type as given and returns the inner payload", async () => {
		fetchMock.mockResolvedValue(
			new Response(
				JSON.stringify({
					status: "Success",
					statusCode: 200,
					errorMessage: null,
					data: {
						statusMessage: "Program Information Returned",
						statusCode: 200,
						courseDetailInfo: { programState: "Enrolled", programType: "FFR" },
					},
				}),
				{ status: 200, headers: { "content-type": "application/json" } },
			),
		)

		const detail = await fetchCourseDetail("FFR")
		expect(fetchMock.mock.calls[0][0]).toContain("courseType=FFR")
		expect(detail).toMatchObject({ programState: "Enrolled" })
	})

	it("refuses a blank course type before it reaches the network", async () => {
		await expect(fetchCourseDetail("  ")).rejects.toMatchObject({ status: 400 })
		expect(fetchMock).not.toHaveBeenCalled()
	})
})
