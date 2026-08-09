import type { AccountContact } from "@/api/account/account-contact-types"
import type {
	AccountView,
	Audience,
	PortalAddress,
} from "@/api/account/types"

function toPortalAddress(address: AccountContact["mailing"]): PortalAddress {
	const street = address.street
	const city = address.city
	const state = address.state
	const postalCode = address.postalCode
	const country = address.country
	const isEmpty = ![street, city, state, postalCode, country].some(Boolean)
	return { street, city, state, postalCode, country, isEmpty }
}

function audienceFromMembershipType(membershipType: string | null): Audience {
	if (membershipType === "Individual") return "Individual"
	if (membershipType === "Affiliate") return "Affiliate"
	if (membershipType) return "NonMember"
	return "NonMember"
}

/**
 * Maps GraphQL AccountContact into AccountView sections for the Information panel.
 * Completeness / preferences are stubs — callers must use REST for completeness.
 */
export function accountContactToView(contact: AccountContact): AccountView {
	const membershipType = contact.membershipType
	const isIndividualMember = membershipType === "Individual"
	const isAffiliateMember = membershipType === "Affiliate"
	const isMember = Boolean(membershipType)

	return {
		identity: {
			contactId: contact.contactId,
			firstName: contact.firstName,
			lastName: contact.lastName,
			fullName: contact.fullName,
			email: contact.email,
			garpId: contact.garpId,
			membershipType,
			membershipStatus: contact.membershipStatus,
			membershipExpiration: contact.membershipExpiration,
			memberSince: contact.memberSince,
			autoRenew: contact.autoRenew,
			isMember,
			isIndividualMember,
			isAffiliateMember,
			audience: audienceFromMembershipType(membershipType),
			photoUrl: contact.photoUrl,
		},
		completeness: {
			percentComplete: 0,
			earnedWeight: 0,
			totalWeight: 0,
			isComplete: true,
			muted: true,
			missing: [],
			missingBySection: {},
		},
		personal: {
			firstName: contact.firstName,
			lastName: contact.lastName,
			email: contact.email,
			phone: contact.phone,
			photoUrl: contact.photoUrl,
		},
		career: contact.career,
		academic: contact.academic,
		expertise: contact.expertise,
		directory: contact.directory,
		chapters: contact.chapters,
		preferences: {
			garpUpdates: null,
			chapterMeetings: null,
			careerCenter: null,
			memberUpdates: null,
		},
		mailingAddress: toPortalAddress(contact.mailing),
		billingAddress: toPortalAddress(contact.billing),
		otherAddress: toPortalAddress(contact.other),
	}
}
