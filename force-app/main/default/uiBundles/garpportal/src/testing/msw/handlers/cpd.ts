import { http, HttpResponse } from "msw"

import type {
	CpdActivityFieldInfo,
	CpdActivityView,
	CpdProgramView,
} from "@/api/cpd"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { cpdActivityView, cpdProgramView } from "@/testing/factories/cpd"

export const CPD_ACTIVITIES_PATH =
	"/services/apexrest/memberportal/cpdActivities"
export const CPD_ACTIVITY_TYPES_PATH =
	"/services/apexrest/memberportal/cpdActivityTypes"
export const CPD_OPTIONS_PATH = "/services/apexrest/memberportal/options"
export const CPD_PROGRAM_PATH = "/services/apexrest/memberportal/cpdProgram"
export const CPD_CLAIM_DELETE_PATH =
	"/services/apexrest/memberportal/cpdClaimDelete"

/** What the catalogue spy observed: how often, with which query params. */
export type CpdActivitiesSpy = {
	hits: number
	params: URLSearchParams[]
}

/**
 * The Browse Credit Opportunities org surface — the paged catalogue plus the
 * two lookups the Add Credits dialog loads when it opens. Register per test
 * with `server.use(...org.handlers)`; layer error overrides on top with a
 * later `server.use`.
 */
export function cpdActivitiesOrg({
	respond = () => cpdActivityView(),
	activityTypes = [],
}: {
	respond?: (params: URLSearchParams, hits: number) => CpdActivityView
	activityTypes?: CpdActivityFieldInfo[]
} = {}) {
	const spy: CpdActivitiesSpy = { hits: 0, params: [] }
	const handlers = [
		http.get(CPD_ACTIVITIES_PATH, ({ request }) => {
			const params = new URL(request.url).searchParams
			spy.hits += 1
			spy.params.push(params)
			return HttpResponse.json(
				memberPortalEnvelope(respond(params, spy.hits)),
			)
		}),
		http.get(CPD_ACTIVITY_TYPES_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(activityTypes)),
		),
		http.get(CPD_OPTIONS_PATH, () =>
			HttpResponse.json(memberPortalEnvelope({ picklists: {}, chapters: [] })),
		),
	]
	return { spy, handlers }
}

/**
 * The `/cpd` page's org surface — the program payload, the claim-delete
 * write (spied), and the lookups the claim/view dialogs load on open.
 */
export function cpdProgramOrg({
	view = cpdProgramView(),
	activityTypes = [],
	deleteRespond = () =>
		HttpResponse.json(
			memberPortalEnvelope({ status: "Success", msg: null, claimId: null }),
		),
}: {
	view?: CpdProgramView
	activityTypes?: CpdActivityFieldInfo[]
	deleteRespond?: (body: { claimId?: string }, hits: number) => Response
} = {}) {
	const deleteSpy = { hits: 0, bodies: [] as { claimId?: string }[] }
	const handlers = [
		http.get(CPD_PROGRAM_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(view)),
		),
		http.get(CPD_ACTIVITY_TYPES_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(activityTypes)),
		),
		http.get(CPD_OPTIONS_PATH, () =>
			HttpResponse.json(memberPortalEnvelope({ picklists: {}, chapters: [] })),
		),
		http.post(CPD_CLAIM_DELETE_PATH, async ({ request }) => {
			const body = (await request.json()) as { claimId?: string }
			deleteSpy.hits += 1
			deleteSpy.bodies.push(body)
			return deleteRespond(body, deleteSpy.hits)
		}),
	]
	return { deleteSpy, handlers }
}
