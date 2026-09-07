import type { MemberPortalEnvelope } from "@/api/account/types"

/**
 * Study materials — the client model built by `normalizeStudyMaterial` from
 * the legacy-shaped `GARP_Portal_StudyMaterialsService` payload, plus the
 * wire types themselves.
 */

/** The five Apex buckets, in the legacy's order. */
export type StudyProgramKey = "frm" | "scr" | "rai" | "raij" | "frr"

/** One openable title inside an eBook key. */
export type EBookTitle = {
	/** Stable within a group — vendor id when present, else the composed label. */
	id: string
	label: string
	/** Null when the key resolved to no vendor item; the row is then unopenable. */
	vendorId: string | null
	provider: string | null
}

/** The eBook key attached to a material, with the titles it unlocks. */
export type StudyEBookSet = {
	titles: EBookTitle[]
	/** ISO date (yyyy-MM-dd) or null. */
	expireDate: string | null
}

/**
 * The FRM Part I practice-exam upgrade Apex attaches to the GARP Learning
 * card — never a row of its own. Which shape arrives is Apex's call.
 */
export type GarpLearningAddOn =
	| {
			kind: "purchasable"
			heading: string
			description: string
			price: number | null
			productCode: string | null
			/** An unpaid order for the add-on already exists (Opportunity Id). */
			pendingOrderId: string | null
	  }
	| {
			kind: "owned"
			heading: string
			description: string
			/** ISO date (yyyy-MM-dd) or null. */
			purchasedDate: string | null
	  }

/**
 * One material, carrying every flag the per-card decision chain reads. The
 * flags are Apex's answers; which one wins is `resolveMaterialAction`'s.
 */
export type StudyMaterialItem = {
	id: string
	/** Owning program bucket — drives brand tint, code chip and errata link. */
	programKey: StudyProgramKey
	title: string
	/** "Download" | "Book" | "eBook" | "GARP Learning" — read off the title by Apex. */
	typeLabel: string | null
	/** HTML-stripped `shortDescription`. */
	description: string | null
	imageUrl: string | null
	/** "Part 1" / "Part 2" — FRM only, null everywhere else. */
	relatedPart: string | null
	productCode: string | null
	price: number | null

	isOwned: boolean
	wasOrderedWithReg: boolean
	/** ISO dates (yyyy-MM-dd) or null. */
	registrationDate: string | null
	orderedDate: string | null
	/** The Opportunity behind an owned or unpaid order. */
	orderId: string | null
	isUnPaidOrder: boolean

	isComingSoon: boolean
	comingSoonDate: string | null
	/** "Notify me" — set by Apex on coming-soon items only. Never a purchase link. */
	leadGenUrl: string | null

	downloadUrl: string | null
	accessUrl: string | null
	/** Granted from an open sitting or active contract, independently of orders. */
	garpLearningAccessUrl: string | null

	canPurchase: boolean
	isOutOfStock: boolean

	eBookSet: StudyEBookSet | null
	addOn: GarpLearningAddOn | null
}

export type StudyProgram = {
	key: StudyProgramKey
	label: string
	items: StudyMaterialItem[]
}

/**
 * What `fetchStudyMaterials` resolves. A member with no membership contract is
 * refused with `Portal Access Denied` — a business answer the page renders,
 * not a failure to toast.
 */
export type StudyMaterialsView =
	| { kind: "ok"; programs: StudyProgram[] }
	| { kind: "denied"; statusCode: number; message: string | null }

// ---------------------------------------------------------------------------
// Wire types — `GARP_Portal_StudyMaterialsService` (legacy field names)
// ---------------------------------------------------------------------------

/** One vendor item inside an eBook key — what actually opens in the reader. */
export type ApexEBookItem = {
	title?: string | null
	/** The vendor (Mobius) product id `eBookAccess` exchanges for a link. */
	vendorId?: number | null
}

