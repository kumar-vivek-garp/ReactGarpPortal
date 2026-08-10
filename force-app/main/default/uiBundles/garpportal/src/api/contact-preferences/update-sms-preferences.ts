import { createDataSDK, gql } from "@salesforce/platform-sdk"

import type { UpdateSmsPreferencesInput } from "@/api/contact-preferences/types"
import { AppError } from "@/api/client"

type SmsPreferencesUpdateResult = {
	uiapi?: {
		ContactUpdate?: {
			success?: boolean | null
			Record?: {
				SMS_Promotional_Updates__c?: { value?: boolean | null } | null
				SMS_Registration_Updates__c?: { value?: boolean | null } | null
			} | null
		} | null
	} | null
}

const UPDATE_SMS_PREFERENCES_MUTATION = gql`
	mutation UpdateSmsPreferences(
		$contactId: IdOrRef!
		$smsPromotional: Boolean
		$smsRegistration: Boolean
	) {
		uiapi(input: { allOrNone: true }) {
			ContactUpdate(
				input: {
					Id: $contactId
					Contact: {
						SMS_Promotional_Updates__c: $smsPromotional
						SMS_Registration_Updates__c: $smsRegistration
					}
				}
			) {
				success
				Record {
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
`

/** Saves SMS promotional + registration opt-ins on Contact. */
export async function updateSmsPreferences(
	input: UpdateSmsPreferencesInput,
): Promise<{ smsPromotional: boolean; smsRegistration: boolean }> {
	const trimmedId = input.contactId.trim()
	if (!trimmedId) {
		throw new AppError({ messages: ["Contact Id is required."] })
	}

	const sdk = await createDataSDK()
	const result = await sdk.graphql?.mutate<
		SmsPreferencesUpdateResult,
		{
			contactId: string
			smsPromotional: boolean
			smsRegistration: boolean
		}
	>({
		mutation: UPDATE_SMS_PREFERENCES_MUTATION,
		variables: {
			contactId: trimmedId,
			smsPromotional: input.smsPromotional,
			smsRegistration: input.smsRegistration,
		},
	})

	if (result?.errors?.length) {
		throw new AppError({
			messages: result.errors.map((error) => error.message),
		})
	}

	const payload = result?.data?.uiapi?.ContactUpdate
	if (payload?.success === false) {
		throw new AppError({ messages: ["Unable to update SMS preferences."] })
	}

	return {
		smsPromotional:
			payload?.Record?.SMS_Promotional_Updates__c?.value === true ||
			input.smsPromotional,
		smsRegistration:
			payload?.Record?.SMS_Registration_Updates__c?.value === true ||
			input.smsRegistration,
	}
}
