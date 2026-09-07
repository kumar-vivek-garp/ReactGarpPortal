import { http, HttpResponse } from "msw"

import type {
	AccountOptionsView,
	AccountView,
	SaveAccountProfileResult,
} from "@/api/account/types"
import type { AccountProfileValues } from "@/api/account/save-profile"
import { accountView, completeness } from "@/testing/factories/account"
import { accountOptionsView } from "@/testing/factories/account-options"
import { memberPortalEnvelope } from "@/testing/factories/envelope"

export const ACCOUNT_PATH = "/services/apexrest/memberportal/account"
export const ACCOUNT_OPTIONS_PATH = "/services/apexrest/memberportal/options"
export const PROFILE_PATH = "/services/apexrest/memberportal/profile"

/** What the profile spy observed: how often it was hit, with which `values`. */
export type ProfileSpy = {
	hits: number
	bodies: AccountProfileValues[]
}

/**
 * The My Account org surface — the composed account view, the form options,
 * and a spying `profile` write. `view` may be a function so a stateful test
 * can hand back the post-save payload after the write invalidates the cache.
 * Register with `server.use(...org.handlers)`; layer scenario overrides (HTTP
 * errors, refusals) on top with a later `server.use`.
 */
export function myAccountOrg({
	view = accountView(),
	options = accountOptionsView(),
	profileRespond = (values) => ({
		applied: Object.keys(values),
		rejected: [],
		completeness: completeness(),
	}),
}: {
	view?: AccountView | (() => AccountView)
	options?: AccountOptionsView
	profileRespond?: (
		values: AccountProfileValues,
		hits: number,
	) => SaveAccountProfileResult
} = {}) {
	const profileSpy: ProfileSpy = { hits: 0, bodies: [] }
	const handlers = [
		http.get(ACCOUNT_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope(typeof view === "function" ? view() : view),
			),
		),
		http.get(ACCOUNT_OPTIONS_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(options)),
		),
		http.post(PROFILE_PATH, async ({ request }) => {
			const body = (await request.json()) as { values: AccountProfileValues }
			profileSpy.hits += 1
			profileSpy.bodies.push(body.values)
			return HttpResponse.json(
				memberPortalEnvelope(profileRespond(body.values, profileSpy.hits)),
			)
		}),
	]
	return { profileSpy, handlers }
}
