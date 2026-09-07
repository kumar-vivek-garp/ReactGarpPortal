/**
 * Typed fixtures for the study-materials contract (`api/study-materials/types.ts`)
 * — the Apex wire rows, one preset per card state, and the client model.
 * Typed against the api types so a contract drift breaks compilation.
 */

import type {
	ApexStudyMaterial,
	ApexStudyMaterialsInfo,
	ApexStudyMaterialsPayload,
	MyEBooksView,
	StudyMaterialItem,
} from "@/api/study-materials/types"

export function apexMaterial(
	overrides: Partial<ApexStudyMaterial> = {},
): ApexStudyMaterial {
	return {
		title: "2026 SCR Book",
		productCode: "SCRH",
		materialType: "Book",
		shortDescription: "Printed book",
		imageURL: null,
		isOwned: false,
		wasOrderedWithReg: false,
		registrationDate: null,
		orderedDate: null,
		orderId: null,
		isUnPaidOrder: false,
		isComingSoon: false,
		comingSoonDate: null,
		leadGenURL: null,
		downloadURL: null,
		eBook: null,
		canPurchase: false,
		isOutOfStock: false,
		price: null,
		GARPLearningAccessURL: null,
		hasGARPLearningAddOn: false,
		accessUrl: null,
		accountingId: null,
		relatedPart: null,
		...overrides,
	}
}

/** Bought with a registration — FRM Part 1 eBooks, two vendor titles. */
export function ownedWithReg(
	overrides: Partial<ApexStudyMaterial> = {},
): ApexStudyMaterial {
	return apexMaterial({
		title: "2026 FRM Exam Part I eBooks",
		productCode: "FRM1H",
		materialType: "eBook",
		shortDescription: "<p>Four digital books&nbsp;covering Part I.</p>",
		isOwned: true,
		wasOrderedWithReg: true,
		registrationDate: "2026-02-11",
		orderId: "006REG00000000001",
		relatedPart: "Part 1",
		eBook: {
			year: 2026,
			title: "FRM Exam Part I eBooks",
			provider: "Pearson",
			key: "PRV-FRM1-2026",
			keyStatus: "Active",
			// Far-future so the meta line never counts down in CI.
			expireDate: "2030-12-31",
			eBookItems: [
				{ title: "Part I", vendorId: 111 },
				{ title: "Part II", vendorId: 222 },
			],
		},
		...overrides,
	})
}

/** Bought on its own — a printed book with an order date. */
export function ownedPurchased(
	overrides: Partial<ApexStudyMaterial> = {},
): ApexStudyMaterial {
	return apexMaterial({
		isOwned: true,
		orderedDate: "2026-03-05",
		orderId: "006BUY00000000001",
		...overrides,
	})
}

/** A New Lead order — bought but not yet paid for. */
export function unpaidOrder(
	overrides: Partial<ApexStudyMaterial> = {},
): ApexStudyMaterial {
	return apexMaterial({
		isUnPaidOrder: true,
		orderId: "006UNPAID00000001",
		canPurchase: true,
		price: 100,
		...overrides,
	})
}

/** Not yet published — a date, and somewhere to register interest. */
export function comingSoon(
	overrides: Partial<ApexStudyMaterial> = {},
): ApexStudyMaterial {
	return apexMaterial({
		title: "2027 Risk and AI Book",
		productCode: "RAIH27",
		isComingSoon: true,
		comingSoonDate: "2026-12-01",
		leadGenURL: "https://www.garp.org/rai/notify",
		price: 120,
		...overrides,
	})
}

export function outOfStock(
	overrides: Partial<ApexStudyMaterial> = {},
): ApexStudyMaterial {
	return apexMaterial({
		title: "FRR Handbook",
		productCode: "CBRHB",
		isOutOfStock: true,
		canPurchase: false,
		price: 80,
		...overrides,
	})
}

/** For sale today. */
export function purchasable(
	overrides: Partial<ApexStudyMaterial> = {},
): ApexStudyMaterial {
	return apexMaterial({
		title: "2026 FRM Exam Part II Books",
		productCode: "FRM2H",
		shortDescription: "Print copies of the Part II readings.",
		canPurchase: true,
		price: 295,
		relatedPart: "Part 2",
		...overrides,
	})
}

