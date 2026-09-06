import { identity } from "@/testing/factories/identity"

/**
 * Wire-level identity payloads for the mock org. On localhost the app
 * resolves the session via the local gateway: a CurrentUser GraphQL POST,
 * falling back to GET memberportal/me. A GUEST IS AN ANSWER, NOT AN
 * ABSENCE — every route resolves identity, including public ones.
 */

export const MEMBER = {
	userId: "005000000000001AAA",
	contactId: "003000000000001AAA",
	name: "Ada Lovelace",
	garpId: "123456",
} as const

/** `{ data: { uiapi: { currentUser } } }` for the CurrentUser operation. */
export function currentUserGraphql(kind: "member" | "guest") {
	if (kind === "guest") {
		return { data: { uiapi: { currentUser: null } } }
	}
	return {
		data: {
			uiapi: {
				currentUser: {
					Id: MEMBER.userId,
					Name: { value: MEMBER.name },
					Contact: {
						Id: MEMBER.contactId,
						// Both populated so identity resolves in ONE round trip
						// (blanks trigger a second ContactProfileExtras call).
						GARP_Member_ID__c: { value: MEMBER.garpId },
						Photo_URL__c: { value: null },
					},
				},
			},
		},
	}
}

/** Envelope `data` for the GET memberportal/me fallback. */
export function memberPortalMe() {
	return {
		contactId: MEMBER.contactId,
		firstName: "Ada",
		lastName: "Lovelace",
		garpId: MEMBER.garpId,
		avatarPhotoURL: null,
		identity: identity(),
	}
}
