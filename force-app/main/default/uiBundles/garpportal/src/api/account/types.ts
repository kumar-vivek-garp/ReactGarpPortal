/**
 * Types mirroring GARP_MemberPortal_Service AccountView / Identity / Completeness / Address.
 */

export type Audience = "All" | "Individual" | "Affiliate" | "NonMember"

export type Identity = {
	contactId: string
	firstName: string | null
	lastName: string | null
	fullName: string | null
	email: string | null
	garpId: string | null
	membershipType: string | null
	membershipStatus: string | null
	/** ISO date (yyyy-MM-dd) or null. */
	membershipExpiration: string | null
	memberSince: string | null
	autoRenew: boolean
	isMember: boolean
	isIndividualMember: boolean
	isAffiliateMember: boolean
	audience: Audience
	photoUrl: string | null
}

export type Completeness = {
	percentComplete: number
	earnedWeight: number
	totalWeight: number
	isComplete: boolean
	muted: boolean
	missing: string[]
	missingBySection: Record<string, number>
}

export type PortalAddress = {
	street: string | null
	city: string | null
	state: string | null
	postalCode: string | null
	country: string | null
	isEmpty: boolean
}

export type AccountDesignations = {
	ACCA: boolean | null
	CA: boolean | null
	CAIA: boolean | null
	CFA: boolean | null
	CFP: boolean | null
	CIA: boolean | null
	CMA: boolean | null
	CMT: boolean | null
	CPA: boolean | null
	CQF: boolean | null
	PMP: boolean | null
	Other: boolean | null
	otherQualifications: string | null
}

export type AccountCareer = {
	currentlyWorkingStatus: string | null
	company: string | null
	corporateTitle: string | null
	jobFunction: string | null
	areaOfConcentration: string | null
	companyCity: string | null
	companyCountry: string | null
	industryWorkingYear: string | null
	riskManagementWorkingYear: string | null
}

export type AccountAcademic = {
	highestDegree: string | null
	schoolName: string | null
	degreeProgramName: string | null
	currentlyInSchool: boolean | null
	expectedGraduationDate: string | null
	expectedGraduationMonth: string | null
}

export type PicklistOption = {
	label: string
	value: string
}

export type ChapterOption = {
	id: string
	name: string
	region: string | null
}

export type AccountOptionsView = {
	picklists: Record<string, PicklistOption[]>
	chapters: ChapterOption[]
}

export type SaveAccountProfileResult = {
	applied: string[]
	rejected: string[]
	completeness: Completeness
}

/**
 * Contract-derived membership block from `GARP_Portal_Core.Standing`.
 * Null when the account has no Membership contract.
 */
export type AccountStanding = {
	garpId: string | null
	memberType: string | null
	/** Verbatim contract status, e.g. "Activated ( Auto-Renew )". */
	memberStatus: string | null
	/** Active when status contains Activated; otherwise Lapsed. */
	statusLabel: string | null
	dateJoined: string | null
	expirationDate: string | null
	isAutoRenewEnabled: boolean
	isCertHolder: boolean
	pendingOrderId: string | null
	pendingOrderNumber: string | null
	pendingOrderAmount: number | null
}

export type AutoRenewOffResult = {
	statusMessage: string | null
	statusCode: number | null
}

export type AutoRenewOnResult = {
	statusMessage: string | null
	statusCode: number | null
	needPaymentInfo: boolean
	/** Opportunity Id for Stripe setup; may be absent on the payload. */
	orderId?: string | null
}

export type AccountView = {
	identity: Identity
	completeness: Completeness
	/** Null / omitted when there is no Membership contract. */
	standing?: AccountStanding | null
	personal: {
		firstName: string | null
		lastName: string | null
		email: string | null
		phone: string | null
		photoUrl: string | null
	}
	designations: AccountDesignations
	career: AccountCareer
	academic: AccountAcademic
	expertise: {
		riskSpecialty: string | null
		topicsOrExpertise: string | null
	}
	directory: {
		optedIn: boolean | null
		connectFeature: boolean | null
		showJobInformation: boolean | null
		showProfessionalBackground: boolean | null
		showAdditionalDetail: boolean | null
	}
	chapters: {
		primary: string | null
		secondary: string | null
	}
	preferences: {
		garpUpdates: boolean | null
		chapterMeetings: boolean | null
		careerCenter: boolean | null
		memberUpdates: boolean | null
	}
	mailingAddress: PortalAddress
	billingAddress: PortalAddress
	otherAddress: PortalAddress
}

/** Envelope returned by GARP_Portal_API / memberportal Apex REST. */
export type MemberPortalEnvelope<T> = {
	status: string
	statusCode: number
	errorMessage: string | null
	warnings?: string[]
	data?: T
}
