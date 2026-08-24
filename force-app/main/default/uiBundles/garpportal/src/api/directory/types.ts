import type { MemberPortalEnvelope } from "@/api/account/types"

/**
 * Types mirroring `GARP_Portal_DirectoryService`.
 *
 * Directory rows are OTHER members' Contacts, which a community user cannot
 * read — the service queries them in system mode and redacts each row against
 * that member's own privacy switches before returning it. So there is no
 * GraphQL equivalent of this: what comes back is already filtered by both the
 * subject's choices and the viewer's entitlement.
 */

/** The viewer's own directory settings. */
export type DirectorySettings = {
	isOptedIn: boolean | null
	showAdditionalDetails: boolean | null
	showJobInformation: boolean | null
	showProfessionalBackground: boolean | null
	isDirectoryConnectEnabled: boolean | null
}

/** The viewer's own entry, as other members would see it. */
export type DirectoryPreview = {
	memberName: string | null
	city: string | null
	state: string | null
	country: string | null
	jobFunction: string | null
	areaOfConcentration: string | null
	riskSpecialty: string | null
	professionalLevel: string | null
	company: string | null
}

/**
 * `GET directory` — what the viewer is allowed to do.
 *
 * The six access flags are independent: a member can reach the directory and
 * still not have advanced search, messaging, or the right to see non-certified
 * members. Never infer one from another.
 */
export type DirectoryView = {
	statusMessage: string | null
	statusCode: number
	settings: DirectorySettings | null
	preview: DirectoryPreview | null
	hasDirectoryAccess: boolean
	hasDirectoryCPDAccess: boolean
	hasDirectoryConnectAccess: boolean
	hasDirectoryAdvancedSearchAccess: boolean
	hasDirectoryNonCertifiedAccess: boolean
	hasDirectorySettingsAccess: boolean
	/**
	 * `null` for a member in good standing, `"Renew"` for a lapsed Individual,
	 * `"Upgrade"` for everyone else. Decides the call to action beside the
	 * advanced-search panel.
	 */
	upsellMembershipType: string | null
	/** An unpaid membership order, so the upsell can link to it instead. */
	pendingMembershipOrderId: string | null
}

/** One directory row, already redacted for this viewer. */
export type DirectoryMember = {
	id: string | null
	garpId: string | null
	name: string | null
	firstName: string | null
	lastName: string | null
	mailingCity: string | null
	mailingCountry: string | null
	photoUrl: string | null
	membershipType: string | null
	membershipSince: string | null
	isFRMCertified: boolean | null
	frmCertifiedDate: string | null
	isERPCertified: boolean | null
	erpCertifiedDate: string | null
	isSCRHolder: boolean | null
	scrCompletionDate: string | null
	isRAIHolder: boolean | null
	raiCompletionDate: string | null
	cpeRequirementStatus: string | null
	cpeCurrentCycle: string | null
	cpeLastCompletedCycle: string | null
	jobFunction: string | null
	riskSpecialty: string | null
	areaOfConcentration: string | null
	corporateTitle: string | null
	company: string | null
	designations: string[] | null
	otherQualifications: string | null
	/** Per-row, decided by the subject's settings AND the viewer's standing. */
	canSendMessage: boolean | null
	canInvite: boolean | null
}

/**
 * `POST directorySearch` body.
 *
 * `sortField` is checked against a whitelist server-side and `pageSize` is
 * clamped to 50 — the legacy interpolated both straight into SOQL. `skipOptIn`
 * exists on the wire but is ignored for members, so it is not modelled here.
 */
export type DirectorySearchParams = {
	searchText?: string | null
	FRMOnly?: boolean
	ERPOnly?: boolean
	SCROnly?: boolean
	RAIOnly?: boolean
	/** `Area_of_Concentration__c` — labelled "Industries" on the form. */
	industries?: string[]
	jobFunctions?: string[]
	riskSpecialties?: string[]
	/** `Corporate_Title__c` — labelled "Professional Level". */
	corporateTitles?: string[]
	company?: string | null
	sortField?: string
	sortOrder?: "ASC" | "DESC"
	pageSize?: number
	pageCurrent?: number
}

export type DirectorySearchResults = {
	statusMessage: string | null
	statusCode: number
	members: DirectoryMember[]
	pages: number
	total: number
	pageCurrent: number
	pageSize: number
}

/** The two message types Apex accepts; anything else is refused. */
export type DirectoryMessageType =
	| "Directory_Connect"
	| "Directory_Connect_Invite"

export type DirectoryMessageInput = {
	recipientContactId: string
	messageType: DirectoryMessageType
	message: string
}

export type DirectoryMessageResult = {
	statusMessage: string | null
	statusCode: number
}

export type { MemberPortalEnvelope }
