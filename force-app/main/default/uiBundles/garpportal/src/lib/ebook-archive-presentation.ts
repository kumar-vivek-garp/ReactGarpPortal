import type {
	ApexArchiveEBook,
	MyEBooksView,
} from "@/api/study-materials/types"

/** One openable title within an edition year. */
export type ArchiveTitle = {
	/** Stable within a group — vendor id when present, else the composed label. */
	id: string
	label: string
	/** Null when the key resolved to no vendor item; the row is then unopenable. */
	vendorId: string | null
	provider: string | null
}

export type ArchiveYearGroup = {
	year: number
	titles: ArchiveTitle[]
}

/**
 * Flattens `GET myEBooks` into year groups, newest first.
 *
 * The payload is a map keyed by edition year, so it carries no order of its
 * own — JS object key order is insertion-based and Apex builds the map in
 * whatever sequence the keys came back. Sorting here is what makes "newest
 * first" true rather than accidental.
 *
 * A key can resolve to several vendor items (Part I and Part II of one
 * purchase), each of which opens separately, so the rows are the items rather
 * than the keys.
 */
export function groupEBooksByYear(
	view: MyEBooksView | null | undefined,
): ArchiveYearGroup[] {
	const source = view?.eBooks ?? {}

	return Object.entries(source)
		.map(([yearKey, books]) => ({
			year: Number(yearKey),
			titles: (Array.isArray(books) ? books : []).flatMap(archiveTitles),
		}))
		.filter((group) => Number.isFinite(group.year) && group.titles.length > 0)
		.sort((left, right) => right.year - left.year)
}

function archiveTitles(book: ApexArchiveEBook): ArchiveTitle[] {
	const items = Array.isArray(book.eBookItems) ? book.eBookItems : []
	const provider = book.provider?.trim() || null

	if (items.length === 0) {
		// Nothing to open, but the member owns it — shown as an unavailable row
		// rather than silently dropped, which is what the legacy did.
		const label = composeLabel(book, null)
		return label ? [{ id: label, label, vendorId: null, provider }] : []
	}

	return items.map((item, index) => {
		const vendorId =
			item.vendorId == null ? null : String(item.vendorId).trim() || null
		const label = composeLabel(book, item.title ?? null)
		return {
			id: vendorId ?? `${label}-${index}`,
			label: label || "Untitled book",
			vendorId,
			provider,
		}
	})
}

/**
 * "FRM — Part I", or just the item title when it already carries the key's.
 *
 * The two titles overlap unpredictably: some vendor items are named "Part I"
 * and need the key's "FRM" for context, others are already "FRM Part I" and
 * would read as "FRM — FRM Part I" if both were joined. The more specific of
 * the two wins whenever one contains the other.
 */
function composeLabel(
	book: ApexArchiveEBook,
	itemTitle: string | null,
): string {
	const key = book.title?.trim() ?? ""
	const item = itemTitle?.trim() ?? ""
	if (!item) return key
	if (!key) return item
	if (item.toLowerCase().includes(key.toLowerCase())) return item
	if (key.toLowerCase().includes(item.toLowerCase())) return key
	return `${key} — ${item}`
}

/** How many titles the archive holds, across every year. */
export function archiveTitleCount(groups: ArchiveYearGroup[]): number {
	return groups.reduce((total, group) => total + group.titles.length, 0)
}
