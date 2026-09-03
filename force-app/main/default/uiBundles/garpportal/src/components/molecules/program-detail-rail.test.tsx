import { screen } from "@testing-library/react"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import {
	ProgramDetailRail,
	flattenDeadlines,
} from "@/components/molecules/program-detail-rail"
import {
	examDeadline,
	programDetail,
	programExamNotification,
} from "@/testing/factories/programs"
import { renderWithRouterProviders } from "@/testing/router"

/** Freeze "today" so the 14-day urgency window is deterministic. */
beforeEach(() => {
	vi.useFakeTimers({ toFake: ["Date"] })
	vi.setSystemTime(new Date(2027, 0, 1))
})
afterEach(() => {
	vi.useRealTimers()
})

describe("flattenDeadlines", () => {
	it("merges labels sharing a date and sorts soonest-first", () => {
		const items = flattenDeadlines([
			examDeadline({
				ADADeadline: "2027-03-01",
				deferalDeadline: "2027-02-01",
				schedulingDeadline: "2027-02-01",
			}),
		])

		expect(items.map((item) => item.date)).toEqual([
			"2027-02-01",
			"2027-03-01",
		])
		// The deferral date carries BOTH of its labels, plus scheduling's.
		expect(items[0].labels).toEqual([
			"Last Day to Defer",
			"Last Day to Complete Payment",
			"Last Day to Schedule",
		])
		expect(items[1].labels).toEqual(["ADA Application Deadline"])
	})

	it("marks a date urgent within 14 days and keeps urgency once set", () => {
		const items = flattenDeadlines([
			examDeadline({ deferalDeadline: "2027-01-10" }),
			examDeadline({ schedulingDeadline: "2027-06-30" }),
		])
		expect(items[0]).toMatchObject({ date: "2027-01-10", urgent: true })
		expect(items[1]).toMatchObject({ date: "2027-06-30", urgent: false })
	})

	it("ignores blank dates, duplicate labels and a missing list", () => {
		expect(flattenDeadlines(null)).toEqual([])
		expect(flattenDeadlines(undefined)).toEqual([])
		const items = flattenDeadlines([
			examDeadline({ ADADeadline: "  " }),
			examDeadline({ ADADeadline: "2027-05-05" }),
			examDeadline({ ADADeadline: "2027-05-05T00:00:00Z" }),
		])
		expect(items).toHaveLength(1)
		expect(items[0].labels).toEqual(["ADA Application Deadline"])
	})
})

describe("the deadlines block", () => {
	it("labels an urgent date Soon and renders nothing without deadlines", async () => {
		const { unmount } = await renderWithRouterProviders(
			<ProgramDetailRail
				detail={programDetail({
					examDeadlines: [examDeadline({ deferalDeadline: "2027-01-10" })],
				})}
			/>,
		)
		expect(
			screen.getByRole("heading", { name: "Deadlines" }),
		).toBeInTheDocument()
		expect(screen.getByText("January 10, 2027")).toBeInTheDocument()
		expect(screen.getByText("Soon")).toBeInTheDocument()
		unmount()

		await renderWithRouterProviders(
			<ProgramDetailRail detail={programDetail()} />,
		)
		expect(
			screen.queryByRole("heading", { name: "Deadlines" }),
		).not.toBeInTheDocument()
	})
})

describe("the notifications block", () => {
	it("drops rows with neither title nor details, and the block when none survive", async () => {
		const { unmount } = await renderWithRouterProviders(
			<ProgramDetailRail
				detail={programDetail({
					examNotifications: [
						programExamNotification(),
						programExamNotification({
							notificationTitle: "  ",
							notificationDetails: null,
							notificationDate: "2027-02-02",
						}),
					],
				})}
			/>,
		)
		expect(
			screen.getByRole("heading", { name: "Notifications" }),
		).toBeInTheDocument()
		expect(screen.getByText("Exam window update")).toBeInTheDocument()
		expect(screen.getByText("January 15, 2027")).toBeInTheDocument()
		unmount()

		await renderWithRouterProviders(
			<ProgramDetailRail
				detail={programDetail({
					examNotifications: [
						programExamNotification({
							notificationTitle: null,
							notificationDetails: "   ",
						}),
					],
				})}
			/>,
		)
		expect(
			screen.queryByRole("heading", { name: "Notifications" }),
		).not.toBeInTheDocument()
	})
})

describe("the three variants", () => {
	const detail = () =>
		programDetail({
			examDeadlines: [examDeadline({ deferalDeadline: "2027-01-10" })],
			examNotifications: [programExamNotification()],
		})

	it("urgent: notifications and deadlines only", async () => {
		await renderWithRouterProviders(
			<ProgramDetailRail detail={detail()} variant="urgent" />,
		)
		expect(screen.getByRole("heading", { name: "Deadlines" })).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: "Notifications" }),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("heading", { name: "Exam Resources" }),
		).not.toBeInTheDocument()
	})

	it("secondary: resources and member details behind one accordion, no urgency", async () => {
		await renderWithRouterProviders(
			<ProgramDetailRail detail={detail()} variant="secondary" />,
		)
		expect(
			screen.getByRole("button", {
				name: "Exam resources & member details",
			}),
		).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: "Exam Resources" }),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("heading", { name: "Deadlines" }),
		).not.toBeInTheDocument()
	})

	it("full: everything in one rail", async () => {
		await renderWithRouterProviders(<ProgramDetailRail detail={detail()} />)
		expect(screen.getByRole("heading", { name: "Deadlines" })).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: "Notifications" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: "Exam Resources" }),
		).toBeInTheDocument()
	})
})
