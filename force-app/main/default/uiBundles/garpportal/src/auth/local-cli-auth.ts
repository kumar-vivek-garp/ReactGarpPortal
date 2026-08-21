import type { Identity, MemberPortalEnvelope } from "@/api/account/types"
import type { CurrentUser } from "@/api/auth/current-user"
import {
	mapContactProfileExtras,
	type ContactProfileQueryResult,
} from "@/api/auth/contact-profile"
import { isMemberPortalEnvelopeOk } from "@/api/client"
import { isLocalViteHost } from "@/auth/sfdc-env"

/**
 * Localhost only (Vite `dev` and `preview`). Safe on Experience Cloud because
 * `isLocalViteHost()` is false there. Kept available in production builds so
 * `npm run preview` can use “Continue with Salesforce CLI”.
 */
export function isLocalCliAuthEnabled(): boolean {
	return isLocalViteHost()
}

/** Browser path → Vite proxy → tools/local-dev gateway (no token in the browser). */
export const LOCAL_SF_PREFIX = "/__local_sf" as const

const DEFAULT_API_VERSION = "67.0"

export type LocalSfHealth = {
	ok: boolean
	username?: string | null
	orgId?: string | null
	error?: string
	hint?: string
}

export async function checkLocalSfHealth(): Promise<LocalSfHealth> {
	try {
		const response = await fetch(`${LOCAL_SF_PREFIX}/health`, {
			method: "GET",
			headers: { Accept: "application/json" },
		})
		const data = (await response.json()) as LocalSfHealth
		if (!response.ok) {
			return {
				ok: false,
				error: data.error ?? `Gateway HTTP ${response.status}`,
				hint: data.hint,
			}
		}
		return data
	} catch {
		return {
			ok: false,
			error: "Local Salesforce gateway is not reachable.",
			hint: "From the repo root run: npm run local-sf",
		}
	}
}

/**
 * Fetch against the local CLI gateway. `path` must start with `/services/`.
 * Attaches `X-GARP-Dev-Contact` when a local Contact is selected (Phase 2).
 */
export async function localSfFetch(
	path: string,
	init?: RequestInit,
): Promise<Response> {
	const normalized = path.startsWith("/") ? path : `/${path}`
	if (!normalized.startsWith("/services/")) {
		throw new Error("localSfFetch only supports /services/* paths")
	}

	const { localDevContactHeaders } = await import("@/auth/local-dev-contacts")
	const headers = new Headers(init?.headers)
	for (const [key, value] of Object.entries(localDevContactHeaders())) {
		headers.set(key, value)
	}

	return fetch(`${LOCAL_SF_PREFIX}${normalized}`, {
		...init,
		headers,
	})
}

type CurrentUserQueryResult = {
	data?: {
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
	errors?: unknown[]
}

/** `/memberportal/me` payload used for local CLI CurrentUser fallback. */
type MemberPortalMeData = {
	contactId?: string | null
	firstName?: string | null
	lastName?: string | null
	garpId?: string | null
	avatarPhotoURL?: string | null
	identity?: Partial<Identity> | null
}

type MemberPortalMeEnvelope = MemberPortalEnvelope<MemberPortalMeData>

async function fetchContactProfileExtrasViaLocalCli(
	contactId: string,
): Promise<{
	garpId: string | null
	photoUrl: string | null
	fullName: string | null
} | null> {
	const query = `
		query ContactProfileExtras($contactId: ID!, $first: Int!) {
			uiapi {
				query {
					Contact(where: { Id: { eq: $contactId } }, first: $first) {
						edges {
							node {
								Id
								Name @optional { value }
								GARP_Member_ID__c @optional { value }
								GARP_ID__c @optional { value }
								Photo_URL__c @optional { value }
							}
						}
						pageInfo { hasNextPage endCursor }
					}
				}
			}
		}
	`

	try {
		const response = await localSfFetch(
			`/services/data/v${DEFAULT_API_VERSION}/graphql`,
			{
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					Accept: "application/json",
				},
				body: JSON.stringify({
					query,
					variables: { contactId, first: 1 },
				}),
			},
		)
		if (!response.ok) return null
		const payload = (await response.json()) as {
			data?: ContactProfileQueryResult
			errors?: unknown[]
		}
		if (payload.errors?.length) return null
		const node = payload.data?.uiapi?.query?.Contact?.edges?.[0]?.node
		if (!node?.Id) return null
		return mapContactProfileExtras(node)
	} catch {
		return null
	}
}

