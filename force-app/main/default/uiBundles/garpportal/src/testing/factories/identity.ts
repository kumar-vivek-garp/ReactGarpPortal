import type { Identity } from "@/api/account/types"
import type { MembershipView } from "@/api/membership/types"

/**
 * The `identity` block shared by the memberportal `dashboard`, `membership`
 * and `account` payloads — an Individual member in good standing. Promoted
 * from the gated-content suite's local helper once the page tests needed the
 * same shape.
 */
export function identity(overrides: Partial<Identity> = {}): Identity {
	return {
		contactId: "003XX0000012345",
		firstName: "Ada",
		lastName: "Lovelace",
		fullName: "Ada Lovelace",
		email: "ada@example.com",
		garpId: "123456",
		membershipType: "Individual",
		membershipStatus: "Active",
		membershipExpiration: "2027-01-01",
		memberSince: "2020-01-01",
		autoRenew: false,
		isMember: true,
		isIndividualMember: true,
		isAffiliateMember: false,
		isMemberInGoodStanding: true,
		audience: "Individual",
		photoUrl: null,
		...overrides,
	}
}

/** `memberportal/membership` happy payload — hero and benefits left empty. */
export function membershipView(
	overrides: Partial<MembershipView> = {},
): MembershipView {
	return {
		identity: identity(),
		hero: null,
		sections: [],
		lockedCount: 0,
		...overrides,
	}
}
