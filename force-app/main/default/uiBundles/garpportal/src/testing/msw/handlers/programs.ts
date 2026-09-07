import { http, HttpResponse } from "msw"

import type { EppOptInInput } from "@/api/programs"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { eppOptInResult } from "@/testing/factories/programs"

export const EPP_OPT_IN_PATH = "/services/apexrest/memberportal/eppOptIn"

/** What the opt-in spy observed: how often it was hit, with which body. */
export type EppOptInSpy = {
	hits: number
	bodies: EppOptInInput[]
}

/**
 * A spying `eppOptIn` write answering the memberportal envelope. Register with
 * `server.use(handler)`; layer a refusal on top with a later `server.use`.
 */
export function eppOptInHandler(
	respond: (body: EppOptInInput, hits: number) => Response = () =>
		HttpResponse.json(memberPortalEnvelope(eppOptInResult())),
): { spy: EppOptInSpy; handler: ReturnType<typeof http.post> } {
	const spy: EppOptInSpy = { hits: 0, bodies: [] }
	const handler = http.post(EPP_OPT_IN_PATH, async ({ request }) => {
		const body = (await request.json()) as EppOptInInput
		spy.hits += 1
		spy.bodies.push(body)
		return respond(body, spy.hits)
	})
	return { spy, handler }
}