/**
 * GraphQL currentUser (+ Contact GARP ID + photo) via local CLI proxy.
 * Falls back to memberportal/me when GraphQL is unavailable but REST works.
 */
export async function fetchCurrentUserViaLocalCli(): Promise<CurrentUser | null> {
	const query = `
		query CurrentUser {
			uiapi {
				currentUser {
					Id
					Name { value @optional }
					Contact {
						Id
						GARP_Member_ID__c @optional { value }
						Photo_URL__c @optional { value }
					}
				}
			}
		}
	`

	let userIdFromGraphql: string | null = null
	let nameFromGraphql = ""

	try {
		const response = await localSfFetch(
			`/services/data/v${DEFAULT_API_VERSION}/graphql`,
			{
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					Accept: "application/json",
				},
				body: JSON.stringify({ query }),
			},
		)

		if (response.ok) {
			const payload = (await response.json()) as CurrentUserQueryResult
			if (!payload.errors?.length) {
				const currentUser = payload.data?.uiapi?.currentUser
				if (currentUser?.Id) {
					userIdFromGraphql = currentUser.Id
					nameFromGraphql = currentUser.Name?.value ?? ""
					const rawContactId = currentUser.Contact?.Id?.trim() || null
					let garpId =
						currentUser.Contact?.GARP_Member_ID__c?.value?.trim() || null
					let photoUrl =
						currentUser.Contact?.Photo_URL__c?.value?.trim() || null
					let name = nameFromGraphql

					// CLI User often has Contact: null on uiapi.currentUser — fall
					// through to memberportal/me for contactId / photo / GARP ID.
					if (rawContactId) {
						if (!garpId || !photoUrl) {
							const extras =
								await fetchContactProfileExtrasViaLocalCli(rawContactId)
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
				}
			}
		}
	} catch {
		/* try REST fallback */
	}

	const me = await fetchMemberPortalMeViaLocalCli()
	if (!me || !isMemberPortalEnvelopeOk(me) || !me.data) {
		return null
	}

	const data = me.data
	const identity = data.identity
	const rawContactId =
		identity?.contactId?.trim() || data.contactId?.trim() || null
	let garpId = identity?.garpId?.trim() || data.garpId?.trim() || null
	let photoUrl =
		identity?.photoUrl?.trim() || data.avatarPhotoURL?.trim() || null
	const identityFullName = identity?.fullName?.trim() || null
	const identityEmail = identity?.email?.trim() || null
	const composedName = [data.firstName, data.lastName]
		.map((part) => part?.trim())
		.filter(Boolean)
		.join(" ")
	let name =
		nameFromGraphql.trim() ||
		identityFullName ||
		composedName ||
		identityEmail ||
		"CLI Member"

	if (!rawContactId && !identityFullName && !identityEmail && !composedName) {
		return null
	}

	if (rawContactId && (!garpId || !photoUrl)) {
		const extras = await fetchContactProfileExtrasViaLocalCli(rawContactId)
		if (extras) {
			garpId = garpId ?? extras.garpId
			photoUrl = photoUrl ?? extras.photoUrl
			if (!identityFullName && extras.fullName) {
				name = extras.fullName
			}
		}
	}

	return {
		id: userIdFromGraphql ?? rawContactId ?? "local-cli-member",
		name,
		garpId,
		contactId: rawContactId,
		photoUrl,
	}
}

/** Member portal identity via local CLI gateway. */
export async function fetchMemberPortalMeViaLocalCli(): Promise<MemberPortalMeEnvelope | null> {
	try {
		const response = await localSfFetch("/services/apexrest/memberportal/me", {
			method: "GET",
			headers: { Accept: "application/json" },
		})
		if (!response.ok) return null
		return (await response.json()) as MemberPortalMeEnvelope
	} catch {
		return null
	}
}
