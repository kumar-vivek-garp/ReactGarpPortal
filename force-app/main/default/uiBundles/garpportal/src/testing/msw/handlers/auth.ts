import { http, HttpResponse } from "msw"

import type { CurrentUser } from "@/api/auth/current-user"

/**
 * Wire handlers for the session identity probe (`fetchCurrentUser`).
 *
 * Under jsdom the origin is `localhost`, so `fetchCurrentUser` takes its local
 * Vite branch: a plain-fetch GraphQL POST to the CLI gateway, falling back to
 * `memberportal/me` when GraphQL yields no user. These handlers serve that
 * wire; everything above it — `ensureCurrentUser`, `ensureQueryData`, the
 * route guards — runs for real, per testing.md ("MSW at the network edge").
 */
export const LOCAL_CLI_GRAPHQL_URL = "/__local_sf/services/data/v67.0/graphql"
export const LOCAL_CLI_ME_URL = "/__local_sf/services/apexrest/memberportal/me"

/**
 * `user` with full Contact fields resolves in ONE GraphQL round trip (the
 * enrich query only fires when garpId/photoUrl are missing). `null` models a
 * guest: GraphQL answers with no currentUser, and the `memberportal/me`
 * fallback probe is refused with a 401, which the client maps to `null`.
 */
export function currentUserWireHandlers(user: CurrentUser | null) {
	return [
		http.post(LOCAL_CLI_GRAPHQL_URL, () =>
			HttpResponse.json({
				data: {
					uiapi: {
						currentUser: user
							? {
									Id: user.id,
									Name: { value: user.name },
									Contact: user.contactId
										? {
												Id: user.contactId,
												GARP_Member_ID__c: { value: user.garpId },
												Photo_URL__c: { value: user.photoUrl },
											}
										: null,
								}
							: null,
					},
				},
			}),
		),
		http.get(LOCAL_CLI_ME_URL, () =>
			HttpResponse.json({ success: false }, { status: 401 }),
		),
	]
}
