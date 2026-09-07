import type {
	ApexStudyMaterial,
	ApexStudyMaterialsInfo,
	ApexStudyMaterialsPayload,
	GarpLearningAddOn,
	StudyEBookSet,
	StudyMaterialItem,
	StudyProgram,
	StudyProgramKey,
} from "@/api/study-materials/types"

/**
 * Program filter pills — labels match MyGarp study-materials
 * `programFilterOptions` (full names). Keys stay the Apex bucket codes, and
 * the order is the legacy's.
 */
const PROGRAM_BUCKETS: Array<{
	key: StudyProgramKey
	label: string
	field: keyof ApexStudyMaterialsInfo
}> = [
	{ key: "frm", label: "Financial Risk Manager", field: "frmStudyMaterials" },
	{
		key: "scr",
		label: "Sustainability & Climate Risk",
		field: "scrStudyMaterials",
	},
	{ key: "rai", label: "Risk & AI", field: "raiStudyMaterials" },
	{
		key: "raij",
		label: "Risk and AI (Japanese)",
		field: "raijStudyMaterials",
	},
	{
		key: "frr",
		label: "Financial Risk and Regulation",
		field: "frrStudyMaterials",
	},
]

function asList(value: ApexStudyMaterial[] | null | undefined): ApexStudyMaterial[] {
	return Array.isArray(value) ? value : []
}

/** Apex copy arrives as HTML fragments; the cards render plain text. */
export function stripHtml(value: string | null | undefined): string {
	if (!value?.trim()) return ""
	return value
		.replace(/<[^>]+>/g, " ")
		.replace(/&nbsp;/gi, " ")
		.replace(/\s+/g, " ")
		.trim()
}

function text(value: string | null | undefined): string | null {
	const trimmed = value?.trim()
	return trimmed ? trimmed : null
}

/** Apex dates may arrive as datetimes; the cards only ever show the day. */
function isoDate(value: string | null | undefined): string | null {
	const trimmed = value?.trim()
	return trimmed ? trimmed.slice(0, 10) : null
}

function materialId(raw: ApexStudyMaterial, programKey: string, index: number): string {
	return (
		raw.productCode?.trim() ||
		raw.eBook?.key?.trim() ||
		`${programKey}-${index}-${raw.title?.trim() || "item"}`
	)
}

/**
 * `relatedPart` is a real null from the service's own FRM map, but the value
 * can also come from admin-edited programme config, which in the legacy
 * carried the literal four-character string "null". Guarded here so a card
 * can never be filed under a part called "null".
 */
function relatedPart(raw: ApexStudyMaterial): string | null {
	const value = text(raw.relatedPart)
	if (!value || value.toLowerCase() === "null") return null
	return value
}

function eBookSet(raw: ApexStudyMaterial): StudyEBookSet | null {
	const book = raw.eBook
	const items = Array.isArray(book?.eBookItems) ? book.eBookItems : []
	if (items.length === 0) return null

	const provider = text(book?.provider)
	return {
		expireDate: isoDate(book?.expireDate),
		titles: items.map((item, index) => {
			const vendorId =
				item.vendorId == null ? null : String(item.vendorId).trim() || null
			const label = text(item.title) ?? text(book?.title) ?? "eBook"
			return {
				id: vendorId ?? `${label}-${index}`,
				label,
				vendorId,
				provider,
			}
		}),
	}
}

function addOn(raw: ApexStudyMaterial): GarpLearningAddOn | null {
	if (raw.hasGARPLearningAddOn !== true) return null

	if (raw.isGARPLearningAddOnOwned === true) {
		return {
			kind: "owned",
			heading: text(raw.GARPLearningAddOnAccessHeading) ?? "Add-On Content",
			description: text(raw.GARPLearningAddOnAccessDescription) ?? "",
			purchasedDate: isoDate(raw.GARPLearningAddOnPurchasedDate),
		}
	}

	return {
		kind: "purchasable",
		heading:
			text(raw.GARPLearningAddOnPuchaseHeading) ??
			"Upgrade for Additional Content",
		description: text(raw.GARPLearningAddOnPuchaseDescription) ?? "",
		price:
			typeof raw.GARPLearningAddOnPuchasePrice === "number"
				? raw.GARPLearningAddOnPuchasePrice
				: null,
		productCode: text(raw.GARPLearningAddOnPuchaseProductCode),
		pendingOrderId: text(raw.GARPLearningAddOnPuchasePendingOrder),
	}
}

/** One Apex row into the client model. Every flag is carried; none is decided here. */
export function normalizeStudyMaterial(
	raw: ApexStudyMaterial,
	programKey: StudyProgramKey,
	index: number,
): StudyMaterialItem {
	return {
		id: materialId(raw, programKey, index),
		programKey,
		title: text(raw.title) ?? "Study material",
		typeLabel: text(raw.materialType),
		description: stripHtml(raw.shortDescription) || null,
		imageUrl: text(raw.imageURL),
		relatedPart: relatedPart(raw),
		productCode: text(raw.productCode),
		price: typeof raw.price === "number" ? raw.price : null,

		isOwned: raw.isOwned === true,
		wasOrderedWithReg: raw.wasOrderedWithReg === true,
		registrationDate: isoDate(raw.registrationDate),
		orderedDate: isoDate(raw.orderedDate),
		orderId: text(raw.orderId),
		isUnPaidOrder: raw.isUnPaidOrder === true,

		isComingSoon: raw.isComingSoon === true,
		comingSoonDate: isoDate(raw.comingSoonDate),
		leadGenUrl: text(raw.leadGenURL),

		downloadUrl: text(raw.downloadURL),
		accessUrl: text(raw.accessUrl),
		garpLearningAccessUrl: text(raw.GARPLearningAccessURL),

		canPurchase: raw.canPurchase === true,
		isOutOfStock: raw.isOutOfStock === true,

		eBookSet: eBookSet(raw),
		addOn: addOn(raw),
	}
}

/**
 * Maps the legacy `studyMaterialsInfo` buckets into programs. Only programs
 * with something in them come back — an empty bucket earns no tab. Apex list
 * order is preserved; the service already sorts.
 */
export function normalizeStudyMaterialsPayload(
	payload: ApexStudyMaterialsPayload | null | undefined,
): StudyProgram[] {
	const info = payload?.studyMaterialsInfo
	const programs: StudyProgram[] = []

	for (const bucket of PROGRAM_BUCKETS) {
		const rows = asList(info?.[bucket.field])
		if (rows.length === 0) continue

		programs.push({
			key: bucket.key,
			label: bucket.label,
			items: rows.map((row, index) =>
				normalizeStudyMaterial(row, bucket.key, index),
			),
		})
	}

	return programs
}
