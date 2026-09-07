import type { StudyMaterialItem } from "@/api/study-materials/types"
import { formatLongDate } from "@/lib/account-format"
import { daysUntil } from "@/lib/days-until"
import type { MetaLine } from "@/lib/meta-line"
import { orderDetailsPath } from "@/lib/order-paths"
import { resolveExperienceHref } from "@/lib/program-card-links"
import type { StatusTone } from "@/lib/status-tone"

/** Inside this window, an access expiry is worth counting down rather than dating. */
const EXPIRING_SOON_DAYS = 30

export function studyCodeLabel(programKey: string): string {
	return programKey.trim().toUpperCase()
}

/**
 * Human phrasing for an access expiry. Prefers a countdown when the deadline is
 * close, because "expires in 9 days" prompts action where a date does not.
 */
export function accessExpiryLine(
	expirationDate: string | null | undefined,
): MetaLine | null {
	const iso = expirationDate?.slice(0, 10) ?? null
	if (!iso) return null

	const remaining = daysUntil(iso)
	if (remaining !== null && remaining < 0) {
		const date = formatLongDate(iso)
		return {
			icon: "expiringSoon",
			text: date ? `Access ended ${date}` : "Access has ended",
		}
	}
	if (remaining !== null && remaining <= EXPIRING_SOON_DAYS) {
		if (remaining === 0) return { icon: "expiringSoon", text: "Access ends today" }
		if (remaining === 1)
			return { icon: "expiringSoon", text: "Access ends tomorrow" }
		return { icon: "expiringSoon", text: `Access ends in ${remaining} days` }
	}

	const date = formatLongDate(iso)
	return date ? { icon: "accessUntil", text: `Access until ${date}` } : null
}

/** `$295`, `$12.50` — the legacy's own rendering, whole dollars unadorned. */
export function formatPrice(amount: number | null | undefined): string | null {
	if (amount == null) return null
	return `$${amount.toFixed(2).replace(/\.00$/, "")}`
}

/** The in-app purchase page for one product. */
export function purchasePath(productCode: string | null | undefined): string | null {
	const code = productCode?.trim()
	if (!code) return null
	return `/study-materials/purchase/${encodeURIComponent(code)}`
}

/** "Included with your registration · 11 February 2026" / "Purchased". */
export function ownedLine(
	item: Pick<
		StudyMaterialItem,
		"wasOrderedWithReg" | "registrationDate" | "orderedDate"
	>,
): string {
	const label = item.wasOrderedWithReg
		? "Included with your registration"
		: "Purchased"
	const on = formatLongDate(item.registrationDate ?? item.orderedDate)
	return on ? `${label} · ${on}` : label
}

/** "Available 1 June 2026", or "Available soon" when Apex gave no date. */
export function comingSoonLine(comingSoonDate: string | null | undefined): string {
	const date = formatLongDate(comingSoonDate)
	return date ? `Available ${date}` : "Available soon"
}

/**
 * What a material lets the member do right now — GarpAppv1's `Actions`,
 * first match wins. A material has more states than a catalogue entry
 * usually does, and the order is the legacy's: something already granted
 * beats something still to buy.
 */
export type MaterialAction =
	| { kind: "garpLearning"; url: string }
	| {
			kind: "external"
			label: "Read eBook" | "Download Now"
			url: string
			icon: "read" | "download"
	  }
	| { kind: "completeOrder"; path: string }
	| { kind: "owned"; text: string }
	| { kind: "comingSoon"; text: string; notifyUrl: string | null }
	| { kind: "outOfStock"; text: string }
	| { kind: "purchase"; priceLabel: string | null; path: string }
	| { kind: "contact"; text: string }
	| { kind: "none" }

export function resolveMaterialAction(item: StudyMaterialItem): MaterialAction {
	// Portal-relative SSO paths (`/BenchPrepSSO?…`) resolve against the
	// Experience site; absolute vendor URLs pass through.
	const learning = resolveExperienceHref(item.garpLearningAccessUrl)
	if (learning) return { kind: "garpLearning", url: learning }

	const read = resolveExperienceHref(item.accessUrl)
	if (read) return { kind: "external", label: "Read eBook", url: read, icon: "read" }

	const download = resolveExperienceHref(item.downloadUrl)
	if (download) {
		return { kind: "external", label: "Download Now", url: download, icon: "download" }
	}

	const orderPath = item.isUnPaidOrder ? orderDetailsPath(item.orderId) : null
	if (orderPath) return { kind: "completeOrder", path: orderPath }

	if (item.isOwned) return { kind: "owned", text: ownedLine(item) }

	if (item.isComingSoon) {
		return {
			kind: "comingSoon",
			text: comingSoonLine(item.comingSoonDate),
			notifyUrl: item.leadGenUrl,
		}
	}

	if (item.isOutOfStock) return { kind: "outOfStock", text: "Out of stock" }

	if (item.canPurchase) {
		const path = purchasePath(item.productCode)
		if (path) return { kind: "purchase", priceLabel: formatPrice(item.price), path }
		return { kind: "contact", text: "Contact member services to buy this." }
	}

	return { kind: "none" }
}

/**
 * The status chip, now that ownership is a fact on the card rather than a
 * section of its own. Null when the material is simply for sale.
 */
export function materialStatusBadge(
	item: StudyMaterialItem,
): { label: string; tone: StatusTone } | null {
	if (item.isUnPaidOrder) return { label: "Unpaid order", tone: "warning" }
	if (item.isOwned) return { label: "Owned", tone: "success" }
	// Granted by an open sitting or contract rather than bought.
	if (item.garpLearningAccessUrl || item.accessUrl) {
		return { label: "Access granted", tone: "success" }
	}
	if (item.isComingSoon) return { label: "Coming soon", tone: "info" }
	if (item.isOutOfStock) return { label: "Out of stock", tone: "neutral" }
	return null
}

/** The icon-prefixed facts under the copy — today, only the eBook key's expiry. */
export function materialMetaLines(item: StudyMaterialItem): MetaLine[] {
	const lines: MetaLine[] = []
	const expiry = accessExpiryLine(item.eBookSet?.expireDate)
	if (expiry) lines.push(expiry)
	return lines
}

export type PartGroup = {
	/** "Part 1" / "Part 2", or null for materials that belong to no part. */
	part: string | null
	items: StudyMaterialItem[]
}

/**
 * FRM is the one programme whose materials split by exam part. Part 1 leads
 * Part 2 and the un-parted items come last; every other programme yields a
 * single null-part group. Item order inside a group is Apex's.
 */
export function groupByPart(items: StudyMaterialItem[]): PartGroup[] {
	const byPart = new Map<string | null, StudyMaterialItem[]>()
	for (const item of items) {
		const key = item.relatedPart
		const group = byPart.get(key)
		if (group) group.push(item)
		else byPart.set(key, [item])
	}

	return [...byPart.entries()]
		.sort(([a], [b]) => {
			if (a === null) return 1
			if (b === null) return -1
			return a.localeCompare(b)
		})
		.map(([part, grouped]) => ({ part, items: grouped }))
}
