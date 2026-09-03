import { screen } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const COURSE_DETAIL_PATH = "/services/apexrest/memberportal/courseDetail"

const enrolledCourse = {
	programState: "Enrolled",
	programType: "FRR",
	programRegisteredOnDate: "2025-01-10",
	programExpireDate: null,
	examAttemptId: null,
	paymentStatus: null,
	unpaidOrderId: null,
	eBookKey: null,
	eBookAccessURL: null,
	eBookExpireDate: null,
	eLearningPlatformName: "We Know Training (WKT)",
	eLearningPlatformAccessURL: null,
	eLearningPlatformExpiresOnDate: null,
	onlineExamProviderName: null,
	onlineExamSchedulingID: null,
	onlineExamSchedulingInformationPageURL: null,
	OnlineExamSchedulingAccessURL: null,
	OnlineExamSchedulingExpiresOn: null,
	scheduledExamMode: null,
	scheduledExamDateTime: null,
	scheduledExamDateTimeZone: null,
	scheduledExamLocation: null,
	showTakeExam: null,
	examTakenDate: null,
	examResult: null,
	examRetakeAvailable: null,
	examRetakeAvailableDate: null,
	downloadCertificateURL: null,
	microCourseInfo: null,
	programInformation: null,
}

function serveCourse(courseDetailInfo: unknown) {
	server.use(
		http.get(COURSE_DETAIL_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					courseDetailInfo,
				}),
			),
		),
	)
}

const mount = () =>
	renderFileRoute(Route, {
		id: "/_appLayout/courses/$courseType/",
		path: "/courses/$courseType/",
		initialEntries: ["/courses/frr"],
	})

describe("/courses/$courseType page", () => {
	it("renders the course name as the heading with data", async () => {
		serveCourse(enrolledCourse)
		await mount()

		expect(
			await screen.findByRole("heading", {
				level: 1,
				name: /Financial Risk and Regulation/,
			}),
		).toBeInTheDocument()
	})

	it("shows the unavailable state when the course is not on the account", async () => {
		serveCourse(null)
		await mount()

		expect(
			await screen.findByText(/This course isn/),
		).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { level: 1, name: "Course" }),
		).toBeInTheDocument()
	})

	it("shows the detail skeleton while loading", async () => {
		server.use(
			http.get(COURSE_DETAIL_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope({}))
			}),
		)
		await mount()

		expect(
			screen.getByLabelText("Loading program details"),
		).toBeInTheDocument()
	})

	it("surfaces the server's message when the load fails", async () => {
		server.use(
			http.get(COURSE_DETAIL_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Course unavailable"), {
					status: 500,
				}),
			),
		)
		await mount()

		expect(
			await screen.findByText("Course unavailable"),
		).toBeInTheDocument()
	})
})
