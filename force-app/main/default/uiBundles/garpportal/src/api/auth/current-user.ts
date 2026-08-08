import { createDataSDK, gql } from "@salesforce/platform-sdk"

import { isLocallyLoggedOut } from "@/auth/local-session"
import { isLocalViteHost } from "@/auth/sfdc-env"

export type CurrentUser = {
	/** Salesforce User Id */
	id: string
	name: string
	/** Contact.GARP_Member_ID__c — member-facing portal ID; null if no Contact / field empty */
	garpId: string | null
}

type CurrentUserQueryResult = {
	uiapi?: {
		currentUser?: {
			Id?: string | null
			Name?: { value?: string | null } | null
			Contact?: {
				Id?: string | null
				GARP_Member_ID__c?: { value?: string | null } | null
			} | null
		} | null
	} | null
}

/**
 * Session identity + Contact GARP Member ID.
 * Field names verified against org GraphQL (Contact.GARP_Member_ID__c).
 * `@optional` keeps the query alive under FLS.
 */
const CURRENT_USER_QUERY = gql`
	query CurrentUser {
		uiapi {
			currentUser {
				Id
				Name {
					value @optional
				}
				Contact {
					Id
					GARP_Member_ID__c {
						value @optional
					}
				}
			}
		}
	}
`

function mapCurrentUser(
	currentUser: NonNullable<
		NonNullable<CurrentUserQueryResult["uiapi"]>["currentUser"]
	>,
): CurrentUser | null {
	if (!currentUser.Id) return null
	const rawGarpId = currentUser.Contact?.GARP_Member_ID__c?.value?.trim()
	return {
		id: currentUser.Id,
		name: currentUser.Name?.value ?? "",
		garpId: rawGarpId ? rawGarpId : null,
	}
}

/**
 * Resolves the Experience Cloud session user via GraphQL `uiapi.currentUser`
 * (not Chatter). Returns `null` for guest / 401 / unauthenticated / transport failure.
 */
export async function fetchCurrentUser(): Promise<CurrentUser | null> {
	// Local Vite Sign Out cannot clear the org proxy session — honor the local flag.
	if (isLocallyLoggedOut()) {
		return null
	}

	// DEV + localhost: identity via CLI gateway (tree-shaken out of production builds).
	if (import.meta.env.DEV && isLocalViteHost()) {
		const { fetchCurrentUserViaLocalCli } = await import("@/auth/local-cli-auth")
		return fetchCurrentUserViaLocalCli()
	}

	try {
		const sdk = await createDataSDK({
			webapp: {
				// Guest Experience users get 401 on uiapi — treat as logged out, don't throw.
				onStatus: {
					401: () => undefined,
					403: () => undefined,
				},
			},
		})
		const result = await sdk.graphql?.query<CurrentUserQueryResult>({
			query: CURRENT_USER_QUERY,
		})

		if (result?.errors?.length) {
			return null
		}

		const currentUser = result?.data?.uiapi?.currentUser
		if (!currentUser) return null
		return mapCurrentUser(currentUser)
	} catch {
		return null
	}
}
