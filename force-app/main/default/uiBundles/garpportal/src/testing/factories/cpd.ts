/**
 * Typed fixtures for the CPD activities contract (`api/cpd/types.ts`).
 * Typed against the api types so a contract drift breaks compilation,
 * not just runtime.
 */

import type {
	CpdActivity,
	CpdActivityView,
	CpdClaim,
	CpdCycleInfo,
	CpdProgramView,
} from "@/api/cpd"

export function cpdActivity(overrides: Partial<CpdActivity> = {}): CpdActivity {
	return {
		id: "act-1",
		title: "Climate Risk Webinar",
		description: null,
		location: null,
		sortDate: "2026-02-01",
		activityDate: "1 February 2026",
		activityType: "Webinar",
		activityTypeId: "type-webinar",
		areasOfStudy: "Credit Risk;Market Risk",
		credits: 2,
		organization: "GARP",
		provider: "GARP",
		providerId: null,
		publication: null,
		url: null,
		...overrides,
	}
}

export function cpdClaim(overrides: Partial<CpdClaim> = {}): CpdClaim {
	return {
		claimId: "claim-1",
		activityType: "type-webinar",
		activityTypeName: "Webinar",
		dateOfCompletion: "2026-02-01",
		dateOfCompletionString: null,
		credits: 2,
		areaOfStudy: "Credit Risk",
		comments: null,
		URL: null,
		provider: null,
		providerOther: null,
		title: "Climate Risk Webinar",
		organizationName: null,
		contactEmail: null,
		publication: null,
		approvalComments: null,
		isFRM: true,
		isERP: false,
		isSCR: false,
		isRAI: null,
		...overrides,
	}
}

export function cpdCycleInfo(
	overrides: Partial<CpdCycleInfo> = {},
): CpdCycleInfo {
	return {
		programId: "prog-1",
		cycleName: "2025/2027",
		startYear: 2025,
		endYear: 2027,
		status: "active",
		isAttested: false,
		attestationID: null,
		isFRMActive: true,
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
		creditsSubmitted: 10,
		creditsApproved: 8,
		creditsRequired: 40,
		creditsRequiredFRM: 40,
		creditsRequiredERP: null,
		creditsRequiredSCR: null,
		creditsRequiredRAI: null,
		approvedClaims: [],
		pendingClaims: [],
		...overrides,
	}
}

/** The whole `cpdProgram` payload; `currentCycle` follows the first cycle. */
export function cpdProgramView(
	overrides: Partial<CpdProgramView> = {},
): CpdProgramView {
	const cycles = overrides.cycles ?? [cpdCycleInfo()]
	return {
		currentCycle: cycles[0]?.cycleName ?? null,
		cpdHandbookURL: null,
		...overrides,
		cycles,
	}
}

/** One page of Browse Credit Opportunities; facet menus follow the rows. */
export function cpdActivityView(
	overrides: Partial<CpdActivityView> = {},
): CpdActivityView {
	const cpdActivities = overrides.cpdActivities ?? [cpdActivity()]
	return {
		sortOptions: [],
		activityTypes: ["Webinar", "Reading"],
		areasOfStudy: ["Credit Risk", "Market Risk"],
		providers: ["GARP"],
		totalCount: cpdActivities?.length ?? 0,
		...overrides,
		cpdActivities,
	}
}
