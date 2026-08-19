import type { CatalogueItem, StudyMaterial } from "@/api/study-materials/types"
import { formatLongDate } from "@/lib/account-format"
import { daysUntil } from "@/lib/days-until"
import type { MetaLine } from "@/lib/meta-line"
import type { StatusTone } from "@/lib/status-tone"

/** Which bucket an item came from — entitlements carry status, catalogue does not. */
export type StudyItemVariant = "owned" | "catalogue"

export type StudyItemLink = {
	label: string
	url: string
	isExternal: boolean
	newWindow?: boolean
}

/**
 * One shape for both owned materials and catalogue entries, so the grid card and
 * the list row can never show different facts about the same item.
 */
export type StudyItemPresentation = {
	id: string
	variant: StudyItemVariant
	title: string
	/** Program code chip (`FRM`, `SCR`) — drives the brand tint too. */
	programKey: string
	codeLabel: string
	/** Material kind, e.g. "eBook" / "GARP Learning" / "Book". */
	typeLabel: string | null
	statusLabel: string | null
	statusTone: StatusTone | null
	paragraphs: string[]
	imageUrl: string | null
	metaLines: MetaLine[]
	primaryAction: StudyItemLink | null
	secondaryAction: StudyItemLink | null
}

/** Inside this window, an access expiry is worth counting down rather than dating. */
const EXPIRING_SOON_DAYS = 30

const ACCESS_HELP_MAILTO =
	"mailto:memberservices@garp.com?Subject=Study%20material%20access"

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

function ownedStatus(material: StudyMaterial): {
	statusLabel: string
	statusTone: StatusTone
} {
	if (!material.isAvailable) {
		return { statusLabel: "Unavailable", statusTone: "warning" }
	}
	const status = material.status?.trim()
	if (status) return { statusLabel: status, statusTone: "info" }
	return { statusLabel: "Available", statusTone: "success" }
}

/** Maps one owned material into everything a card or row renders. */
export function buildOwnedItemPresentation(
	material: StudyMaterial,
): StudyItemPresentation {
	const { statusLabel, statusTone } = ownedStatus(material)
	const metaLines: MetaLine[] = []

	const expiry = accessExpiryLine(material.expirationDate)
	if (expiry) metaLines.push(expiry)

	if (!material.isAvailable && material.unavailableReason?.trim()) {
		metaLines.push({
			icon: "unavailable",
			text: material.unavailableReason.trim(),
		})
	}

	const canOpen = material.isAvailable && Boolean(material.accessUrl?.trim())

	return {
		id: material.id,
		variant: "owned",
		title: material.name?.trim() || "Study material",
		programKey: material.programKey,
		codeLabel: studyCodeLabel(material.programKey),
		typeLabel: material.type?.trim() || null,
		statusLabel,
		statusTone,
		paragraphs: [],
		imageUrl: null,
		metaLines,
		primaryAction: canOpen
			? {
					label: "Open material",
					url: material.accessUrl!.trim(),
					isExternal: true,
					newWindow: true,
				}
			: null,
		// Without an access URL the only useful next step is asking a human.
		secondaryAction: canOpen
			? null
			: {
					label: "Ask about access",
					url: ACCESS_HELP_MAILTO,
					isExternal: true,
				},
	}
}

/** Maps one catalogue entry into everything a card or row renders. */
export function buildCatalogueItemPresentation(
	item: CatalogueItem,
): StudyItemPresentation {
	const metaLines: MetaLine[] = []
	const price = item.costNote?.trim()
	if (price) metaLines.push({ icon: "price", text: price })

	const download = item.isDownload ? item.downloadUrl?.trim() : null
	const purchase = item.purchaseUrl?.trim()

	const primaryAction: StudyItemLink | null = download
		? {
				label: "Download now",
				url: download,
				isExternal: true,
				newWindow: true,
			}
		: purchase
			? { label: "Purchase", url: purchase, isExternal: true, newWindow: true }
			: null

	return {
		id: item.id,
		variant: "catalogue",
		title: item.title?.trim() || "Study material",
		programKey: item.programKey,
		codeLabel: studyCodeLabel(item.programKey),
		typeLabel: item.materialType?.trim() || null,
		statusLabel: null,
		statusTone: null,
		paragraphs: item.paragraphs.filter((p) => p.trim().length > 0),
		imageUrl: item.imageUrl?.trim() || null,
		metaLines,
		primaryAction,
		secondaryAction: null,
	}
}
