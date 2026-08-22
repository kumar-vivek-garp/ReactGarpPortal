import type {
	CpdActivity,
	CpdActivityFieldInfo,
	CpdClaim,
	CpdCycleInfo,
	CpdDesignation,
	CpdProgramView,
	CpdView,
} from "@/api/cpd"
import { CPD_DESIGNATIONS } from "@/config/cpd"
import { formatLongDate } from "@/lib/account-format"

/**
 * Pure derivations for the CPD page and the dashboard CPD card.
 *
 * The two surfaces read different endpoints on purpose and must not be folded
 * together: `cycleCreditRows` reads `cpdProgram` and `dashboardCreditRows`
 * reads `cpd`, and the two disagree about RAI — 20 required on the page, 10 on
 * the card. That is the legacy's own inconsistency, reproduced deliberately by
 * both Apex ports (see the RAI notes in `GARP_Portal_CpdService` and
 * `GARP_Portal_CpdProgramService`). Keeping the two builders separate means
 * there is no shared constant anyone could "fix" by accident.
 */

/** One bar: credits approved against credits required for a designation. */
export type CpdCreditBarRow = {
	designation: CpdDesignation
	approved: number
	required: number
}

export type CpdCertificateLink = {
	designation: CpdDesignation
	label: string
	/** Visualforce path; resolve with `resolveExperienceHref` before use. */
	url: string
}

function toNumber(value: number | null | undefined): number {
	return typeof value === "number" && Number.isFinite(value) ? value : 0
}

/**
 * Cycle names for the picker — server order (newest first), deduplicated.
 * A cycle with no start or end date has a null name and is dropped rather
 * than collapsing unrelated cycles onto a single blank option.
 */
export function dedupeCycleOptions(
	cycles: CpdCycleInfo[] | null | undefined,
): string[] {
	const seen = new Set<string>()
	const out: string[] = []
	for (const cycle of cycles ?? []) {
		const name = cycle.cycleName?.trim()
		if (!name || seen.has(name)) continue
		seen.add(name)
		out.push(name)
	}
	return out
}

/**
 * The cycle to render: the chosen one, else the server's `currentCycle`, else
 * the first. An unknown name falls through to the default rather than leaving
 * the page with nothing to show, which is what the legacy did.
 */
export function resolveActiveCycle(
	view: CpdProgramView | null | undefined,
	chosenName?: string | null,
): CpdCycleInfo | null {
	const cycles = view?.cycles ?? []
	if (cycles.length === 0) return null

	const chosen = chosenName?.trim()
	if (chosen) {
		const match = cycles.find((cycle) => cycle.cycleName === chosen)
		if (match) return match
	}

	const current = view?.currentCycle?.trim()
	if (current) {
		const match = cycles.find((cycle) => cycle.cycleName === current)
		if (match) return match
	}

	return cycles[0]
}

/**
 * Whether this is the live cycle — the only one that carries pending claims
 * and the only one the manage box applies to.
 *
 * Compares `cycleName` rather than reading `status`, because `status` is a
 * lowercased `Contract.Status` whose domain includes both "active" (mapped
 * from "activated ( auto-renew )") and a bare "activated". Apex itself
 * decides the current cycle by name.
 */
export function isCurrentCycle(
	cycle: CpdCycleInfo | null | undefined,
	view: CpdProgramView | null | undefined,
): boolean {
	const name = cycle?.cycleName?.trim()
	const current = view?.currentCycle?.trim()
	return Boolean(name && current && name === current)
}

/**
 * Bars for the CPD page — one per designation the cycle is answerable for.
 * The same `creditsApproved` total feeds every row; Apex does not attribute
 * credits per designation.
 */
export function cycleCreditRows(
	cycle: CpdCycleInfo | null | undefined,
): CpdCreditBarRow[] {
	if (!cycle) return []
	const approved = toNumber(cycle.creditsApproved)

	const active: Record<CpdDesignation, boolean> = {
		FRM: cycle.isFRMActive,
		ERP: cycle.isERPActive,
		SCR: cycle.isSCRActive,
		RAI: cycle.isRAIActive,
	}
	const required: Record<CpdDesignation, number | null> = {
		FRM: cycle.creditsRequiredFRM,
		ERP: cycle.creditsRequiredERP,
		SCR: cycle.creditsRequiredSCR,
		RAI: cycle.creditsRequiredRAI,
	}

	return CPD_DESIGNATIONS.filter((d) => active[d]).map((designation) => ({
		designation,
		approved,
		required: toNumber(required[designation]),
	}))
}

/**
 * Bars for the dashboard card. Keyed on "this member has a completed value",
 * matching the legacy card, which tested `null != frmCompleted` rather than
 * an active flag.
 */
