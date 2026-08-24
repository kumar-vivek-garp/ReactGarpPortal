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

/** One vendor item inside an eBook key — what actually opens in the reader. */
export type ApexEBookItem = {
	title?: string | null
	/** The vendor (Mobius) product id `eBookAccess` exchanges for a link. */
	vendorId?: number | null
}

/**
 * `GET myEBooks` — the purchased-materials archive.
 *
 * `eBooks` is a MAP keyed by edition year, not a list: Apex builds
 * `Map<Integer, List<EBook>>`, so the JSON keys are year strings and carry no
 * order of their own.
 */
export type MyEBooksView = {
	statusMessage: string | null
	statusCode: number
	eBooks: Record<string, ApexArchiveEBook[]>
}

/** An owned eBook key, with the vendor items it resolved to. */
export type ApexArchiveEBook = ApexStudyEBook & {
	provider?: string | null
	eBookItems?: ApexEBookItem[] | null
}

/** `GET eBookAccess?vendorId=` — one short-lived signed reader link. */
export type EBookAccess = {
	statusMessage: string | null
	statusCode: number
	accessURL: string | null
}
