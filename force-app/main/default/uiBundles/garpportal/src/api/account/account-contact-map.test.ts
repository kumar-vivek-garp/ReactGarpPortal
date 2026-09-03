import { describe, expect, it } from "vitest"

import { accountContactToView } from "@/api/account/account-contact-map"
import type { AccountContact } from "@/api/account/account-contact-types"

function accountContact(overrides: Partial<AccountContact> = {}): AccountContact {
	return {
		contactId: "003xx1",
		firstName: "Ada",
		lastName: "Lovelace",
		fullName: "Ada Lovelace",
		email: "ada@example.com",
		garpId: "G-1",
		photoUrl: null,
		phone: "555-0100",
		membershipType: null,
		membershipStatus: null,
		membershipExpiration: null,
		memberSince: null,
		autoRenew: false,
		career: {
			currentlyWorkingStatus: null,
			company: "Analytical Engines",
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
			optedIn: true,
			connectFeature: null,
			showJobInformation: null,
			showProfessionalBackground: null,
			showAdditionalDetail: null,
		},
		chapters: { primary: "London", secondary: null },
		mailing: {
			street: "1 Main St",
			city: "London",
			state: null,
			postalCode: null,
			country: "United Kingdom",
		},
		billing: { street: null, city: null, state: null, postalCode: null, country: null },
		other: { street: null, city: null, state: null, postalCode: null, country: null },
		...overrides,
	}
}

describe("accountContactToView", () => {
	it("derives the audience and member flags from the membership type", () => {
		const individual = accountContactToView(
			accountContact({ membershipType: "Individual" }),
		).identity
		expect(individual).toMatchObject({
			audience: "Individual",
			isMember: true,
			isIndividualMember: true,
			isAffiliateMember: false,
		})

		const affiliate = accountContactToView(
			accountContact({ membershipType: "Affiliate" }),
		).identity
		expect(affiliate).toMatchObject({
			audience: "Affiliate",
			isAffiliateMember: true,
		})

		// Any other non-empty type is still a member, but a NonMember audience.
		const student = accountContactToView(
			accountContact({ membershipType: "Student" }),
		).identity
		expect(student).toMatchObject({ audience: "NonMember", isMember: true })

		const none = accountContactToView(accountContact()).identity
		expect(none).toMatchObject({ audience: "NonMember", isMember: false })
	})

	it("never claims good standing from a Contact read", () => {
		const view = accountContactToView(
			accountContact({ membershipType: "Individual", membershipStatus: "Active" }),
		)
		expect(view.identity.isMemberInGoodStanding).toBe(false)
	})

	it("computes isEmpty per address", () => {
		const view = accountContactToView(accountContact())
		expect(view.mailingAddress).toMatchObject({
			street: "1 Main St",
			country: "United Kingdom",
			isEmpty: false,
		})
		expect(view.billingAddress.isEmpty).toBe(true)
	})

	it("stubs completeness as muted and complete — REST owns the real score", () => {
		const view = accountContactToView(accountContact())
		expect(view.completeness).toMatchObject({
			percentComplete: 0,
			muted: true,
			isComplete: true,
		})
		expect(view.standing).toBeNull()
	})
})
