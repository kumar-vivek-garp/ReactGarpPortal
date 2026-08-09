import { createDataSDK, gql } from "@salesforce/platform-sdk"

/**
 * Slim Contact lookup used to enrich session identity when nested
 * `currentUser.Contact` custom fields are blank / inaccessible.
 */

type StringField = { value?: string | null } | null | undefined

type ContactProfileQueryResult = {
	uiapi?: {
		query?: {
			Contact?: {
				edges?: Array<{
					node?: {
						Id?: string
						GARP_Member_ID__c?: StringField
						GARP_ID__c?: StringField
						Photo_URL__c?: StringField
						Name?: StringField
					} | null
				} | null> | null
			} | null
		} | null
	} | null
}

const CONTACT_PROFILE_QUERY = gql`
	query ContactProfileExtras($contactId: ID!, $first: Int!) {
		uiapi {
			query {
				Contact(where: { Id: { eq: $contactId } }, first: $first) {
					edges {
						node {
							Id
							Name @optional {
								value
							}
							GARP_Member_ID__c @optional {
								value
							}
							GARP_ID__c @optional {
								value
							}
							Photo_URL__c @optional {
								value
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

export type ContactProfileExtras = {
	garpId: string | null
	photoUrl: string | null
	fullName: string | null
}

function trimOrNull(value: string | null | undefined): string | null {
	const trimmed = value?.trim()
	return trimmed ? trimmed : null
}

export function mapContactProfileExtras(
	node:
		| {
				GARP_Member_ID__c?: StringField
				GARP_ID__c?: StringField
				Photo_URL__c?: StringField
				Name?: StringField
		  }
		| null
		| undefined,
): ContactProfileExtras {
	const garpMemberId = trimOrNull(node?.GARP_Member_ID__c?.value)
	const garpLegacyId = trimOrNull(node?.GARP_ID__c?.value)
	return {
		garpId: garpMemberId ?? garpLegacyId,
		photoUrl: trimOrNull(node?.Photo_URL__c?.value),
		fullName: trimOrNull(node?.Name?.value),
	}
}

/** Data SDK path (Experience Cloud / production). */
export async function fetchContactProfileExtras(
	contactId: string,
): Promise<ContactProfileExtras | null> {
	const trimmedId = contactId.trim()
	if (!trimmedId) return null

	try {
		const sdk = await createDataSDK({
			webapp: {
				onStatus: {
					401: () => undefined,
					403: () => undefined,
				},
			},
		})
		const result = await sdk.graphql?.query<
			ContactProfileQueryResult,
			{ contactId: string; first: number }
		>({
			query: CONTACT_PROFILE_QUERY,
			variables: { contactId: trimmedId, first: 1 },
			cacheControl: "no-cache",
		})

		if (result?.errors?.length) return null
		const node = result?.data?.uiapi?.query?.Contact?.edges?.[0]?.node
		if (!node?.Id) return null
		return mapContactProfileExtras(node)
	} catch {
		return null
	}
}

export { CONTACT_PROFILE_QUERY }
export type { ContactProfileQueryResult }
