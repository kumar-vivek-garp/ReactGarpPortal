import { createDataSDK, gql } from "@salesforce/platform-sdk"

import { fetchContactProfileExtras } from "@/api/auth/contact-profile"
import { isLocallyLoggedOut } from "@/auth/local-session"
import { isLocalViteHost } from "@/auth/sfdc-env"

export type CurrentUser = {
	/** Salesforce User Id */
	id: string
	name: string
	/** Contact.GARP_Member_ID__c — member-facing portal ID; null if no Contact / field empty */
	garpId: string | null
	/** Contact Id when the user has a Contact; null otherwise. */
	contactId: string | null
	/** Contact.Photo_URL__c — profile photo path/URL; null if unset. */
	photoUrl: string | null
}

type CurrentUserQueryResult = {
	uiapi?: {
		currentUser?: {
			Id?: string | null
			Name?: { value?: string | null } | null
			Contact?: {
				Id?: string | null
				GARP_Member_ID__c?: { value?: string | null } | null
				Photo_URL__c?: { value?: string | null } | null
			} | null
		} | null
	} | null
}

/**
 * Session identity + Contact GARP Member ID + profile photo.
 * Nested `currentUser.Contact` custom fields are often blank; we enrich via a
 * direct Contact query when `Contact.Id` is present.
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
					GARP_Member_ID__c @optional {
						value
					}
					Photo_URL__c @optional {
						value
					}
				}
			}
		}
	}
`

async function mapCurrentUser(
	currentUser: NonNullable<
		NonNullable<CurrentUserQueryResult["uiapi"]>["currentUser"]
	>,
	enrich: (contactId: string) => Promise<{
		garpId: string | null
		photoUrl: string | null
		fullName: string | null
	} | null>,
): Promise<CurrentUser | null> {
	if (!currentUser.Id) return null
	const rawContactId = currentUser.Contact?.Id?.trim() || null
	let garpId = currentUser.Contact?.GARP_Member_ID__c?.value?.trim() || null
	let photoUrl = currentUser.Contact?.Photo_URL__c?.value?.trim() || null
	let name = currentUser.Name?.value ?? ""

	if (rawContactId && (!garpId || !photoUrl)) {
		const extras = await enrich(rawContactId)
		if (extras) {
			garpId = garpId ?? extras.garpId
			photoUrl = photoUrl ?? extras.photoUrl
			if (!name.trim() && extras.fullName) name = extras.fullName
		}
	}

	return {
		id: currentUser.Id,
		name,
		garpId,
		contactId: rawContactId,
		photoUrl,
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

	// Localhost Vite (dev or preview): identity via CLI gateway.
	if (isLocalViteHost()) {
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
			cacheControl: "no-cache",
		})

		if (result?.errors?.length) {
			return null
		}

		const currentUser = result?.data?.uiapi?.currentUser
		if (!currentUser) return null
		return mapCurrentUser(currentUser, fetchContactProfileExtras)
	} catch {
		return null
	}
}
