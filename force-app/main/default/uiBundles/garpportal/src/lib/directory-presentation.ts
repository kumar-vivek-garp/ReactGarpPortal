import type {
	DirectoryMember,
	DirectorySearchParams,
	DirectoryView,
} from "@/api/directory"

/** "Head of Risk · Abrdn plc · United Kingdom", skipping what is redacted. */
export function directoryMemberSubtitle(member: DirectoryMember): string {
	return [member.corporateTitle, member.company, member.mailingCountry]
		.map((part) => part?.trim())
		.filter((part): part is string => Boolean(part))
		.join(" · ")
}

/** The designations a row is allowed to show, as short codes. */
export function directoryCredentials(member: DirectoryMember): string[] {
	const held = [
		member.isFRMCertified ? "FRM" : null,
		member.isERPCertified ? "ERP" : null,
		member.isSCRHolder ? "SCR" : null,
		member.isRAIHolder ? "RAI" : null,
	].filter((code): code is string => Boolean(code))

	const others = (member.designations ?? [])
		.map((code) => code?.trim())
		.filter((code): code is string => Boolean(code))

	return [...held, ...others]
}

export type DirectoryPageState = {
	pageCurrent: number
	pages: number
	total: number
	hasPrevious: boolean
	hasNext: boolean
	/** "1–10 of 84" — or null when there is nothing to describe. */
	rangeLabel: string | null
}

/**
 * Paging state from the server's own counts.
 *
 * `pages` and `total` are computed by Apex against the same filters, so
 * nothing is recomputed here — this only decides what the controls may do.
 */
export function directoryPageState(results: {
	pageCurrent: number
	pageSize: number
	pages: number
	total: number
} | null | undefined): DirectoryPageState {
	const pageCurrent = Math.max(1, results?.pageCurrent ?? 1)
	const pages = Math.max(0, results?.pages ?? 0)
	const total = Math.max(0, results?.total ?? 0)
	const pageSize = Math.max(1, results?.pageSize ?? 10)

	const first = (pageCurrent - 1) * pageSize + 1
	const last = Math.min(total, pageCurrent * pageSize)

	return {
		pageCurrent,
		pages,
		total,
		hasPrevious: pageCurrent > 1,
		hasNext: pageCurrent < pages,
		rangeLabel: total > 0 ? `${first}–${last} of ${total}` : null,
	}
}

/**
 * The upsell beside the advanced-search panel.
 *
 * `upsellMembershipType` is null for a member in good standing, "Renew" for a
 * lapsed Individual and "Upgrade" for everyone else. A pending membership
 * order outranks both — sending someone to buy again when they have already
 * ordered is the legacy's own mistake on the membership page.
 */
export function directoryUpsell(view: DirectoryView | null | undefined): {
	label: string
	orderId: string | null
} | null {
	const type = view?.upsellMembershipType?.trim()
	if (!type) return null
	const orderId = view?.pendingMembershipOrderId?.trim() || null
	if (orderId) return { label: "View Order", orderId }
	return { label: type === "Renew" ? "Renew Now" : "Upgrade", orderId: null }
}

/**
 * Builds the search body.
 *
 * A new set of criteria always starts at page 1. The legacy kept whatever page
 * the member was on, so narrowing a search from page 4 returned an empty list
 * that looked like "no results" — one of the three live bugs on that screen.
 */
export function toDirectorySearchParams(input: {
	searchText: string
	company: string
	industries: string[]
	jobFunctions: string[]
	riskSpecialties: string[]
	corporateTitles: string[]
	certifications: string[]
	pageCurrent: number
	pageSize?: number
}): DirectorySearchParams {
	const certs = new Set(input.certifications)
	return {
		searchText: input.searchText.trim() || null,
		company: input.company.trim() || null,
		industries: input.industries,
		jobFunctions: input.jobFunctions,
		riskSpecialties: input.riskSpecialties,
		corporateTitles: input.corporateTitles,
		FRMOnly: certs.has("FRM"),
		ERPOnly: certs.has("ERP"),
		SCROnly: certs.has("SCR"),
		RAIOnly: certs.has("RAI"),
		pageCurrent: Math.max(1, input.pageCurrent),
		pageSize: input.pageSize ?? 10,
	}
}

/**
 * Two-letter monogram for the avatar fallback.
 *
 * Built from first/last where Apex gave them and from the display name
 * otherwise — a redacted row can carry a name and no name parts. Falls back to
 * a neutral mark rather than rendering an empty circle.
 */
export function memberInitials(member: DirectoryMember): string {
	const first = member.firstName?.trim()
	const last = member.lastName?.trim()
	if (first || last) {
		return `${first?.[0] ?? ""}${last?.[0] ?? ""}`.toUpperCase() || "GA"
	}

	const words = (member.name ?? "")
		.trim()
		.split(/\s+/)
		.filter(Boolean)
	if (words.length === 0) return "GA"
	if (words.length === 1) return words[0].slice(0, 2).toUpperCase()
	return `${words[0][0]}${words[words.length - 1][0]}`.toUpperCase()
}

/** How many filters are in effect — drives the badge on the Filters button. */
export function activeFilterCount(state: {
	company: string
	certifications: string[]
	values: Record<string, string[]>
}): number {
	const fromValues = Object.values(state.values).reduce(
		(total, list) => total + list.length,
		0,
	)
	return (
		(state.company.trim() ? 1 : 0) + state.certifications.length + fromValues
	)
}
