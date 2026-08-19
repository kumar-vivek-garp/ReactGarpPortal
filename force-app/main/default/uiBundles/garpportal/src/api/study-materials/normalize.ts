import type {
	ApexStudyMaterial,
	ApexStudyMaterialsPayload,
	CatalogueItem,
	StudyMaterial,
	StudyMaterialsView,
	StudyProgram,
} from "@/api/study-materials/types"

const PROGRAM_BUCKETS: Array<{
	key: string
	label: string
	field: keyof NonNullable<ApexStudyMaterialsPayload["studyMaterialsInfo"]>
}> = [
	{ key: "frm", label: "FRM", field: "frmStudyMaterials" },
	{ key: "scr", label: "SCR", field: "scrStudyMaterials" },
	{ key: "rai", label: "RAI", field: "raiStudyMaterials" },
	{ key: "raij", label: "RAIJ", field: "raijStudyMaterials" },
	{ key: "frr", label: "FRR", field: "frrStudyMaterials" },
]

function asList(value: ApexStudyMaterial[] | null | undefined): ApexStudyMaterial[] {
	return Array.isArray(value) ? value : []
}

function stripHtml(value: string | null | undefined): string {
	if (!value?.trim()) return ""
	return value
		.replace(/<[^>]+>/g, " ")
		.replace(/&nbsp;/gi, " ")
		.replace(/\s+/g, " ")
		.trim()
}

function materialId(raw: ApexStudyMaterial, programKey: string, index: number): string {
	return (
		raw.productCode?.trim() ||
		raw.productId?.trim() ||
		raw.eBook?.key?.trim() ||
		`${programKey}-${index}-${raw.title?.trim() || "item"}`
	)
}

function sortValue(raw: ApexStudyMaterial, index: number): number {
	if (typeof raw.displayOrder === "number") return raw.displayOrder
	// Preserve Apex list order; sortCode is a catalogue hint, not a global rank.
	return index
}

function costNote(raw: ApexStudyMaterial): string | null {
	if (raw.isCompWithReg) return "Included with registration"
	if (typeof raw.price !== "number") return null
	if (raw.price === 0) return "Complimentary"
	return `$${raw.price.toFixed(raw.price % 1 === 0 ? 0 : 2)}`
}

function toCatalogueItem(
	raw: ApexStudyMaterial,
	programKey: string,
	index: number,
): CatalogueItem {
	const short = stripHtml(raw.shortDescription)
	const long = stripHtml(raw.description)
	const paragraphs = [short || long].filter(Boolean)
	const downloadUrl = raw.downloadURL?.trim() || null
	const materialType = raw.materialType?.trim() || null
	const isDownload =
		Boolean(downloadUrl) ||
		materialType?.toLowerCase() === "download"

	return {
		id: materialId(raw, programKey, index),
		programKey,
		title: raw.title?.trim() || null,
		paragraphs,
		imageUrl: raw.imageURL?.trim() || null,
		downloadUrl,
		purchaseUrl: raw.leadGenURL?.trim() || null,
		costNote: costNote(raw),
		materialType,
		isDownload,
		sortOrder: sortValue(raw, index),
	}
}

function unavailableReason(raw: ApexStudyMaterial): string | null {
	if (raw.isComingSoon) return "Coming soon"
	if (raw.isOutOfStock) return "Out of stock"
	if (raw.isUnPaidOrder) return "Payment pending"
	if (raw.isAvailable === false) return "Not available"
	return null
}

function toEntitlement(
	raw: ApexStudyMaterial,
	programKey: string,
	index: number,
): StudyMaterial {
	const accessUrl =
		raw.GARPLearningAccessURL?.trim() ||
		raw.accessUrl?.trim() ||
		raw.downloadURL?.trim() ||
		null
	const expire = raw.eBook?.expireDate
	const expirationDate =
		typeof expire === "string" && expire.trim()
			? expire.trim().slice(0, 10)
			: null

	return {
		id: materialId(raw, programKey, index),
		programKey,
		name: raw.title?.trim() || null,
		type: raw.materialType?.trim() || null,
		accessUrl,
		status: raw.eBook?.keyStatus?.trim() || null,
		expirationDate,
		isAvailable: raw.isAvailable !== false && !raw.isComingSoon,
		unavailableReason: unavailableReason(raw),
		lastAccessed: null,
		invoiceNumber: null,
	}
}

/**
 * Maps Apex legacy `studyMaterialsInfo` buckets into the React panel model.
 */
export function normalizeStudyMaterialsPayload(
	payload: ApexStudyMaterialsPayload | null | undefined,
): StudyMaterialsView {
	const info = payload?.studyMaterialsInfo
	const programs: StudyProgram[] = []
	const entitlements: StudyMaterial[] = []
	const seenEntitlementIds = new Set<string>()

	for (const bucket of PROGRAM_BUCKETS) {
		const rows = asList(info?.[bucket.field] as ApexStudyMaterial[] | null)
		if (rows.length === 0) continue

		const materials = rows
			.map((row, index) => toCatalogueItem(row, bucket.key, index))
			.sort((a, b) => a.sortOrder - b.sortOrder)

		programs.push({
			key: bucket.key,
			label: bucket.label,
			materials,
		})

		rows.forEach((row, index) => {
			if (!row.isOwned) return
			const entitlement = toEntitlement(row, bucket.key, index)
			if (seenEntitlementIds.has(entitlement.id)) return
			seenEntitlementIds.add(entitlement.id)
			entitlements.push(entitlement)
		})
	}

	return { programs, myEntitlements: entitlements }
}