export function dashboardCreditRows(
	view: CpdView | null | undefined,
): CpdCreditBarRow[] {
	if (!view) return []

	const completed: Record<CpdDesignation, number | null> = {
		FRM: view.frmCompleted,
		ERP: view.erpCompleted,
		SCR: view.scrCompleted,
		RAI: view.raiCompleted,
	}
	const needed: Record<CpdDesignation, number | null> = {
		FRM: view.frmTotalNeeded,
		ERP: view.erpTotalNeeded,
		SCR: view.scrTotalNeeded,
		RAI: view.raiTotalNeeded,
	}

	return CPD_DESIGNATIONS.filter((d) => completed[d] != null).map(
		(designation) => ({
			designation,
			approved: toNumber(completed[designation]),
			required: toNumber(needed[designation]),
		}),
	)
}

/**
 * Whether the dashboard card has anything to show.
 *
 * A 401 resolves to `null` upstream, but there is a second empty case that
 * still answers 200: a member with a CPE contract and no completed
 * certification comes back with every number null, because the service sets
 * 501 for that case and then overwrites it with 200 two lines later. Both
 * cases must suppress the card — the legacy rendered a blank chart for them.
 */
export function hasDashboardCpdCredits(
	view: CpdView | null | undefined,
): boolean {
	return dashboardCreditRows(view).length > 0
}

/**
 * "20 credits remaining this cycle", or null once nothing is owed.
 *
 * `creditsRemaining` reports a single programme — the first of FRM, ERP, SCR,
 * RAI the member holds, in that order — which is what the legacy card showed.
 */
export function cpdRemainingLabel(
	view: CpdView | null | undefined,
): string | null {
	const remaining = view?.creditsRemaining
	if (typeof remaining !== "number" || remaining <= 0) return null
	return `${formatCredits(remaining)} remaining this cycle`
}

/** "2023/2025 CPD Credits", degrading gracefully when the cycle is unnamed. */
export function cpdCardTitle(view: CpdView | null | undefined): string {
	const cycle = view?.cpdCycle?.trim()
	return cycle ? `${cycle} CPD Credits` : "CPD Credits"
}

/**
 * Certificate links for a cycle — one per designation both active and
 * complete. FRM and ERP legitimately resolve to the same combined PDF when
 * both are complete, so rows are keyed on designation, not URL.
 */
export function cycleCertificates(
	cycle: CpdCycleInfo | null | undefined,
): CpdCertificateLink[] {
	if (!cycle) return []

	const eligible: Record<CpdDesignation, boolean> = {
		FRM: cycle.isFRMActive && cycle.isFRMCompleted,
		ERP: cycle.isERPActive && cycle.isERPCompleted,
		SCR: cycle.isSCRActive && cycle.isSCRCompleted,
		RAI: cycle.isRAIActive && cycle.isRAICompleted,
	}
	const urls: Record<CpdDesignation, string | null> = {
		FRM: cycle.completedFRMCertURL,
		ERP: cycle.completedERPCertURL,
		SCR: cycle.completedSCRCertURL,
		RAI: cycle.completedRAICertURL,
	}

	return CPD_DESIGNATIONS.filter(
		(d) => eligible[d] && Boolean(urls[d]?.trim()),
	).map((designation) => ({
		designation,
		label: `CPD Certificate - ${designation}`,
		// Non-null: the filter above already rejected blank URLs.
		url: (urls[designation] as string).trim(),
	}))
}

/** "2.5 credits" / "1 credit". Apex sends a Decimal, so halves are normal. */
export function formatCredits(credits: number | null | undefined): string {
	const value = toNumber(credits)
	return `${value} ${value === 1 ? "credit" : "credits"}`
}

export type CpdClaimRowPresentation = {
	title: string
	dateLabel: string | null
	creditsLabel: string
}

/**
 * One activity row. Apex already falls `title` back to the activity type
 * name, so this only has to cover a claim with neither.
 */
export function buildClaimRowPresentation(
	claim: CpdClaim,
): CpdClaimRowPresentation {
	return {
		title: claim.title?.trim() || claim.activityTypeName?.trim() || "Activity",
		dateLabel: formatLongDate(claim.dateOfCompletion),
		creditsLabel: formatCredits(claim.credits),
	}
}

// =====================================================================
// The Add Credits form's dynamic fields
// =====================================================================

/** The five optional extras, and the label field that switches each one on. */
const DYNAMIC_FIELDS = [
	{ name: "organizationName", labelKey: "organizationLabel", required: true },
	{ name: "provider", labelKey: "providerLabel", required: false },
	{ name: "publication", labelKey: "publicationLabel", required: true },
	{ name: "title", labelKey: "titleLabel", required: true },
	{ name: "contactEmail", labelKey: "contactEmailLabel", required: true },
] as const

export type CpdDynamicFieldName = (typeof DYNAMIC_FIELDS)[number]["name"]

export type CpdDynamicField = {
	name: CpdDynamicFieldName
	/** Admin-configured, e.g. "Publication" is relabelled "Journal". */
	label: string
	required: boolean
	kind: "text" | "email"
}

/**
 * Which extra fields the chosen activity type asks for.
 *
 * Apex returns a label only for the fields an admin configured on that type
 * and leaves the rest null, so the presence of a label is the switch and its
 * value is what to call the field. `provider` is the one extra that is shown
 * but never required — matching the legacy, whose label carried no asterisk.
 */