/** Apex `GARP_Portal_StudyMaterialsService.EBook`. */
export type ApexStudyEBook = {
	year?: number | null
	title?: string | null
	provider?: string | null
	productCode?: string | null
	accountingId?: string | null
	eBookItems?: ApexEBookItem[] | null
	key?: string | null
	keyStatus?: string | null
	expireDate?: string | null
	isAPI?: boolean | null
	type?: string | null
	part?: string | null
}

/** The archive (`myEBooks`) rows are the same Apex class. */
export type ApexArchiveEBook = ApexStudyEBook

/**
 * Apex `GARP_Portal_StudyMaterialsService.StudyMaterial`.
 *
 * Trimmed on 2026-08-18 to what the service actually sends: `description`,
 * `displayOrder`, `wasPurchased`, `isPreOrder`, `year`, `isAvailable`,
 * `isCompWithReg`, `isShippable`, `isElectronicDelivery`, `productId`,
 * `glCode`, `sortCode` and `selected` no longer travel and must not be read.
 */
export type ApexStudyMaterial = {
	materialType?: string | null
	title?: string | null
	shortDescription?: string | null
	imageURL?: string | null

	isOwned?: boolean | null
	wasOrderedWithReg?: boolean | null
	registrationDate?: string | null
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

	GARPLearningAccessURL?: string | null
	hasGARPLearningAddOn?: boolean | null
	GARPLearningAddOnPuchasePrice?: number | null
	GARPLearningAddOnPuchaseProductCode?: string | null
	GARPLearningAddOnPuchaseHeading?: string | null
	GARPLearningAddOnPuchaseDescription?: string | null
	isGARPLearningAddOnOwned?: boolean | null
	GARPLearningAddOnPurchasedDate?: string | null
	GARPLearningAddOnAccessHeading?: string | null
	GARPLearningAddOnAccessDescription?: string | null
	/** The pending add-on order's Opportunity Id, when one is at New Lead. */
	GARPLearningAddOnPuchasePendingOrder?: string | null

	accessUrl?: string | null
	productCode?: string | null
	accountingId?: string | null
	relatedPart?: string | null
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

/** `GET eBookAccess?vendorId=` — one short-lived signed reader link. */
export type EBookAccess = {
	statusMessage: string | null
	statusCode: number
	accessURL: string | null
}

// ---------------------------------------------------------------------------
// Buying one material — `GARP_Portal_MaterialPurchase`
// ---------------------------------------------------------------------------

/** Apex `GARP_Portal_MaterialPurchase.Address`. `country` is the NAME, not a code. */
export type MaterialShipTo = {
	company: string | null
	street: string | null
	street2: string | null
	city: string | null
	state: string | null
	postalCode: string | null
	country: string | null
	phone: string | null
}

/** `GET materialQuote?productCode=` — envelope `data`. */
export type MaterialQuote = {
	statusMessage: string | null
	statusCode: number
	productCode: string | null
	title: string | null
	imageURL: string | null
	price: number | null
	/** Null when no per-country charge is known — "Calculated at checkout". */
	shipping: number | null
	total: number | null
	/** A printed book — an address is needed before it can be posted. */
	isShippable: boolean
	/** Pre-filled from the member's record; null when the record has none. */
	shipTo: MaterialShipTo | null
	/** Country NAMES GARP will post to. Advisory — the server does not enforce it. */
	shippableCountries: string[]
}

export type MaterialPurchaseRequest = {
	productCode: string
	shipTo: MaterialShipTo
}

/**
 * `POST materialPurchase`. Exactly one of `orderId` / `stagedId` is set on
 * success, depending on the org's deferred-order switch — the client never
 * reads the switch, it takes whichever id came back.
 */
export type MaterialPurchaseResult = {
	statusMessage: string | null
	statusCode: number
	/** Deferred flow OFF — the Opportunity to take to checkout. */
	orderId: string | null
	orderNumber: string | null
	/** Deferred flow ON — the staged Order_History__c row to take to checkout. */
	stagedId: string | null
	registrationRef: string | null
	total: number | null
}
