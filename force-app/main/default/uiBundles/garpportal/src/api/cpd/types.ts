import type { MemberPortalEnvelope } from "@/api/account/types"

/**
 * Types mirroring the Apex CPD services in `GARP_Portal_API`:
 * `GARP_Portal_CpdService` (dashboard card) and
 * `GARP_Portal_CpdProgramService` (the CPD page).
 */

/** The four certifications a CPD cycle can be answerable for. */
export type CpdDesignation = "FRM" | "ERP" | "SCR" | "RAI"

/** Cycle status values Apex can emit. Widened — Setup can add more. */
export type CpdCycleStatus =
	| "active"
	| "activated"
	| "completed"
	| "expired"
	| (string & {})
	| null

/**
 * `GET cpd` — the dashboard card (`GARP_Portal_CpdService.CpdView`).
 *
 * Every `*TotalNeeded` / `*Completed` pair is null unless the member holds
 * that certification, so "is this designation on the card" is a null check.
 *
 * A member who HAS a CPE contract but holds no completed certification comes
 * back 200 with every number null: the service sets 501 for that case and then
 * unconditionally overwrites it with 200 two lines later. So "has CPD" cannot
 * be inferred from the status code alone — check for a non-null designation.
 *
 * `raiTotalNeeded` is 10 here and 20 on `cpdProgram`. That is not a bug — the
 * two legacy Apex classes disagree and both ports reproduce the disagreement
 * deliberately, so the new portal matches the legacy portal while both are
 * live. See the RAI_REQUIRED note in `GARP_Portal_CpdService`.
 */
export type CpdView = {
	statusMessage: string | null
	statusCode: number
	/** "2025/2026", from the CPE contract's start and end years. */
	cpdCycle: string | null
	frmTotalNeeded: number | null
	frmCompleted: number | null
	erpTotalNeeded: number | null
	erpCompleted: number | null
	scrTotalNeeded: number | null
	scrCompleted: number | null
	raiTotalNeeded: number | null
	raiCompleted: number | null
	creditsRemaining: number | null
}

/** One logged activity (`CPE_Claim__c`) on a cycle. */
export type CpdClaim = {
	claimId: string | null
	/** The CPE_Activity_Type__c record Id, not the display name. */
	activityType: string | null
	activityTypeName: string | null
	/** ISO date (yyyy-MM-dd) or null. */
	dateOfCompletion: string | null
	/**
	 * Declared on the Apex DTO but never assigned — `claimFrom()` sets
	 * `dateOfCompletion` and nothing else. Always null; use `dateOfCompletion`.
	 */
	dateOfCompletionString: string | null
	credits: number | null
	/** Semicolon-delimited, e.g. "Credit Risk;Market Risk". */
	areaOfStudy: string | null
	comments: string | null
	URL: string | null
	provider: string | null
	providerOther: string | null
	title: string | null
	organizationName: string | null
	contactEmail: string | null
	publication: string | null
	approvalComments: string | null
	isFRM: boolean
	isERP: boolean
	isSCR: boolean
	/** Only assigned when `RAI__c` survived the Apex query retry — can be null. */
	isRAI: boolean | null
}

/**
 * One CPE contract — a two-year cycle named "<start>/<end>".
 *
 * `pendingClaims` is only ever populated on the CURRENT cycle. A pending claim
 * against a closed cycle still counts in `creditsSubmitted` but is never
 * listed, which is why submitted can exceed what a past cycle shows.
 */
export type CpdCycleInfo = {
	programId: string | null
	/** "2023/2025". */
	cycleName: string | null
	startYear: number | null
	endYear: number | null
	/**
	 * Lowercased `Contract.Status`, with "activated ( auto-renew )" mapped to
	 * "active" — so the real domain is active | activated | completed | expired.
	 * Never derive "is this the current cycle?" from it; compare `cycleName`
	 * against `CpdProgramView.currentCycle`, which is what Apex itself does.
	 */
	status: CpdCycleStatus
	isAttested: boolean
	attestationID: string | null

	isFRMActive: boolean
	isERPActive: boolean
	isSCRActive: boolean
	isRAIActive: boolean

	isFRMCompleted: boolean
	isERPCompleted: boolean
	isSCRCompleted: boolean
	isRAICompleted: boolean

	/** Visualforce paths (`/apex/CPDCertificate_FRM?id=`), not absolute URLs. */
	completedFRMCertURL: string | null
	completedERPCertURL: string | null
	completedSCRCertURL: string | null
	completedRAICertURL: string | null

	creditsSubmitted: number | null
	creditsApproved: number | null
	creditsRequired: number | null

	creditsRequiredFRM: number | null
	creditsRequiredERP: number | null
	creditsRequiredSCR: number | null
	creditsRequiredRAI: number | null

	approvedClaims: CpdClaim[] | null
	pendingClaims: CpdClaim[] | null
}

