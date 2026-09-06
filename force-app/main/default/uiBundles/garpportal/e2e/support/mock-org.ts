import type { Page, Route } from "@playwright/test"

import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { currentUserGraphql, memberPortalMe } from "./identity"

/**
 * The fabricated org for the `mocked` Playwright project.
 *
 * Serves everything the built app puts on the wire — CSRF, identity
 * (gateway GraphQL + /me fallback), `/services/apexrest/memberportal/*`
 * actions, the `/services/apexrest/examreg/*` registration family, and SDK
 * GraphQL operations — from ONE dispatcher, with per-test overrides.
 * Payload data comes from the typed factories in `src/testing/factories/`
 * so contract drift breaks compilation, not the night's run.
 *
 * URL rules learned the hard way (do not "simplify"):
 * - Version-agnostic paths: the BUILT app calls /services/data/v67.0 paths
 *   (SDK default when SFDC_ENV is absent) while unit-test constants pin
 *   v65.0 — match on path fragments, never full literals.
 * - Playwright matches routes newest-first, and a gateway URL like
 *   /__local_sf/services/... matches both patterns — the generic services
 *   glob is registered FIRST, the __local_sf glob LAST.
 * - ?oid=8013 reaches the app as the NUMBER 8013 (router JSON-parses
 *   search values) — assertions on recorded calls must coerce.
 */

type Responder = (route: Route) => Promise<void>

/** Plain object → 200 envelope/data wrap; function → full control. */
type ActionValue = unknown | Responder

export type MockOrgOptions = {
	identity?: "member" | "guest"
	/** memberportal action name (e.g. "dashboard") → envelope `data` or responder. */
	actions?: Record<string, ActionValue>
	/** examreg path after `/examreg/` (e.g. "info", "event/info") → envelope `data` or responder. */
	examreg?: Record<string, ActionValue>
	/** GraphQL operation name (e.g. "PersonalInfoEditContact") → `data` value or responder. */
	graphql?: Record<string, ActionValue>
}

export type RecordedCall = {
	kind: "action" | "examreg" | "graphql" | "csrf" | "other"
	/** action name / examreg path / operation name */
	key: string
	method: string
	url: string
	postData: string | null
}

export type MockOrg = {
	/** Every request the mock org answered, in order. */
	readonly calls: RecordedCall[]
	/** Calls for one key (action name, examreg path, or GraphQL op). */
	of(key: string): RecordedCall[]
	/** Count for one key. */
	hits(key: string): number
	/** Requests that fell through to a permissive default — audit surface. */
	readonly unhandled: RecordedCall[]
	/** Swap/extend responders mid-test. */
	use(patch: Pick<MockOrgOptions, "actions" | "examreg" | "graphql">): void
}

/** Responder that refuses with a memberportal error envelope (status mirrors). */
export function refuse(statusCode: number, errorMessage: string): Responder {
	return (route) =>
		route.fulfill({
			status: statusCode,
			json: memberPortalError(statusCode, errorMessage),
		})
}

function operationName(postData: string | null): string {
	const match = postData?.match(/\b(?:query|mutation)\s+([A-Za-z0-9_]+)/)
	return match?.[1] ?? "(anonymous)"
}

export async function installMockOrg(
	page: Page,
	options: MockOrgOptions = {},
): Promise<MockOrg> {
	const who = options.identity ?? "member"
	const actions: Record<string, ActionValue> = { ...options.actions }
	const examreg: Record<string, ActionValue> = { ...options.examreg }
	const graphql: Record<string, ActionValue> = { ...options.graphql }

	const calls: RecordedCall[] = []
	const unhandled: RecordedCall[] = []

	if (who === "guest") {
		await page.addInitScript(() => {
			// The app's own local-logout flag: fetchCurrentUser returns null
			// before ANY network. Guards still run and must see a guest.
			sessionStorage.setItem("garpportal:local-logged-out", "1")
		})
	}

	async function fulfillValue(
		route: Route,
		value: ActionValue,
		wrap: (data: unknown) => unknown,
	): Promise<void> {
		if (typeof value === "function") {
			await (value as Responder)(route)
			return
		}
		await route.fulfill({ json: wrap(value) })
	}

	async function dispatch(route: Route): Promise<void> {
		const request = route.request()
		const url = request.url()
		const method = request.method()
		const postData = request.postData()
		const record = (kind: RecordedCall["kind"], key: string) => {
			const call: RecordedCall = { kind, key, method, url, postData }
			calls.push(call)
			return call
		}

		if (url.includes("/ui-api/session/csrf")) {
			record("csrf", "csrf")
			await route.fulfill({ json: { csrfToken: "e2e-csrf-token" } })
			return
		}

		if (url.includes("/graphql")) {
			const op = operationName(postData)
			const call = record("graphql", op)
			if (op === "CurrentUser") {
				await route.fulfill({ json: currentUserGraphql(who) })
				return
			}
			if (op in graphql) {
				await fulfillValue(route, graphql[op], (data) => ({ data }))
				return
			}
			unhandled.push(call)
			await route.fulfill({ json: { data: {} } })
			return
		}

		const examregMatch = url.match(/\/services\/apexrest\/examreg\/([^?]+)/)
		if (examregMatch) {
			const path = examregMatch[1]
			const call = record("examreg", path)
			if (path in examreg) {
				await fulfillValue(route, examreg[path], memberPortalEnvelope)
				return
			}
			if (path === "whoami") {
				await route.fulfill({
					json: memberPortalEnvelope({ isAuthenticated: who === "member" }),
				})
				return
			}
			unhandled.push(call)
			await route.fulfill({ json: memberPortalEnvelope({}) })
			return
		}

		const actionMatch = url.match(
			/\/services\/apexrest\/memberportal\/([^?/]+)/,
		)
		if (actionMatch) {
			const action = actionMatch[1]
			const call = record("action", action)
			if (action in actions) {
				await fulfillValue(route, actions[action], memberPortalEnvelope)
				return
			}
			if (action === "me") {
				if (who === "member") {
					await route.fulfill({ json: memberPortalEnvelope(memberPortalMe()) })
				} else {
					await route.fulfill({
						status: 401,
						json: memberPortalError(401, "Not authenticated."),
					})
				}
				return
			}
			unhandled.push(call)
			await route.fulfill({ json: memberPortalEnvelope({}) })
			return
		}

		const call = record("other", new URL(url).pathname)
		unhandled.push(call)
		await route.fulfill({ json: {} })
	}

	// Generic catch-all FIRST, gateway prefix LAST (newest-first matching).
	await page.route("**/services/**", dispatch)
	await page.route("**/__local_sf/**", dispatch)

	return {
		calls,
		unhandled,
		of: (key) => calls.filter((c) => c.key === key),
		hits: (key) => calls.filter((c) => c.key === key).length,
		use: (patch) => {
			Object.assign(actions, patch.actions)
			Object.assign(examreg, patch.examreg)
			Object.assign(graphql, patch.graphql)
		},
	}
}
