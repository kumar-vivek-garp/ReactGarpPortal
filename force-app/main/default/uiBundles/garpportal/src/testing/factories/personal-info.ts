/**
 * Fixtures for the `personal-info` domain (`PersonalInfoEditData`) — the
 * member record the edit dialog and the registration forms seed themselves
 * from — plus the wire shapes that produce it: the composed account view and
 * the one GraphQL read (the Account billing company) that view omits.
 */

import type { QueryClient } from "@tanstack/react-query"

import { accountQueryKeys } from "@/api/account/query-options"
import type { AccountView, PortalAddress } from "@/api/account/types"
import { joinStreet } from "@/api/personal-info/address-utils"
import { personalInfoQueryKeys } from "@/api/personal-info/query-options"
import type {
	AddressFormFields,
	PersonalInfoEditData,
} from "@/api/personal-info/types"
import {
	accountView,
	type AccountViewOverrides,
} from "@/testing/factories/account"

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
		photoUrl: null,
		firstName: "Ada",
		lastName: "Lovelace",
		email: "ada@example.org",
		/** Stored exactly as the org's `mobilePhoneLocations` spell it. */
		mobilePhoneCode: "United States (+1)",
		mobilePhone: "5551234",
		billing: portalAddressFields(),
		mailing: portalAddressFields({
			address1: "2 Ship St",
			city: "Boston",
			state: "MA",
			postalCode: "02110",
		}),
		sameAsBilling: false,
		...overrides,
	}
}

/** One `Address` block as `GARP_Portal_AccountService` returns it. */
function toPortalAddress(fields: AddressFormFields): PortalAddress {
	const street = joinStreet(fields.address1, fields.address2, fields.address3)
	return {
		street: street || null,
		street1: fields.address1 || null,
		street2: fields.address2 || null,
		street3: fields.address3 || null,
		city: fields.city || null,
		state: fields.state || null,
		postalCode: fields.postalCode || null,
		country: fields.country || null,
		isEmpty: !street && !fields.city && !fields.country,
	}
}

/**
 * The composed `GET /memberportal/account` payload that hydrates into `data`
 * — so the mapper (street lines, phones, same-as-billing) runs for real in
 * component tests and e2e mocks.
 */
export function accountViewFromPersonalInfo(
	data: PersonalInfoEditData,
	overrides: AccountViewOverrides = {},
): AccountView {
	return accountView({
		...overrides,
		identity: { contactId: data.contactId, ...overrides.identity },
		personal: {
			firstName: data.firstName,
			lastName: data.lastName,
			email: data.email,
			phone: data.billing.phone || null,
			homePhone: data.mailing.phone || null,
			mobilePhone: data.mobilePhone || null,
			mobilePhoneCode: data.mobilePhoneCode || null,
			mailingCompany: data.mailing.company || null,
			photoUrl: data.photoUrl,
			...overrides.personal,
		},
		mailingAddress: toPortalAddress(data.mailing),
		billingAddress: toPortalAddress(data.billing),
		isBillingAndMailingAddressSame: data.sameAsBilling,
	})
}

/** GraphQL `data` for the `BillingCompany` read (the mock org wants this). */
export function billingCompanyGraphql(data: PersonalInfoEditData) {
	return {
		uiapi: {
			query: {
				Contact: {
					edges: [
						{
							node: {
								Id: data.contactId,
								Account: {
									Id: "001-member",
									Billing_Address_Company__c: {
										value: data.billing.company || null,
									},
								},
							},
						},
					],
				},
			},
		},
	}
}

/** Resolver for `sdkGraphqlHandler({ ...billingCompanyResolver(data) })`. */
export function billingCompanyResolver(data: PersonalInfoEditData) {
	return { BillingCompany: () => ({ data: billingCompanyGraphql(data) }) }
}

/**
 * Pre-caches both halves of the hydrate so a panel under test seeds from
 * `data` without either read reaching the wire.
 */
export function seedPersonalInfoCache(
	queryClient: QueryClient,
	data: PersonalInfoEditData = personalInfoEditData(),
): void {
	queryClient.setQueryData(
		accountQueryKeys.detail,
		accountViewFromPersonalInfo(data),
	)
	queryClient.setQueryData(
		personalInfoQueryKeys.billingCompany(data.contactId),
		{ accountId: "001-member", billingCompany: data.billing.company || null },
	)
}
