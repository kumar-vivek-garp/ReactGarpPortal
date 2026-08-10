import { createDataSDK, gql } from "@salesforce/platform-sdk"

import { AppError } from "@/api/client"

type EmailPreferenceUpdateResult = {
	uiapi?: {
		ContactUpdate?: {
			success?: boolean | null
		} | null
	} | null
}

const REQUEST_EMAIL_PREFERENCES_MUTATION = gql`
	mutation RequestEmailPreferences($contactId: IdOrRef!, $updatedAt: DateTime) {
		uiapi(input: { allOrNone: true }) {
			ContactUpdate(
				input: {
					Id: $contactId
					Contact: { Last_Email_Pref_Update_Date__c: $updatedAt }
				}
			) {
				success
			}
		}
	}
`

/**
 * Stamps `Last_Email_Pref_Update_Date__c` so org automation can email the
 * member their preference-center link (same as MyGarp remoting).
 */
export async function requestEmailPreferences(contactId: string): Promise<void> {
	const trimmedId = contactId.trim()
	if (!trimmedId) {
		throw new AppError({ messages: ["Contact Id is required."] })
	}

	const sdk = await createDataSDK()
	const result = await sdk.graphql?.mutate<
		EmailPreferenceUpdateResult,
		{ contactId: string; updatedAt: string }
	>({
		mutation: REQUEST_EMAIL_PREFERENCES_MUTATION,
		variables: {
			contactId: trimmedId,
			updatedAt: new Date().toISOString(),
		},
	})

	if (result?.errors?.length) {
		throw new AppError({
			messages: result.errors.map((error) => error.message),
		})
	}

	if (result?.data?.uiapi?.ContactUpdate?.success === false) {
		throw new AppError({
			messages: ["Unable to request email preference update."],
		})
	}
}
