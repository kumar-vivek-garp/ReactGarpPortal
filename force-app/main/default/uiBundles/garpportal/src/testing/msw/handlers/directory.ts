import { http, HttpResponse } from "msw"

import type {
	DirectorySearchParams,
	DirectorySearchResults,
	DirectoryView,
} from "@/api/directory"
import type { PicklistOption } from "@/api/account/types"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { directorySearchResults, directoryView } from "@/testing/factories/directory"

export const DIRECTORY_PATH = "/services/apexrest/memberportal/directory"
export const DIRECTORY_SEARCH_PATH =
	"/services/apexrest/memberportal/directorySearch"
export const ACCOUNT_OPTIONS_PATH = "/services/apexrest/memberportal/options"

/** What the search spy observed: how often it was hit, with which bodies. */
export type DirectorySearchSpy = {
	hits: number
	bodies: DirectorySearchParams[]
}

/**
 * The Member Directory panel's whole org surface — access view, the picklists
 * behind the filters dialog, and a spying search handler. Register per test
 * with `server.use(...org.handlers)`; layer scenario-specific overrides (HTTP
 * errors, gated responses) on top with a later `server.use`.
 */
export function directoryOrg({
	view = directoryView(),
	picklists = {},
	respond = () => directorySearchResults(),
}: {
	view?: DirectoryView
	picklists?: Record<string, PicklistOption[]>
	respond?: (
		body: DirectorySearchParams,
		hits: number,
	) => DirectorySearchResults
} = {}) {
	const spy: DirectorySearchSpy = { hits: 0, bodies: [] }
	const handlers = [
		http.get(DIRECTORY_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(view)),
		),
		http.get(ACCOUNT_OPTIONS_PATH, () =>
			HttpResponse.json(memberPortalEnvelope({ picklists, chapters: [] })),
		),
		http.post(DIRECTORY_SEARCH_PATH, async ({ request }) => {
			const body = (await request.json()) as DirectorySearchParams
			spy.hits += 1
			spy.bodies.push(body)
			return HttpResponse.json(memberPortalEnvelope(respond(body, spy.hits)))
		}),
	]
	return { spy, handlers }
}
