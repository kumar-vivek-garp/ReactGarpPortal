import type { MemberPortalEnvelope } from "@/api/account/types"

/**
 * Types mirroring GARP_MemberPortal_Programs StudyMaterialsView DTOs.
 */

export type StudyMaterial = {
	id: string
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

export type { MemberPortalEnvelope }
