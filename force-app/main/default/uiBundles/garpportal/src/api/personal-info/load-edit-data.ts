import { createDataSDK, gql } from "@salesforce/platform-sdk"

import { AppError } from "@/api/client"
import {
	addressesMatch,
	emptyAddress,
	splitStreet,
	str,
} from "@/api/personal-info/address-utils"
import type { PersonalInfoEditData } from "@/api/personal-info/types"

type StringField = { value?: string | null } | null | undefined
type IdField = { value?: string | null } | null | undefined

type ContactEditNode = {
	Id?: string
	FirstName?: StringField
	LastName?: StringField
	Email?: StringField
	MobilePhone?: StringField
	Mobile_Phone_Code__c?: StringField
	Photo_URL__c?: StringField
	Mailing_Address_Company__c?: StringField
	MailingStreet?: StringField
	MailingCity?: StringField
	MailingState?: StringField
	MailingPostalCode?: StringField
	MailingCountry?: StringField
	HomePhone?: StringField
	AccountId?: IdField
	Account?: {
		Id?: string
		Billing_Address_Company__c?: StringField
		BillingStreet?: StringField
		BillingCity?: StringField
		BillingState?: StringField
		BillingPostalCode?: StringField
		BillingCountry?: StringField
		Phone?: StringField
	} | null
}

type ContactEditQueryResult = {
	uiapi?: {
		query?: {
			Contact?: {
				edges?: Array<{ node?: ContactEditNode | null } | null> | null
			} | null
		} | null
	} | null
}

const CONTACT_EDIT_QUERY = gql`
	query PersonalInfoEditContact($contactId: ID!, $first: Int!) {
		uiapi {
			query {
				Contact(where: { Id: { eq: $contactId } }, first: $first) {
					edges {
						node {
							Id
							FirstName @optional {
								value
							}
							LastName @optional {
								value
							}
							Email @optional {
								value
							}
							MobilePhone @optional {
								value
							}
							Mobile_Phone_Code__c @optional {
								value
							}
							Photo_URL__c @optional {
								value
							}
							Mailing_Address_Company__c @optional {
								value
							}
							MailingStreet @optional {
								value
							}
							MailingCity @optional {
								value
							}
							MailingState @optional {
								value
							}
							MailingPostalCode @optional {
								value
							}
							MailingCountry @optional {
								value
							}
							HomePhone @optional {
								value
							}
							AccountId @optional {
								value
							}
							Account @optional {
								Id
								Billing_Address_Company__c @optional {
									value
								}
								BillingStreet @optional {
									value
								}
								BillingCity @optional {
									value
								}
								BillingState @optional {
									value
								}
								BillingPostalCode @optional {
									value
								}
								BillingCountry @optional {
									value
								}
								Phone @optional {
									value
								}
							}
						}
					}
					pageInfo {
						hasNextPage
						endCursor
					}
				}
			}
		}
	}
`

/**
 * Loads Contact + Account billing fields for the Personal Information edit form.
 */
export async function loadPersonalInfoEditData(
	contactId: string,
): Promise<PersonalInfoEditData> {
	const trimmedId = contactId.trim()
	if (!trimmedId) {
		throw new AppError({ messages: ["Contact Id is required."] })
	}

	const sdk = await createDataSDK()
	// Bypass SDK OneStore (300s TTL) — TanStack Query caches this hydrate.
	const result = await sdk.graphql?.query<
		ContactEditQueryResult,
		{ contactId: string; first: number }
	>({
		query: CONTACT_EDIT_QUERY,
		variables: { contactId: trimmedId, first: 1 },
		cacheControl: "no-cache",
	})

	if (result?.errors?.length) {
		throw new AppError({
			messages: result.errors.map((error) => error.message),
		})
	}

	const node = result?.data?.uiapi?.query?.Contact?.edges?.[0]?.node
	if (!node?.Id) {
		throw new AppError({ messages: ["Unable to load personal information."] })
	}

	const [mail1, mail2, mail3] = splitStreet(node.MailingStreet?.value)
	const [bill1, bill2, bill3] = splitStreet(node.Account?.BillingStreet?.value)

	const billing = {
		company: str(node.Account?.Billing_Address_Company__c?.value),
		address1: bill1,
		address2: bill2,
		address3: bill3,
		country: str(node.Account?.BillingCountry?.value),
		city: str(node.Account?.BillingCity?.value),
		state: str(node.Account?.BillingState?.value),
		postalCode: str(node.Account?.BillingPostalCode?.value),
		phone: str(node.Account?.Phone?.value),
	}

	const mailing = {
		company: str(node.Mailing_Address_Company__c?.value),
		address1: mail1,
		address2: mail2,
		address3: mail3,
		country: str(node.MailingCountry?.value),
		city: str(node.MailingCity?.value),
		state: str(node.MailingState?.value),
		postalCode: str(node.MailingPostalCode?.value),
		phone: str(node.HomePhone?.value),
	}

	const accountId =
		node.Account?.Id?.trim() || node.AccountId?.value?.trim() || null

	return {
		contactId: node.Id,
		accountId,
		photoUrl: node.Photo_URL__c?.value?.trim() || null,
		firstName: str(node.FirstName?.value),
		lastName: str(node.LastName?.value),
		email: str(node.Email?.value),
		mobilePhoneCode: str(node.Mobile_Phone_Code__c?.value),
		mobilePhone: str(node.MobilePhone?.value),
		billing: accountId ? billing : emptyAddress(),
		mailing,
		sameAsBilling: accountId ? addressesMatch(billing, mailing) : false,
	}
}
