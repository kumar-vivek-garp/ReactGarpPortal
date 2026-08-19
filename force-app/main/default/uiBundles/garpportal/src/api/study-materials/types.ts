import type { MemberPortalEnvelope } from "@/api/account/types"

/**
 * UI catalogue / entitlement models — built by `normalizeStudyMaterialsPayload`
 * from the Apex legacy-shaped response.
 */

export type StudyMaterial = {
	id: string
	/** Owning program bucket (`frm` / `scr` / `rai` / …) — drives brand + code chip. */
	programKey: string
	name: string | null
	type: string | null
	accessUrl: string | null
	status: string | null
	/** ISO date (yyyy-MM-dd) or null. */
	expirationDate: string | null
	isAvailable: boolean
	unavailableReason: string | null
	/** ISO datetime or null. */
	lastAccessed: string | null
	invoiceNumber: string | null
}

export type CatalogueItem = {
	id: string
	/** Owning program bucket (`frm` / `scr` / `rai` / …) — drives brand + code chip. */
	programKey: string
	title: string | null
	paragraphs: string[]
	imageUrl: string | null
	downloadUrl: string | null
	purchaseUrl: string | null
	costNote: string | null
	materialType: string | null
	isDownload: boolean
	sortOrder: number
}

export type StudyProgram = {
	key: string
	label: string
	materials: CatalogueItem[]
}

export type StudyMaterialsView = {
	programs: StudyProgram[]
	myEntitlements: StudyMaterial[]
}

/** Apex `GARP_Portal_StudyMaterialsService.EBook` (legacy field names). */
export type ApexStudyEBook = {
	year?: number | null
	title?: string | null
	key?: string | null
	keyStatus?: string | null
	expireDate?: string | null
	isAPI?: boolean | null
	type?: string | null
	part?: string | null
	productCode?: string | null
	accountingId?: string | null
}

/** Apex `GARP_Portal_StudyMaterialsService.StudyMaterial` (legacy field names). */
export type ApexStudyMaterial = {
	materialType?: string | null
	title?: string | null
	description?: string | null
	shortDescription?: string | null
	imageURL?: string | null
	displayOrder?: number | null
	isOwned?: boolean | null
	wasOrderedWithReg?: boolean | null
	registrationDate?: string | null
	wasPurchased?: boolean | null
	orderedDate?: string | null
	orderId?: string | null
	isUnPaidOrder?: boolean | null
	isComingSoon?: boolean | null
	comingSoonDate?: string | null
	leadGenURL?: string | null
	downloadURL?: string | null
	eBook?: ApexStudyEBook | null
	canPurchase?: boolean | null
	isOutOfStock?: boolean | null
	price?: number | null
	isPreOrder?: boolean | null
	GARPLearningAccessURL?: string | null
	accessUrl?: string | null
	isAvailable?: boolean | null
	isCompWithReg?: boolean | null
	isShippable?: boolean | null
	isElectronicDelivery?: boolean | null
	productId?: string | null
	productCode?: string | null
	accountingId?: string | null
	relatedPart?: string | null
	sortCode?: string | null
	selected?: boolean | null
}

export type ApexStudyMaterialsInfo = {
	frmStudyMaterials?: ApexStudyMaterial[] | null
	scrStudyMaterials?: ApexStudyMaterial[] | null
	raiStudyMaterials?: ApexStudyMaterial[] | null
	raijStudyMaterials?: ApexStudyMaterial[] | null
	frrStudyMaterials?: ApexStudyMaterial[] | null
}

/** Envelope `data` from `GET /memberportal/studyMaterials`. */
export type ApexStudyMaterialsPayload = {
	statusMessage?: string | null
	statusCode?: number | null
	studyMaterialsInfo?: ApexStudyMaterialsInfo | null
}

export type { MemberPortalEnvelope }
