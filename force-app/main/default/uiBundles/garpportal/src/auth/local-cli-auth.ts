import type { CurrentUser } from "@/api/auth/current-user"
import { isLocalViteHost } from "@/auth/sfdc-env"

/** Vite DEV + localhost only. Compiles to false in production builds. */
export function isLocalCliAuthEnabled(): boolean {
	return import.meta.env.DEV && isLocalViteHost()
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
 */
export async function localSfFetch(
	path: string,
	init?: RequestInit,
): Promise<Response> {
	const normalized = path.startsWith("/") ? path : `/${path}`
	if (!normalized.startsWith("/services/")) {
		throw new Error("localSfFetch only supports /services/* paths")
	}
	return fetch(`${LOCAL_SF_PREFIX}${normalized}`, init)
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
				} | null
			} | null
		} | null
	}
	errors?: unknown[]
}

type MemberPortalMeEnvelope = {
	ok?: boolean
	data?: {
		contactId?: string
		fullName?: string
		email?: string
		garpId?: string
	}
}

/**
 * GraphQL currentUser (+ Contact GARP ID) via local CLI proxy.
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
						GARP_Member_ID__c { value @optional }
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
				body: JSON.stringify({ query }),
			},
		)

		if (response.ok) {
			const payload = (await response.json()) as CurrentUserQueryResult
			if (!payload.errors?.length) {
				const currentUser = payload.data?.uiapi?.currentUser
				if (currentUser?.Id) {
					const rawGarpId = currentUser.Contact?.GARP_Member_ID__c?.value?.trim()
					return {
						id: currentUser.Id,
						name: currentUser.Name?.value ?? "",
						garpId: rawGarpId ? rawGarpId : null,
					}
				}
			}
		}
	} catch {
		/* try REST fallback */
	}

	const me = await fetchMemberPortalMeViaLocalCli()
	if (me && typeof me === "object" && me.ok && me.data) {
		const data = me.data
		if (data.contactId || data.fullName || data.email) {
			const rawGarpId = data.garpId?.trim()
			return {
				id: data.contactId ?? "local-cli-member",
				name: data.fullName ?? data.email ?? "CLI Member",
				garpId: rawGarpId ? rawGarpId : null,
			}
		}
	}

	return null
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
