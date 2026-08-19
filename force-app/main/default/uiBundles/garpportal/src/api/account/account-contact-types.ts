/**
 * GraphQL Contact payload for My Account Information (not completeness).
 * Completeness scoring stays on REST `GET /memberportal/account`.
 */

export type AccountContactAddress = {
	street: string | null
	city: string | null
	state: string | null
	postalCode: string | null
	country: string | null
}

export type AccountContact = {
	contactId: string
	firstName: string | null
	lastName: string | null
	fullName: string | null
	email: string | null
	garpId: string | null
	photoUrl: string | null
	phone: string | null
	membershipType: string | null
	membershipStatus: string | null
	membershipExpiration: string | null
	memberSince: string | null
	autoRenew: boolean
	career: {
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
	academic: {
		highestDegree: string | null
		schoolName: string | null
		degreeProgramName: string | null
		currentlyInSchool: boolean | null
		expectedGraduationDate: string | null
		expectedGraduationMonth: string | null
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
	mailing: AccountContactAddress
	/** Account billing address (nested `Contact.Account`). */
	billing: AccountContactAddress
	other: AccountContactAddress
}