/** A free PDF. */
export function freeDownload(
	overrides: Partial<ApexStudyMaterial> = {},
): ApexStudyMaterial {
	return apexMaterial({
		title: "2026 SCR Study Guide",
		productCode: null,
		materialType: "Download",
		downloadURL: "https://www.garp.org/hubfs/scr-study-guide.pdf",
		...overrides,
	})
}

/**
 * The FRM Part I GARP Learning card, granted by an open sitting, with the
 * practice-exam add-on in the requested state.
 */
export function garpLearning(
	addOn: "purchasable" | "pending" | "owned" | null = "purchasable",
	overrides: Partial<ApexStudyMaterial> = {},
): ApexStudyMaterial {
	const addOnFields: Partial<ApexStudyMaterial> =
		addOn === null
			? { hasGARPLearningAddOn: false }
			: addOn === "owned"
				? {
						hasGARPLearningAddOn: true,
						isGARPLearningAddOnOwned: true,
						GARPLearningAddOnPurchasedDate: "2026-03-20",
						GARPLearningAddOnAccessHeading: "Add-On Content",
						GARPLearningAddOnAccessDescription:
							"Access your third full-length practice exam for the FRM Part I.",
					}
				: {
						hasGARPLearningAddOn: true,
						isGARPLearningAddOnOwned: false,
						GARPLearningAddOnPuchasePrice: 75,
						GARPLearningAddOnPuchaseProductCode: "FRM1BPPE",
						GARPLearningAddOnPuchaseHeading: "Upgrade for Additional Content",
						GARPLearningAddOnPuchaseDescription:
							"Looking for additional prep questions? Purchase a third full-length practice exam for the FRM Part I.",
						GARPLearningAddOnPuchasePendingOrder:
							addOn === "pending" ? "006ADDON0000000001" : null,
					}

	return apexMaterial({
		title: "2026 FRM Part I GARP Learning",
		productCode: "FRMBP",
		materialType: "GARP Learning",
		shortDescription:
			"Practice questions, full-length practice exams and progress tracking for FRM Exam Part I.",
		isOwned: true,
		wasOrderedWithReg: true,
		registrationDate: "2026-02-11",
		orderId: "006REG00000000001",
		GARPLearningAccessURL: "https://learning.garp.org/sso?prog=FRM&part=1",
		relatedPart: "Part 1",
		...addOnFields,
		...overrides,
	})
}

export function studyMaterialsPayload(
	info: ApexStudyMaterialsInfo,
): ApexStudyMaterialsPayload {
	return { statusMessage: "Success", statusCode: 200, studyMaterialsInfo: info }
}

/** `GARP_Portal_Access.verify` refused — no buckets at all. */
export function deniedStudyMaterials(statusCode = 403): ApexStudyMaterialsPayload {
	return {
		statusMessage: "Portal Access Denied",
		statusCode,
		studyMaterialsInfo: null,
	}
}

export function myEBooksEmpty(): MyEBooksView {
	return { statusMessage: null, statusCode: 200, eBooks: {} }
}

export function myEBooksWithKey(): MyEBooksView {
	return {
		statusMessage: null,
		statusCode: 200,
		eBooks: {
			"2026": [
				{
					title: "FRM",
					provider: "Pearson",
					eBookItems: [{ title: "Part I", vendorId: 111 }],
				},
			],
		},
	}
}

/** The client model, for the rules and the cards — nothing set unless asked. */
export function studyItem(
	overrides: Partial<StudyMaterialItem> = {},
): StudyMaterialItem {
	return {
		id: "FRM2H",
		programKey: "frm",
		title: "2026 FRM Exam Part II Books",
		typeLabel: "Book",
		description: null,
		imageUrl: null,
		relatedPart: null,
		productCode: "FRM2H",
		price: null,
		isOwned: false,
		wasOrderedWithReg: false,
		registrationDate: null,
		orderedDate: null,
		orderId: null,
		isUnPaidOrder: false,
		isComingSoon: false,
		comingSoonDate: null,
		leadGenUrl: null,
		downloadUrl: null,
		accessUrl: null,
		garpLearningAccessUrl: null,
		canPurchase: false,
		isOutOfStock: false,
		eBookSet: null,
		addOn: null,
		...overrides,
	}
}
