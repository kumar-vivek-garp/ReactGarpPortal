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
	/**
	 * The gate the members-only content paywall reads.
	 *
	 * Narrower than `isMember` and not derivable from it: a lapsed Individual
	 * still reports `isIndividualMember: true` and a membership type of
	 * "Individual", so only this field says whether they may actually be let
	 * through.
	 */
	isMemberInGoodStanding: boolean
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
	/** The whole street text area, as Salesforce stores it. */
	street: string | null
	/** The same street split into the three lines the address form edits. */
	street1: string | null
	street2: string | null
	street3: string | null
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

export type ProvinceOption = {
	name: string
	code: string | null
}

/**
 * One `Country_Code__c` row for the address form: the province list decides
 * whether State is a dropdown or free text; the flags say what is required.
 */
export type PortalCountryOption = {
	name: string
	code: string | null
	phoneCode: string | null
	postalCodeRequired: boolean
	provinceRequired: boolean
	provinces: ProvinceOption[]
}

export type AccountOptionsView = {
	picklists: Record<string, PicklistOption[]>
	chapters: ChapterOption[]
	/**
	 * `"United States (+1)"` and friends — the exact strings the org stores in
	 * `Contact.Mobile_Phone_Code__c`, so the phone-code select must offer them
	 * verbatim.
	 */
	mobilePhoneLocations: string[]
	countries: PortalCountryOption[]
	/** Typeahead lists for the career/survey school and company inputs. */
	schools: string[]
	organizations: string[]
	/** Year dropdowns the career/survey forms offer. */
	workingYears: string[]
	graduationYears: string[]
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

/**
 * `GARP_Portal_MembershipService.AutoRenewOnResult`. Switching on stores a
 * card and nothing more — no charge, no order — so the whole action is
 * following `setupUrl`.
 */
export type AutoRenewOnResult = {
	statusMessage: string | null
	statusCode: number | null
	/** Always true on the server: a card must be saved first. */
	needPaymentInfo: boolean
	/** The checkout.stripe.com page that stores the card. */
	setupUrl: string | null
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
		/** Billing phone (`Contact.Phone`). */
		phone: string | null
		/** Mailing phone (`Contact.HomePhone`). */
		homePhone: string | null
		mobilePhone: string | null
		mobilePhoneCode: string | null
		mailingCompany: string | null
		photoUrl: string | null
		/** An email change was requested but not yet confirmed by the member. */
		isAwaitingEmailChange: boolean | null
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
		smsPromotional: boolean | null
		smsRegistration: boolean | null
	}
	mailingAddress: PortalAddress
	/** Lives on the Account, not the Contact. */
	billingAddress: PortalAddress
	otherAddress: PortalAddress
	/** Pre-ticks "same as billing" — Apex compares the five address fields. */
	isBillingAndMailingAddressSame: boolean
}

/** Envelope returned by GARP_Portal_API / memberportal Apex REST. */
export type MemberPortalEnvelope<T> = {
	status: string
	statusCode: number
	errorMessage: string | null
	warnings?: string[]
	data?: T
}
