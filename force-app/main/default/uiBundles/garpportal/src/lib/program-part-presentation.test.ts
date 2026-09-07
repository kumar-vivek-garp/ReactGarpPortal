import { describe, expect, it, vi } from "vitest"

vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => undefined),
}))

import { examPartInfo, programDetail } from "@/testing/factories/programs"
import {
	canEditPart,
	examFormatLabel,
	isPartBlocked,
	partAdministration,
	partBadgeUrl,
	partFacts,
	partMessages,
} from "./program-part-presentation"

const FRM = programDetail({ programType: "FRM" })
const SCR = programDetail({ programType: "SCR" })

describe("examFormatLabel", () => {
	it("is always in person for FRM, whatever the stored format says", () => {
		expect(
			examFormatLabel(examPartInfo({ examFormat: "Remote" }), FRM),
		).toBe("In-Person")
	})

	it("says nothing for another programme until a sitting is chosen", () => {
		expect(
			examFormatLabel(
				examPartInfo({
					examFormat: "Remote",
					schedulingExamDateTimeSelected: null,
				}),
				SCR,
			),
		).toBeNull()
	})

	it("reads Remote as online proctored and anything else as in person", () => {
		const booked = { schedulingExamDateTimeSelected: "2027-05-08T09:00:00" }
		expect(
			examFormatLabel(examPartInfo({ ...booked, examFormat: "Remote" }), SCR),
		).toBe("Online Proctored")
		expect(
			examFormatLabel(
				examPartInfo({ ...booked, examFormat: "Computer-based" }),
				SCR,
			),
		).toBe("In-Person")
	})
})

describe("partAdministration", () => {
	it("heads a deferred card with the administration deferred to", () => {
		expect(
			partAdministration(
				examPartInfo({
					examPartState: "Deferred",
					examAttemptAdminName: "May 2027",
					deferredAdminName: "November 2027",
				}),
			),
		).toBe("November 2027")
	})

	it("drops the administration once the registration expired unscheduled", () => {
		expect(
			partAdministration(
				examPartInfo({ examPartState: "SchedulingClosedNeverScheduled" }),
			),
		).toBeNull()
		expect(partAdministration(examPartInfo())).toBe("May 2027")
	})
})

describe("partFacts", () => {
	it("replaces the scheduling rows with payment rows while unpaid", () => {
		const facts = partFacts(
			examPartInfo({
				examPartState: "Unpaid",
				unpaidOrderPayByDate: "2027-02-15",
			}),
			FRM,
		)
		expect(facts.map((f) => [f.label, f.value])).toEqual([
			["Payment status", "Unpaid"],
			["Complete payment by", "February 15, 2027"],
		])
	})

	it("names the scheduling open date while waiting or deferred", () => {
		expect(
			partFacts(
				examPartInfo({
					examPartState: "AwaitingSchedulingToOpen",
					schedulingAwaitingToOpenOpenDate: "2027-03-01",
				}),
				FRM,
			),
		).toMatchObject([{ label: "Scheduling opens", value: "March 1, 2027" }])
		expect(
			partFacts(
				examPartInfo({
					examPartState: "Deferred",
					deferredExamSetupOpenDate: "2027-06-01",
				}),
				FRM,
			),
		).toMatchObject([{ label: "Scheduling opens", value: "June 1, 2027" }])
	})

	it("shows no rows at all for an expired, never-scheduled registration", () => {
		expect(
			partFacts(
				examPartInfo({ examPartState: "SchedulingClosedNeverScheduled" }),
				FRM,
			),
		).toEqual([])
	})

	it("announces results as coming, with the release date, then the result itself", () => {
		expect(
			partFacts(
				examPartInfo({
					examPartState: "SchedulingClosedAwaitingResults",
					resultsAvailableDateTime: "2027-07-01T12:00:00Z",
				}),
				FRM,
			).map((f) => [f.label, f.value]),
		).toEqual([
			["Exam results", "Coming soon"],
			["Results released", "July 1, 2027"],
		])
		expect(
			partFacts(
				examPartInfo({
					examPartState: "SchedulingClosedResultsAvailable",
					result: "Pass",
				}),
				FRM,
			),
		).toMatchObject([{ label: "Exam results", value: "Pass" }])
	})

	it("gives the standard four rows while scheduling, linking the provider once booked", () => {
		const facts = partFacts(
			examPartInfo({
				examPartState: "SchedulingOpen",
				schedulingIsComplete: true,
				schedulingExamProviderName: "Pearson VUE",
				schedulingExamAccessURL: "/PearsonVue_SSO?id=a1",
				schedulingExamDateTimeSelected: "2027-05-08T09:00:00",
				schedulingExamDateTimeZoneSelected: "EST",
				schedulingExamLocationSelected: "Boston",
			}),
			FRM,
		)
		expect(facts.map((f) => f.label)).toEqual([
			"Exam format",
			"Exam provider",
			"Exam date",
			"Exam site",
		])
		expect(facts[0].value).toBe("In-Person")
		expect(facts[1]).toMatchObject({
			value: "Pearson VUE",
			href: "/PearsonVue_SSO?id=a1",
		})
		expect(facts[2].value).toMatch(/\(EST\)$/)
		expect(facts[3].value).toBe("Boston")
	})

	it("does not link the provider before the sitting is complete", () => {
		const facts = partFacts(
			examPartInfo({
				schedulingIsComplete: false,
				schedulingExamProviderName: "Pearson VUE",
				schedulingExamAccessURL: "/PearsonVue_SSO?id=a1",
			}),
			FRM,
		)
		expect(facts[1].href).toBeNull()
	})
})

