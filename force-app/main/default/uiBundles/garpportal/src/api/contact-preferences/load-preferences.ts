import { createDataSDK, gql } from "@salesforce/platform-sdk"

import type { ContactPreferencesData } from "@/api/contact-preferences/types"
import { AppError } from "@/api/client"

type StringField = { value?: string | null } | null | undefined
type BooleanField = { value?: boolean | null } | null | undefined

type ContactPreferencesNode = {
	Id?: string
	Email?: StringField
	MobilePhone?: StringField
	Mobile_Phone_Code__c?: StringField
	SMS_Promotional_Updates__c?: BooleanField
	SMS_Registration_Updates__c?: BooleanField
}

type ContactPreferencesQueryResult = {
	uiapi?: {
		query?: {
			Contact?: {
				edges?: Array<{ node?: ContactPreferencesNode | null } | null> | null
			} | null
		} | null
	} | null
}

const CONTACT_PREFERENCES_QUERY = gql`
	query ContactPreferences($contactId: ID!, $first: Int!) {
		uiapi {
			query {
				Contact(where: { Id: { eq: $contactId } }, first: $first) {
					edges {
						node {
							Id
							Email @optional {
								value
							}
							MobilePhone @optional {
								value
							}
							Mobile_Phone_Code__c @optional {
								value
							}
							SMS_Promotional_Updates__c @optional {
								value
							}
							SMS_Registration_Updates__c @optional {
								value
							}
						}
					}
				}
			}
		}
	}
`

function trimOrNull(value: string | null | undefined): string | null {
	const trimmed = value?.trim()
	return trimmed ? trimmed : null
}

/** Loads SMS prefs + read-only contact display fields for Contact Preferences. */
export async function loadContactPreferences(
	contactId: string,
): Promise<ContactPreferencesData> {
	const trimmedId = contactId.trim()
	if (!trimmedId) {
		throw new AppError({ messages: ["Contact Id is required."] })
	}

	const sdk = await createDataSDK()
	const result = await sdk.graphql?.query<
		ContactPreferencesQueryResult,
		{ contactId: string; first: number }
	>({
		query: CONTACT_PREFERENCES_QUERY,
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
		throw new AppError({ messages: ["Contact was not found."] })
	}

	return {
		contactId: node.Id,
		email: trimOrNull(node.Email?.value),
		mobilePhone: trimOrNull(node.MobilePhone?.value),
		mobilePhoneCode: trimOrNull(node.Mobile_Phone_Code__c?.value),
		smsPromotional: node.SMS_Promotional_Updates__c?.value === true,
		smsRegistration: node.SMS_Registration_Updates__c?.value === true,
	}
}
