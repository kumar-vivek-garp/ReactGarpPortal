import { describe, expect, it } from "vitest"

import type {
	CpdActivity,
	CpdActivityFieldInfo,
	CpdCycleInfo,
	CpdProgramView,
	CpdView,
} from "@/api/cpd/types"
import {
	activityToClaimSeed,
	buildActivityCardPresentation,
	buildClaimRowPresentation,
	cpdCardTitle,
	cpdRemainingLabel,
	cycleCertificates,
	cycleCreditRows,
	dashboardCreditRows,
	dedupeCycleOptions,
	dynamicFieldsFor,
	findActivityType,
	formatAreaOfStudy,
	formatCredits,
	splitAreaOfStudy,
	toDateInputValue,
	todayInputValue,
	hasDashboardCpdCredits,
	isCurrentCycle,
	pageCount,
	pageRange,
	resolveActiveCycle,
} from "./cpd-presentation"

function cycle(overrides: Partial<CpdCycleInfo> = {}): CpdCycleInfo {
	return {
		programId: "c1",
		cycleName: "2023/2025",
		startYear: 2023,
		endYear: 2025,
		status: "active",
		isAttested: false,
		attestationID: "cr1",
		isFRMActive: false,
		isERPActive: false,
		isSCRActive: false,
		isRAIActive: false,
		isFRMCompleted: false,
		isERPCompleted: false,
		isSCRCompleted: false,
		isRAICompleted: false,
		completedFRMCertURL: null,
		completedERPCertURL: null,
		completedSCRCertURL: null,
		completedRAICertURL: null,
		creditsSubmitted: 0,
		creditsApproved: 0,
		creditsRequired: null,
		creditsRequiredFRM: 40,
		creditsRequiredERP: 40,
		creditsRequiredSCR: 20,
		creditsRequiredRAI: 20,
		approvedClaims: [],
		pendingClaims: [],
		...overrides,
	}
}

function view(overrides: Partial<CpdView> = {}): CpdView {
	return {
		statusMessage: "Success",
		statusCode: 200,
		cpdCycle: "2023/2025",
		frmTotalNeeded: null,
		frmCompleted: null,
		erpTotalNeeded: null,
		erpCompleted: null,
		scrTotalNeeded: null,
		scrCompleted: null,
		raiTotalNeeded: null,
		raiCompleted: null,
		creditsRemaining: null,
		...overrides,
	}
}

describe("dedupeCycleOptions", () => {
	it("keeps server order and drops duplicates", () => {
		expect(
			dedupeCycleOptions([
				cycle({ cycleName: "2023/2025" }),
				cycle({ cycleName: "2021/2023" }),
				cycle({ cycleName: "2023/2025" }),
			]),
		).toEqual(["2023/2025", "2021/2023"])
	})

	it("drops unnamed cycles rather than collapsing them onto one blank option", () => {
		// Apex returns a null cycleName when the contract has no start or end date.
		expect(
			dedupeCycleOptions([
				cycle({ cycleName: null }),
				cycle({ cycleName: "2021/2023" }),
				cycle({ cycleName: null }),
			]),
		).toEqual(["2021/2023"])
	})
})

describe("resolveActiveCycle", () => {
	const program: CpdProgramView = {
		currentCycle: "2023/2025",
		cycles: [cycle({ cycleName: "2023/2025" }), cycle({ cycleName: "2021/2023" })],
	}

	it("prefers an explicit choice", () => {
		expect(resolveActiveCycle(program, "2021/2023")?.cycleName).toBe("2021/2023")
	})

	it("falls back to the server's current cycle", () => {
		expect(resolveActiveCycle(program)?.cycleName).toBe("2023/2025")
	})

	it("falls back to the default for an unknown name instead of rendering nothing", () => {
		expect(resolveActiveCycle(program, "1999/2001")?.cycleName).toBe("2023/2025")
	})

	it("returns null when the member has no cycles", () => {
		expect(resolveActiveCycle({ currentCycle: null, cycles: [] })).toBeNull()
	})
})