describe("partMessages — results available", () => {
	const passed = (overrides = {}) =>
		examPartInfo({
			examPartState: "SchedulingClosedResultsAvailable",
			result: "Pass",
			...overrides,
		})

	it("tells a passed Part I candidate to take Part II next", () => {
		expect(
			partMessages(
				passed(),
				programDetail({
					programType: "FRM",
					currentRegistrationCanAddPartII: true,
					currentRegistrationIsOpen: true,
				}),
			),
		).toEqual([
			"Congratulations! You are almost there to getting certified!",
			"Take the FRM Exam Part II next.",
		])
	})

	it("names the reopen date when there is more to register for and the window is shut", () => {
		const detail = programDetail({
			programType: "FRM",
			currentRegistrationIsOpen: false,
			nextRegistrationOpenDate: "2027-12-01",
		})
		expect(
			partMessages(passed({ result: "Fail" }), detail),
		).toEqual([
			"We regret to inform you, your result did not meet the requirement to pass.",
			"Registration will open on December 1, 2027.",
		])
		expect(
			partMessages(
				passed(),
				programDetail({ ...detail, currentRegistrationCanAddPartII: true }),
			),
		).toContain("Registration will open on December 1, 2027.")
	})

	it("stays quiet about reopening for a pass with nothing left to register", () => {
		expect(
			partMessages(
				passed(),
				programDetail({
					programType: "SCR",
					currentRegistrationIsOpen: false,
					nextRegistrationOpenDate: "2027-12-01",
				}),
			),
		).toEqual(["Congratulations! You are almost there to getting certified!"])
	})
})

describe("partMessages — other states", () => {
	it("pairs an expired registration with when to register again", () => {
		const part = examPartInfo({
			examPartState: "SchedulingClosedNeverScheduled",
		})
		expect(
			partMessages(
				part,
				programDetail({ nextRegistrationOpenDate: "2027-12-01" }),
			),
		).toEqual([
			"Your registration has expired.",
			"Register again on December 1, 2027.",
		])
		expect(partMessages(part, FRM)[1]).toBe(
			"Register again when exam results are released.",
		)
	})

	it("says where a deferral went", () => {
		expect(
			partMessages(
				examPartInfo({
					examPartState: "Deferred",
					deferredAdminName: "November 2027",
				}),
				FRM,
			),
		).toEqual(["Your exam has been deferred to November 2027."])
	})
})

describe("gates", () => {
	it("blocks a part, and its Edit link, while an exam change is unpaid", () => {
		const blocked = examPartInfo({
			isDeferralOpen: true,
			unpaidDeferralOrderId: "006-change",
		})
		expect(isPartBlocked(blocked)).toBe(true)
		expect(canEditPart(blocked)).toBe(false)
		expect(canEditPart(examPartInfo({ isDeferralOpen: true }))).toBe(true)
		// Scheduling being open is not, on its own, a reason to edit the sitting.
		expect(
			canEditPart(examPartInfo({ isDeferralOpen: false, isSchedulingOpen: true })),
		).toBe(false)
	})

	it("badges only a pass with a result on record", () => {
		const badge = {
			badgeURL: "https://badges.example.test/img.png",
			badgePageURL: "https://badges.example.test/frm",
		}
		expect(
			partBadgeUrl(
				examPartInfo({
					examPartState: "SchedulingClosedResultsAvailable",
					result: "Pass",
					...badge,
				}),
			),
		).toBe("https://badges.example.test/frm")
		expect(
			partBadgeUrl(
				examPartInfo({
					examPartState: "SchedulingClosedResultsAvailable",
					result: "Fail",
					...badge,
				}),
			),
		).toBeNull()
		expect(
			partBadgeUrl(examPartInfo({ examPartState: "SchedulingOpen", ...badge })),
		).toBeNull()
	})
})
