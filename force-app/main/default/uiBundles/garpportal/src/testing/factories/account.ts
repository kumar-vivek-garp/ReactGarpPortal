import type {
	AccountStanding,
	AccountView,
	Completeness,
	PortalAddress,
} from "@/api/account/types"

/**
 * `GARP_MemberPortal_Service` AccountView fixtures. Defaults model a signed-in
 * contact with NO Membership contract (`standing: null`) and a complete
 * profile — tests override the one block under test.
 */

export function emptyPortalAddress(): PortalAddress {
	return {
		street: null,
		city: null,
		state: null,
		postalCode: null,
		country: null,
		isEmpty: true,
	}
}

export function completeness(overrides: Partial<Completeness> = {}): Completeness {
	return {
		percentComplete: 100,
		earnedWeight: 11,
		totalWeight: 11,
		isComplete: true,
		muted: false,
		missing: [],
		missingBySection: {},
		...overrides,
	}
}

export function accountStanding(
	overrides: Partial<AccountStanding> = {},
): AccountStanding {
	return {
		garpId: "G-STANDING",
		memberType: "Individual",
		memberStatus: "Activated ( Auto-Renew )",
		statusLabel: "Active",
		dateJoined: "2020-03-01",
		expirationDate: "2027-03-01",
		isAutoRenewEnabled: false,
		isCertHolder: false,
		pendingOrderId: null,
		pendingOrderNumber: null,
		pendingOrderAmount: null,
		...overrides,
	}
}

type AccountViewOverrides = {
	identity?: Partial<AccountView["identity"]>
	completeness?: Partial<Completeness>
	standing?: AccountStanding | null
	personal?: Partial<AccountView["personal"]>
}

export function accountView(overrides: AccountViewOverrides = {}): AccountView {
	return {
		identity: {
			contactId: "003xx0000001",
			firstName: "Ada",
			lastName: "Lovelace",
			fullName: "Ada Lovelace",
			email: "ada@example.com",
			garpId: "G-IDENTITY",
			membershipType: null,
			membershipStatus: null,
			membershipExpiration: null,
			memberSince: null,
			autoRenew: false,
			isMember: false,
			isIndividualMember: false,
			isAffiliateMember: false,
			isMemberInGoodStanding: false,
			audience: "All",
			photoUrl: null,
			...overrides.identity,
		},
		completeness: completeness(overrides.completeness),
		standing: overrides.standing ?? null,
		personal: {
			firstName: "Ada",
			lastName: "Lovelace",
			email: "ada@example.com",
			phone: null,
			photoUrl: null,
			...overrides.personal,
		},
		designations: {
			ACCA: null,
			CA: null,
			CAIA: null,
			CFA: null,
			CFP: null,
			CIA: null,
			CMA: null,
			CMT: null,
			CPA: null,
			CQF: null,
			PMP: null,
			Other: null,
			otherQualifications: null,
		},
		career: {
			currentlyWorkingStatus: null,
			company: null,
			corporateTitle: null,
			jobFunction: null,
			areaOfConcentration: null,
			companyCity: null,
			companyCountry: null,
			industryWorkingYear: null,
			riskManagementWorkingYear: null,
		},
		academic: {
			highestDegree: null,
			schoolName: null,
			degreeProgramName: null,
			currentlyInSchool: null,
			expectedGraduationDate: null,
			expectedGraduationMonth: null,
		},
		expertise: { riskSpecialty: null, topicsOrExpertise: null },
		directory: {
			optedIn: null,
			connectFeature: null,
			showJobInformation: null,
			showProfessionalBackground: null,
			showAdditionalDetail: null,
		},
		chapters: { primary: null, secondary: null },
		preferences: {
			garpUpdates: null,
			chapterMeetings: null,
			careerCenter: null,
			memberUpdates: null,
		},
		mailingAddress: emptyPortalAddress(),
		billingAddress: emptyPortalAddress(),
		otherAddress: emptyPortalAddress(),
	}
}