export function dynamicFieldsFor(
	activityType: CpdActivityFieldInfo | null | undefined,
): CpdDynamicField[] {
	if (!activityType) return []
	return DYNAMIC_FIELDS.flatMap((field) => {
		const label = activityType[field.labelKey]?.trim()
		if (!label) return []
		return [
			{
				name: field.name,
				label,
				required: field.required,
				kind: field.name === "contactEmail" ? ("email" as const) : ("text" as const),
			},
		]
	})
}

/** Look an activity type up by its record Id. */
export function findActivityType(
	activityTypes: CpdActivityFieldInfo[] | null | undefined,
	id: string | null | undefined,
): CpdActivityFieldInfo | null {
	const key = id?.trim()
	if (!key) return null
	return (activityTypes ?? []).find((type) => type.id === key) ?? null
}

/** ";"-delimited Apex string to a list, dropping blanks. */
export function splitAreaOfStudy(value: string | null | undefined): string[] {
	return (value ?? "")
		.split(";")
		.map((part) => part.trim())
		.filter(Boolean)
}

/** "Credit Risk;Market Risk" reads as "Credit Risk, Market Risk". */
export function formatAreaOfStudy(value: string | null | undefined): string {
	return splitAreaOfStudy(value).join(", ")
}

/**
 * An ISO `yyyy-MM-dd` for the date input, from whatever Apex sent.
 *
 * `dateOfCompletionString` is declared on the DTO but never assigned, so
 * `dateOfCompletion` is the only real source.
 */
export function toDateInputValue(value: string | null | undefined): string {
	const raw = value?.trim()
	if (!raw) return ""
	return raw.slice(0, 10)
}

/** Today as `yyyy-MM-dd`, for the date input's `max`. */
export function todayInputValue(now: Date = new Date()): string {
	const month = String(now.getMonth() + 1).padStart(2, "0")
	const day = String(now.getDate()).padStart(2, "0")
	return `${now.getFullYear()}-${month}-${day}`
}

// =====================================================================
// Browse Credit Opportunities
// =====================================================================

/** Total pages for a server-paged result. Always at least 1. */
export function pageCount(totalCount: number | null, pageSize: number): number {
	const total = Math.max(0, toNumber(totalCount))
	if (pageSize <= 0) return 1
	return Math.max(1, Math.ceil(total / pageSize))
}

/** The 1-based range this page covers, for "Showing 21–40 of 137". */
export function pageRange(
	page: number,
	pageSize: number,
	totalCount: number | null,
): { from: number; to: number; total: number } {
	const total = Math.max(0, toNumber(totalCount))
	if (total === 0) return { from: 0, to: 0, total: 0 }
	const from = (page - 1) * pageSize + 1
	return { from, to: Math.min(page * pageSize, total), total }
}

export type CpdActivityCardPresentation = {
	title: string
	creditsLabel: string
	areasOfStudy: string
	/** "12 March 2026 | GARP" — whichever parts exist. */
	metaLine: string
	description: string | null
	url: string | null
}

/**
 * One catalogue row.
 *
 * `areasOfStudy` is run through the same delimiter formatting the claim view
 * uses — the legacy printed the raw "Credit Risk;Market Risk" here while
 * formatting it everywhere else.
 */
export function buildActivityCardPresentation(
	activity: CpdActivity,
): CpdActivityCardPresentation {
	const meta = [activity.activityDate?.trim(), activity.provider?.trim()].filter(
		Boolean,
	)
	return {
		title: activity.title?.trim() || activity.activityType?.trim() || "Activity",
		creditsLabel: formatCredits(activity.credits),
		areasOfStudy: formatAreaOfStudy(activity.areasOfStudy),
		metaLine: meta.join(" | "),
		description: activity.description?.trim() || null,
		url: activity.url?.trim() || null,
	}
}

/**
 * Seeds Add Credits from a catalogue activity.
 *
 * Two deliberate departures from the legacy's `cpdClaim(cpdActivity)`:
 *
 *  - `dateOfCompletion` is left empty. The legacy seeded it from `activityDate`,
 *    which is a free-text "Date Description" — `new Date(...)` on it usually
 *    yielded Invalid Date and the member got a broken field. The date is when
 *    *they* completed it, so they should pick it.
 *  - `provider` takes the provider NAME, not `providerId`. The legacy used the
 *    id, but the ported service never populates `providerId`, and Apex writes
 *    this straight to the free-text `Provider_Other__c` anyway.
 */
export function activityToClaimSeed(activity: CpdActivity): CpdClaim {
	return {
		claimId: null,
		activityType: activity.activityTypeId,
		activityTypeName: activity.activityType,
		dateOfCompletion: null,
		dateOfCompletionString: null,
		credits: activity.credits,
		areaOfStudy: activity.areasOfStudy,
		comments: null,
		URL: activity.url,
		provider: activity.provider,
		providerOther: activity.provider,
		title: activity.title,
		organizationName: activity.organization,
		contactEmail: null,
		publication: activity.publication,
		approvalComments: null,
		isFRM: false,
		isERP: false,
		isSCR: false,
		isRAI: null,
	}
}