/**
 * `GET cpdProgram` — every cycle, its credits and its claims.
 *
 * Unlike most memberportal payloads this one carries no `statusCode`, so the
 * envelope always reports 200. An empty `cycles` array is the "this member has
 * no CPD program" signal.
 */
/**
 * One row of `GET cpdActivityTypes` — an active `CPE_Activity_Type__c`.
 *
 * The `*Label` fields drive the Add Credits form: a non-null label means that
 * extra field applies to this activity type, and the label is what to call it
 * ("Publication" becomes "Journal" for some types). Apex leaves the others
 * null, so presence is the switch — the same mechanism the legacy relied on.
 */
export type CpdActivityFieldInfo = {
	id: string | null
	name: string | null
	organizationLabel: string | null
	providerLabel: string | null
	publicationLabel: string | null
	titleLabel: string | null
	contactEmailLabel: string | null
}

/** One row of the Browse Credit Opportunities catalogue (`CPE_Activity__c`). */
export type CpdActivity = {
	id: string | null
	title: string | null
	description: string | null
	location: string | null
	/** ISO date used for sorting. */
	sortDate: string | null
	/** Free-text "Date Description", not a parseable date. */
	activityDate: string | null
	activityType: string | null
	activityTypeId: string | null
	/** Semicolon-delimited. */
	areasOfStudy: string | null
	credits: number | null
	organization: string | null
	provider: string | null
	/** Declared on the Apex DTO but never assigned — use `provider`. */
	providerId: string | null
	publication: string | null
	url: string | null
}

/**
 * `GET cpdActivities` — a paged, filtered slice of the catalogue.
 *
 * The three facet lists are derived from the CURRENT PAGE's rows, not the whole
 * catalogue, so they shift as you page. That is a reproduced legacy quirk;
 * stable menus would need a backend change.
 */
export type CpdActivityView = {
	sortOptions: string[] | null
	activityTypes: string[] | null
	areasOfStudy: string[] | null
	providers: string[] | null
	cpdActivities: CpdActivity[] | null
	/** Total matching the filter, across all pages. */
	totalCount: number | null
}

/** Query-string filters. Multi-value fields are semicolon-delimited. */
export type CpdActivityFilters = {
	/**
	 * One activity by id.
	 *
	 * **Overrides everything else.** Apex builds `WHERE Id = :singleId` and
	 * drops the facet, sort and paging clauses entirely — the filters are not
	 * combined with it, they are ignored. An unknown id is not an error either:
	 * it comes back as an empty list at 200.
	 */
	activityId?: string
	activityTypes?: string[]
	areasOfStudy?: string[]
	providers?: string[]
	sortOrder?: string
	pageSize?: number
	/** 1-based. */
	pageCurrent?: number
}

/** What a member may set on a claim (Apex `CpdClaimService.ClaimInput`). */
export type CpdClaimInput = {
	/** Omit to create; supply to update the member's own claim. */
	claimId?: string | null
	/** The CPE_Activity_Type__c record Id, not its name. */
	activityType: string | null
	credits: number
	/** ISO `yyyy-MM-dd` — Apex takes the locale-independent parse branch. */
	dateOfCompletionString: string
	areaOfStudy?: string | null
	comments?: string | null
	URL?: string | null
	provider?: string | null
	title?: string | null
	organizationName?: string | null
	contactEmail?: string | null
	publication?: string | null
}

/**
 * Result of every CPD write (`SaveResult`).
 *
 * It carries no `statusCode`, so the envelope reports 200 and `status:
 * "Success"` even when the write was refused — the real outcome is this
 * `status` field. Callers must check it or server messages like "Claim not
 * found" are silently swallowed.
 */
export type CpdSaveResult = {
	status: string | null
	msg: string | null
	/** The saved claim, so the page can reconcile without a refetch. */
	claimId: string | null
}

export type CpdProgramView = {
	/** The cycle the page opens on, by `cycleName`. */
	currentCycle: string | null
	cycles: CpdCycleInfo[]
	/**
	 * Not currently returned by Apex — the legacy hardcoded it server-side in
	 * `GARP_BC_MemberPortal.getCPDListingInfo` and the port has not carried it
	 * across yet. Declared so that if the backend adds it, the client picks it
	 * up without a release; until then `CPD_HANDBOOK_URL` stands in.
	 */
	cpdHandbookURL?: string | null
}

export type { MemberPortalEnvelope }