describe("isCurrentCycle", () => {
	it("compares cycle names, not status", () => {
		const program: CpdProgramView = {
			currentCycle: "2023/2025",
			// "activated" is a real status value — only the auto-renew variant is
			// mapped to "active" — so status must not decide this.
			cycles: [cycle({ cycleName: "2023/2025", status: "activated" })],
		}
		expect(isCurrentCycle(program.cycles[0], program)).toBe(true)
	})

	it("is false for a past cycle", () => {
		const program: CpdProgramView = {
			currentCycle: "2023/2025",
			cycles: [cycle({ cycleName: "2021/2023", status: "expired" })],
		}
		expect(isCurrentCycle(program.cycles[0], program)).toBe(false)
	})
})

describe("credit bar rows", () => {
	it("emits one row per active designation, sharing the approved total", () => {
		const rows = cycleCreditRows(
			cycle({ isFRMActive: true, isSCRActive: true, creditsApproved: 12 }),
		)
		expect(rows).toEqual([
			{ designation: "FRM", approved: 12, required: 40 },
			{ designation: "SCR", approved: 12, required: 20 },
		])
	})

	it("keeps fractional credits — Apex sends a Decimal", () => {
		const rows = cycleCreditRows(
			cycle({ isFRMActive: true, creditsApproved: 12.5 }),
		)
		expect(rows[0].approved).toBe(12.5)
	})

	it("keys the dashboard on a non-null completed value, not an active flag", () => {
		const rows = dashboardCreditRows(
			view({ frmTotalNeeded: 40, frmCompleted: 0 }),
		)
		expect(rows).toEqual([{ designation: "FRM", approved: 0, required: 40 }])
	})

	/**
	 * The whole reason the two builders exist separately. Normalising these
	 * would make the new portal disagree with the legacy portal while both are
	 * live — see the RAI notes in the two Apex services.
	 */
	it("reproduces the RAI split: 20 required on the page, 10 on the card", () => {
		expect(cycleCreditRows(cycle({ isRAIActive: true }))[0].required).toBe(20)
		expect(
			dashboardCreditRows(view({ raiTotalNeeded: 10, raiCompleted: 4 }))[0]
				.required,
		).toBe(10)
	})
})

describe("hasDashboardCpdCredits", () => {
	it("is false for a member with no CPD program", () => {
		expect(hasDashboardCpdCredits(null)).toBe(false)
	})

	/**
	 * The service sets 501 for "no completed certification" and then overwrites
	 * it with 200 two lines later, so this arrives as a success with every
	 * number null. The legacy rendered a blank chart for it.
	 */
	it("is false for a 200 response with every designation null", () => {
		expect(hasDashboardCpdCredits(view())).toBe(false)
	})

	it("is true once any designation reports credits", () => {
		expect(
			hasDashboardCpdCredits(view({ scrTotalNeeded: 20, scrCompleted: 5 })),
		).toBe(true)
	})
})

describe("cpdCardTitle", () => {
	it("uses the cycle when there is one", () => {
		expect(cpdCardTitle(view())).toBe("2023/2025 CPD Credits")
	})

	it("degrades rather than rendering a leading space", () => {
		expect(cpdCardTitle(view({ cpdCycle: null }))).toBe("CPD Credits")
	})
})

describe("cpdRemainingLabel", () => {
	it("reports what is still owed", () => {
		expect(cpdRemainingLabel(view({ creditsRemaining: 20 }))).toBe(
			"20 credits remaining this cycle",
		)
		expect(cpdRemainingLabel(view({ creditsRemaining: 1 }))).toBe(
			"1 credit remaining this cycle",
		)
	})

	it("says nothing once the requirement is met", () => {
		expect(cpdRemainingLabel(view({ creditsRemaining: 0 }))).toBeNull()
		expect(cpdRemainingLabel(view({ creditsRemaining: -5 }))).toBeNull()
		expect(cpdRemainingLabel(view())).toBeNull()
		expect(cpdRemainingLabel(null)).toBeNull()
	})
})

