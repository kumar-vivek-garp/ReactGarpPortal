import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { CourseView } from "@/api/courses"
import { installMockOrg } from "../support/mock-org"
import { dashboardActionSet } from "../support/payloads"

/**
 * Course detail journeys: `/courses/frr` maps the route slug to the FRR
 * course type Apex matches on, and renders the enrolled course's hero,
 * course facts, and exam facts from one `courseDetail` payload.
 */

/** No floating alert over the page (see programs.spec.ts). */
const NO_ALERT = {
	statusMessage: null,
	statusCode: 200,
	examType: null,
	examPart: null,
	alertStatus: null,
	deadline: null,
	orderId: null,
	route: null,
} satisfies AlertBarView

/**
 * `GET courseDetail?courseType=FRR` — an enrolled FRR with live coursework
 * and a sitting behind it (examAttemptId is what makes the Exam card render).
 * Not in payloads.ts because only this module reads it.
 */
const FRR_COURSE = {
	statusMessage: null,
	statusCode: 200,
	courseDetailInfo: {
		programState: "Enrolled",
		programType: "FRR",
		programRegisteredOnDate: "2026-06-01",
		programExpireDate: "2027-06-01",
		examAttemptId: "att-frr-1",
		paymentStatus: "Paid",
		unpaidOrderId: null,
		eBookKey: "FRR-EBOOK",
		eBookAccessURL: "https://ebooks.example.com/frr",
		eBookExpireDate: "2027-06-01",
		eLearningPlatformName: "We Know Training (WKT)",
		eLearningPlatformAccessURL: "https://wkt.example.com/frr",
		eLearningPlatformExpiresOnDate: "2027-06-01",
		onlineExamProviderName: "PSI",
		onlineExamSchedulingID: null,
		onlineExamSchedulingInformationPageURL:
			"https://www.garp.org/frr-scheduling",
		OnlineExamSchedulingAccessURL: null,
		OnlineExamSchedulingExpiresOn: null,
		scheduledExamMode: null,
		scheduledExamDateTime: null,
		scheduledExamDateTimeZone: null,
		scheduledExamLocation: null,
		showTakeExam: false,
		examTakenDate: null,
		examResult: null,
		examRetakeAvailable: null,
		examRetakeAvailableDate: null,
		downloadCertificateURL: null,
		microCourseInfo: null,
		programInformation: null,
	},
} satisfies CourseView

test.describe("course detail", () => {
	test("an enrolled FRR renders its hero, course facts, and exam facts", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				...dashboardActionSet(),
				alertBar: NO_ALERT,
				courseDetail: FRR_COURSE,
			},
		})
		await page.goto("/courses/frr")

		// Hero: the fixed course's display name and its state's copy.
		await expect(
			page.getByRole("heading", {
				name: "Financial Risk and Regulation",
				level: 1,
			}),
		).toBeVisible()
		await expect(
			page.getByText("Your course materials are ready.").first(),
		).toBeVisible()
		await expect(
			page.getByRole("heading", { name: "Work through your course" }),
		).toBeVisible()

		// The e-learning platform is the primary action while enrolled.
		const cta = page.getByRole("link", {
			name: "Open We Know Training (WKT)",
		})
		await expect(cta).toBeVisible()
		await expect(cta).toHaveAttribute("href", "https://wkt.example.com/frr")
		await expect(
			page.getByRole("link", { name: "Open eBook" }),
		).toBeVisible()

		// Course facts and — because a sitting exists — the exam card.
		// `exact`: role-name matching is substring by default, and the
		// next-step card's "Work through your course" contains this.
		await expect(
			page.getByRole("heading", { name: "Your course", exact: true }),
		).toBeVisible()
		await expect(
			page.getByText("We Know Training (WKT)", { exact: true }),
		).toBeVisible()
		await expect(
			page.getByRole("heading", { name: "Exam", exact: true }),
		).toBeVisible()
		await expect(page.getByText("PSI", { exact: true })).toBeVisible()

		// The route slug was mapped to the courseType Apex matches on —
		// a lower-cased "frr" would come back 501 from the real org.
		expect(org.hits("courseDetail")).toBe(1)
		expect(org.of("courseDetail")[0].url).toContain("courseType=FRR")
	})
})
