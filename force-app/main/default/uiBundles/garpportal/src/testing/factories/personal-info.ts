/**
 * Fixtures for the `personal-info` domain (`PersonalInfoEditData`) — the
 * member record the exam registration form seeds itself from. Typed against
 * the api types so contract drift breaks compilation.
 */

import type {
	AddressFormFields,
	PersonalInfoEditData,
} from "@/api/personal-info/types"

export function portalAddressFields(
	overrides: Partial<AddressFormFields> = {},
): AddressFormFields {
	return {
		company: "",
		address1: "1 Main St",
		address2: "",
		address3: "",
		country: "United States",
		city: "Hoboken",
		state: "NJ",
		postalCode: "07030",
		phone: "5551234",
		...overrides,
	}
}

export function personalInfoEditData(
	overrides: Partial<PersonalInfoEditData> = {},
): PersonalInfoEditData {
	return {
		contactId: "003-member",
		accountId: "001-member",
		photoUrl: null,
		firstName: "Ada",
		lastName: "Lovelace",
		email: "ada@example.org",
		/** Stored bare — the form composes `"United States (+1)"` from it. */
		mobilePhoneCode: "+1",
		mobilePhone: "5551234",
		billing: portalAddressFields(),
		mailing: portalAddressFields({
			address1: "2 Ship St",
			city: "Boston",
			state: "MA",
			postalCode: "02110",
		}),
		sameAsBilling: true,
		...overrides,
	}
}