describe("cycleCertificates", () => {
	it("only lists designations that are both active and complete", () => {
		const links = cycleCertificates(
			cycle({
				isFRMActive: true,
				isFRMCompleted: true,
				completedFRMCertURL: "/apex/CPDCertificate_FRM?id=c1",
				isSCRActive: true,
				isSCRCompleted: false,
				completedSCRCertURL: "/apex/CPDCertificate_SCR?id=c1",
			}),
		)
		expect(links).toEqual([
			{
				designation: "FRM",
				label: "CPD Certificate - FRM",
				url: "/apex/CPDCertificate_FRM?id=c1",
			},
		])
	})

	it("lists FRM and ERP separately even though they share one combined PDF", () => {
		const shared = "/apex/CPDCertificate_FRM_ERP?id=c1"
		const links = cycleCertificates(
			cycle({
				isFRMActive: true,
				isFRMCompleted: true,
				completedFRMCertURL: shared,
				isERPActive: true,
				isERPCompleted: true,
				completedERPCertURL: shared,
			}),
		)
		expect(links.map((link) => link.designation)).toEqual(["FRM", "ERP"])
	})

	it("skips a completed designation with no URL", () => {
		expect(
			cycleCertificates(cycle({ isRAIActive: true, isRAICompleted: true })),
		).toEqual([])
	})
})

describe("formatCredits", () => {
	it("pluralises — the legacy printed '1 credits'", () => {
		expect(formatCredits(1)).toBe("1 credit")
		expect(formatCredits(2)).toBe("2 credits")
		expect(formatCredits(2.5)).toBe("2.5 credits")
		expect(formatCredits(null)).toBe("0 credits")
	})
})

describe("buildClaimRowPresentation", () => {
	it("formats the date and falls back to the activity type for a title", () => {
		const row = buildClaimRowPresentation({
			claimId: "cl1",
			activityType: "at1",
			activityTypeName: "Webinar",
			dateOfCompletion: "2024-03-04",
			dateOfCompletionString: null,
			credits: 1,
			areaOfStudy: "Credit Risk;Market Risk",
			comments: null,
			URL: null,
			provider: null,
			providerOther: null,
			title: null,
			organizationName: null,
			contactEmail: null,
			publication: null,
			approvalComments: null,
			isFRM: false,
			isERP: false,
			isSCR: false,
			isRAI: null,
		})
		expect(row.title).toBe("Webinar")
		expect(row.creditsLabel).toBe("1 credit")
		expect(row.dateLabel).toContain("2024")
	})
})

function activityType(
	overrides: Partial<CpdActivityFieldInfo> = {},
): CpdActivityFieldInfo {
	return {
		id: "at1",
		name: "Webinar",
		organizationLabel: null,
		providerLabel: null,
		publicationLabel: null,
		titleLabel: null,
		contactEmailLabel: null,
		...overrides,
	}
}

describe("dynamicFieldsFor", () => {
	/**
	 * Apex returns a label only for the fields an admin configured, so presence
	 * is the switch and the value is the field's visible name.
	 */
	it("shows only the fields the activity type carries a label for", () => {
		const fields = dynamicFieldsFor(
			activityType({ providerLabel: "Webinar Provider", titleLabel: "Webinar Title" }),
		)
		expect(fields.map((field) => field.name)).toEqual(["provider", "title"])
		expect(fields.map((field) => field.label)).toEqual([
			"Webinar Provider",
			"Webinar Title",
		])
	})

	it("uses the admin label verbatim — Publication can read as Journal", () => {
		const [field] = dynamicFieldsFor(activityType({ publicationLabel: "Journal" }))
		expect(field.label).toBe("Journal")
		expect(field.name).toBe("publication")
	})

	it("keeps provider optional while the other extras are required", () => {
		const fields = dynamicFieldsFor(
			activityType({
				providerLabel: "Provider",
				titleLabel: "Title",
				organizationLabel: "Organization",
				publicationLabel: "Publication",
				contactEmailLabel: "Contact Email",
			}),
		)
		const required = Object.fromEntries(
			fields.map((field) => [field.name, field.required]),
		)
		expect(required).toEqual({
			organizationName: true,
			provider: false,
			publication: true,
			title: true,
			contactEmail: true,
		})
	})

	it("types the email field so the control can validate it", () => {
		const [field] = dynamicFieldsFor(activityType({ contactEmailLabel: "Email" }))
		expect(field.kind).toBe("email")
	})

	it("ignores a blank label and an absent type", () => {
		expect(dynamicFieldsFor(activityType({ titleLabel: "   " }))).toEqual([])
		expect(dynamicFieldsFor(null)).toEqual([])
	})
})

