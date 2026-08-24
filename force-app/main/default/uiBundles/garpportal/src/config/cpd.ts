import { ScrollText } from "lucide-react"
import { z } from "zod"

import type { CpdDesignation } from "@/api/cpd"

/**
 * Static CPD config — copy, links, and the designation vocabulary shared by
 * the `/cpd` page and the dashboard card.
 */

/** Bar order on both surfaces, matching the legacy chart. */
export const CPD_DESIGNATIONS: readonly CpdDesignation[] = [
	"FRM",
	"ERP",
	"SCR",
	"RAI",
] as const

/**
 * Per-designation label and bar colour.
 *
 * The legacy chart hardcoded `#00A2DD` / `#b0cb36` / `#fdb517` / `#9ea3da`.
 * FRM and SCR map onto brand tokens whose own provenance comments cite those
 * exact hexes; ERP got a token of its own (`--erp-green`); RAI uses the RAI
 * program's live-verified brand blue rather than the legacy's arbitrary
 * lavender. All four are mode-invariant, so a designation keeps its identity
 * in dark mode — which is also why the stock `chart-*` tokens are unsuitable.
 */
export const CPD_DESIGNATION_META: Record<
	CpdDesignation,
	{ label: string; barClassName: string }
> = {
	FRM: { label: "FRM", barClassName: "text-garp-cyan" },
	ERP: { label: "ERP", barClassName: "text-erp-green" },
	SCR: { label: "SCR", barClassName: "text-garp-saffron" },
	RAI: { label: "RAI", barClassName: "text-rai-blue" },
}

/**
 * Fallback handbook link.
 *
 * The legacy served this from `GARP_BC_MemberPortal.getCPDListingInfo`, which
 * hardcoded the same constant server-side; the ported `cpdProgram` action does
 * not return it yet. Preferring the payload when it appears means the eventual
 * Apex fix needs no client change, and a new brochure version does not strand
 * members on an old PDF.
 */
export const CPD_HANDBOOK_URL =
	"https://www.garp.org/hubfs/Portal/Assets/GARP_CPD_Brochure_v8.pdf"

/** The legacy's own escape hatch for CPD questions. */
export const CPD_CONTACT_EMAIL = "cpd@garp.com"

export const CPD_PAGE_TITLE = "Continuing Professional Development"

/**
 * `?cycle=2026/2027`. Optional so an absent value stays distinguishable from an
 * explicit one — the panel then opens on the server's `currentCycle`. A name
 * matching no cycle resolves to that default rather than rendering nothing,
 * which is what the legacy did.
 */
export const cpdSearchSchema = z.object({
	cycle: z.string().optional().catch(undefined),
})

export type CpdSearch = z.infer<typeof cpdSearchSchema>

// =====================================================================
// Browse Credit Opportunities (`/cpd/activities`)
// =====================================================================

/**
 * The four sort labels `GARP_Portal_CpdActivityService` recognises.
 *
 * The service also returns these in its payload, but from an Apex `Map`
 * keySet, whose order is not guaranteed — so the canonical order lives here
 * and the response's copy is ignored.
 *
 * The default is deliberately NOT the legacy's: it initialised the control to
 * "Date: Descending", which matches none of these, so the select painted blank
 * and the server applied no ORDER BY at all.
 */
export const CPD_SORT_OPTIONS = [
	"Date most recent to oldest",
	"Date oldest to most recent",
	"Credits Low to High",
	"Credits High to Low",
] as const

export type CpdSortOption = (typeof CPD_SORT_OPTIONS)[number]

export const DEFAULT_CPD_SORT: CpdSortOption = "Date most recent to oldest"

/** Apex defaults to 20 and caps at 100. */
export const CPD_ACTIVITIES_PAGE_SIZE = 20

/**
 * `/cpd/activities?type=&area=&provider=&sort=&page=`.
 *
 * Facets repeat (`?type=A&type=B`) rather than packing a delimiter into one
 * value — the delimiter is Apex's wire format, not something to leak into a
 * URL a member might share.
 */
export const cpdActivitiesSearchSchema = z.object({
	/**
	 * Scopes the page to one activity — the legacy's
	 * `/cpd-activities-detail/{id}`, kept as a search param so the page can
	 * drop back to the full list without a route change.
	 */
	activityId: z.string().optional().catch(undefined),
	type: z.array(z.string()).optional().catch(undefined),
	area: z.array(z.string()).optional().catch(undefined),
	provider: z.array(z.string()).optional().catch(undefined),
	sort: z.enum(CPD_SORT_OPTIONS).optional().catch(undefined),
	page: z.coerce.number().int().min(1).optional().catch(undefined),
})

export type CpdActivitiesSearch = z.infer<typeof cpdActivitiesSearchSchema>

export const CPD_ACTIVITIES_TITLE = "Browse CPD Activities"

/** Facet panel headings, in the legacy's order. */
export const CPD_FACETS = [
	{ key: "type", label: "Activity Type" },
	{ key: "area", label: "Area of Study" },
	{ key: "provider", label: "Providers" },
] as const

export type CpdFacetKey = (typeof CPD_FACETS)[number]["key"]

export const CPD_ACTIVITIES_ZERO_STATE = {
	icon: ScrollText,
	title: "No CPD activity found",
	message:
		"No credit opportunities match these filters. Try clearing a filter, or check back later.",
} as const

/**
 * Facet values come from the current page's rows rather than the whole
 * catalogue, so they change as you page. Reproduced from the legacy; saying so
 * beats letting a member think a filter vanished.
 */
export const CPD_FACET_SCOPE_NOTE =
	"Filter options reflect the activities on this page."

export const CPD_SECTION_COPY = {
	pending: {
		title: "Pending Activities",
		emptyLabel: "No Pending Credits",
	},
	approved: {
		title: "Approved Activities",
		emptyLabel: "No Approved Credits",
	},
} as const

export type CpdSection = keyof typeof CPD_SECTION_COPY

/** Shown when the member has no CPD cycle at all — legacy had no empty state. */
export const CPD_ZERO_STATE = {
	icon: ScrollText,
	title: "No CPD cycle yet",
	message:
		"Continuing Professional Development starts once you complete a certification. Your cycle, credits, and certificates will appear here.",
} as const

/** Shown for a cycle where no certification is answerable for credits. */
export const CPD_NO_REQUIREMENT_MESSAGE =
	"No credits are required for this cycle."

/** Attestation is a Phase B write, so certificates are visible but inert. */
export const CPD_ATTESTATION_PENDING_MESSAGE = `Attest this cycle to download. Attesting in the portal is coming soon — email ${CPD_CONTACT_EMAIL} to attest today.`
