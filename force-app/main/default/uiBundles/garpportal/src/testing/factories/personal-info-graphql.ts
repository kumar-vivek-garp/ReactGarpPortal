/**
 * Wire-shaped fixtures for the personal-info GraphQL reads — the
 * `PersonalInfoEditContact` and `PersonalInfoCountries` operations the edit
 * forms hydrate from. Built from the domain factories so the values stay in
 * one place; serve through `sdkGraphqlHandler` so the real loader (street
 * splitting, same-as-billing detection) runs in component tests.
 */

import { joinStreet } from "@/api/personal-info/address-utils"
import type {
	AddressFormFields,
	CountryOption,
	PersonalInfoEditData,
} from "@/api/personal-info/types"

function field(value: string | null): { value: string } | null {
	return value ? { value } : null
}

/** One `Contact` node as `loadPersonalInfoEditData` reads it off the wire. */
export function contactEditNode(data: PersonalInfoEditData) {
	const street = (address: AddressFormFields) =>
		field(joinStreet(address.address1, address.address2, address.address3))
	return {
		Id: data.contactId,
		FirstName: field(data.firstName),
		LastName: field(data.lastName),
		Email: field(data.email),
		MobilePhone: field(data.mobilePhone),
		Mobile_Phone_Code__c: field(data.mobilePhoneCode),
		Photo_URL__c: field(data.photoUrl),
		Mailing_Address_Company__c: field(data.mailing.company),
		MailingStreet: street(data.mailing),
		MailingCity: field(data.mailing.city),
		MailingState: field(data.mailing.state),
		MailingPostalCode: field(data.mailing.postalCode),
		MailingCountry: field(data.mailing.country),
		HomePhone: field(data.mailing.phone),
		AccountId: data.accountId ? { value: data.accountId } : null,
		Account: data.accountId
			? {
					Id: data.accountId,
					Billing_Address_Company__c: field(data.billing.company),
					BillingStreet: street(data.billing),
					BillingCity: field(data.billing.city),
					BillingState: field(data.billing.state),
					BillingPostalCode: field(data.billing.postalCode),
					BillingCountry: field(data.billing.country),
					Phone: field(data.billing.phone),
				}
			: null,
	}
}

/**
 * Resolvers for both hydrate reads, ready to spread into one
 * `sdkGraphqlHandler({...})` call alongside per-test mutation spies.
 */
export function personalInfoGraphqlResolvers(
	data: PersonalInfoEditData,
	countries: CountryOption[],
) {
	return {
		PersonalInfoEditContact: () => ({
			data: {
				uiapi: {
					query: { Contact: { edges: [{ node: contactEditNode(data) }] } },
				},
			},
		}),
		PersonalInfoCountries: () => ({
			data: {
				uiapi: {
					query: {
						Country_Code__c: {
							edges: countries.map((country) => ({
								node: {
									Id: country.value,
									Country__c: { value: country.value },
									PhoneCode__c: { value: country.phoneCode },
								},
							})),
						},
					},
				},
			},
		}),
	}
}