describe("findActivityType", () => {
	it("matches on record id", () => {
		const types = [activityType({ id: "a" }), activityType({ id: "b", name: "Course" })]
		expect(findActivityType(types, "b")?.name).toBe("Course")
		expect(findActivityType(types, "missing")).toBeNull()
		expect(findActivityType(types, null)).toBeNull()
	})
})

describe("area of study", () => {
	it("splits and rejoins the semicolon-delimited Apex string", () => {
		expect(splitAreaOfStudy("Credit Risk;Market Risk")).toEqual([
			"Credit Risk",
			"Market Risk",
		])
		expect(formatAreaOfStudy("Credit Risk;Market Risk")).toBe(
			"Credit Risk, Market Risk",
		)
		expect(splitAreaOfStudy(null)).toEqual([])
	})
})

describe("date helpers", () => {
	it("narrows whatever Apex sent to a yyyy-MM-dd input value", () => {
		expect(toDateInputValue("2024-03-04")).toBe("2024-03-04")
		expect(toDateInputValue("2024-03-04T00:00:00.000Z")).toBe("2024-03-04")
		expect(toDateInputValue(null)).toBe("")
	})

	it("formats today in local time, not UTC", () => {
		expect(todayInputValue(new Date(2026, 0, 5))).toBe("2026-01-05")
	})
})

function catalogueActivity(overrides: Partial<CpdActivity> = {}): CpdActivity {
	return {
		id: "ca1",
		title: "Climate Risk Webinar",
		description: "A one hour webinar.",
		location: "Online",
		sortDate: "2026-03-04",
		activityDate: "March 2026",
		activityType: "Webinar",
		activityTypeId: "at1",
		areasOfStudy: "Credit Risk;Market Risk",
		credits: 1.5,
		organization: "GARP",
		provider: "GARP Provider",
		providerId: null,
		publication: null,
		url: "https://www.garp.org/webinar",
		...overrides,
	}
}

describe("paging", () => {
	it("counts pages from the server total", () => {
		expect(pageCount(0, 20)).toBe(1)
		expect(pageCount(20, 20)).toBe(1)
		expect(pageCount(21, 20)).toBe(2)
		expect(pageCount(137, 20)).toBe(7)
		expect(pageCount(null, 20)).toBe(1)
	})

	it("describes the current range", () => {
		expect(pageRange(1, 20, 137)).toEqual({ from: 1, to: 20, total: 137 })
		expect(pageRange(7, 20, 137)).toEqual({ from: 121, to: 137, total: 137 })
		expect(pageRange(1, 20, 0)).toEqual({ from: 0, to: 0, total: 0 })
	})
})

describe("buildActivityCardPresentation", () => {
	it("formats the delimited areas of study, unlike the legacy card", () => {
		expect(buildActivityCardPresentation(catalogueActivity()).areasOfStudy).toBe(
			"Credit Risk, Market Risk",
		)
	})

	it("joins the meta line and drops missing parts", () => {
		expect(buildActivityCardPresentation(catalogueActivity()).metaLine).toBe(
			"March 2026 | GARP Provider",
		)
		expect(
			buildActivityCardPresentation(
				catalogueActivity({ provider: null }),
			).metaLine,
		).toBe("March 2026")
	})

	it("falls back to the activity type when a row has no title", () => {
		expect(
			buildActivityCardPresentation(catalogueActivity({ title: null })).title,
		).toBe("Webinar")
	})
})

describe("activityToClaimSeed", () => {
	it("carries the catalogue values onto a new claim", () => {
		const seed = activityToClaimSeed(catalogueActivity())
		expect(seed).toMatchObject({
			claimId: null,
			activityType: "at1",
			credits: 1.5,
			areaOfStudy: "Credit Risk;Market Risk",
			title: "Climate Risk Webinar",
			organizationName: "GARP",
			URL: "https://www.garp.org/webinar",
		})
	})

	/**
	 * The legacy seeded this from `activityDate`, a free-text description, so
	 * `new Date(...)` usually produced Invalid Date and the field arrived broken.
	 */
	it("leaves the completion date for the member to pick", () => {
		expect(activityToClaimSeed(catalogueActivity()).dateOfCompletion).toBeNull()
	})

	it("uses the provider name, since the port never populates providerId", () => {
		const seed = activityToClaimSeed(catalogueActivity())
		expect(seed.provider).toBe("GARP Provider")
		expect(seed.providerOther).toBe("GARP Provider")
	})
})
