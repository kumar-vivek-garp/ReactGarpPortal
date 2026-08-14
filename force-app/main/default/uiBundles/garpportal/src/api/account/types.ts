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

export type AccountView = {
	identity: Identity
	completeness: Completeness
	personal: {
		firstName: string | null
		lastName: string | null
		email: string | null
		phone: string | null
		photoUrl: string | null
	}
	career: {
		company: string | null
		corporateTitle: string | null
		jobFunction: string | null
		companyCity: string | null
		companyCountry: string | null
		industryWorkingYear: string | null
	}
	academic: {
		highestDegree: string | null
		schoolName: string | null
		degreeProgramName: string | null
		currentlyInSchool: boolean | null
	}
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
