import { http, HttpResponse } from "msw"

import { memberPortalEnvelope } from "@/testing/factories/envelope"

/** `GARP_ExamReg_API` — the one `@RestResource` every programme shares. */
export const EXAMREG_PATH = "/services/apexrest/examreg"

/** What a spying handler observed: how often it was hit, with which bodies. */
export type ExamregSpy<TBody> = {
	hits: number
	bodies: TBody[]
}

/**
 * A POST handler that counts hits, records each JSON body, and answers with
 * the portal envelope around `respond`'s payload. Register it per test with
 * `server.use(handler)`; anything scenario-specific beyond a per-hit payload
 * (HTTP errors, gated responses) belongs in a hand-written handler instead.
 */
export function examregPost<TBody = Record<string, unknown>>(
	action: string,
	respond: (body: TBody, hits: number) => unknown,
) {
	const spy: ExamregSpy<TBody> = { hits: 0, bodies: [] }
	const handler = http.post(
		`${EXAMREG_PATH}/${action}`,
		async ({ request }) => {
			const body = (await request.json()) as TBody
			spy.hits += 1
			spy.bodies.push(body)
			return HttpResponse.json(memberPortalEnvelope(respond(body, spy.hits)))
		},
	)
	return { spy, handler }
}

/** The GET twin of `examregPost` — no body to record. */
export function examregGet(action: string, respond: (hits: number) => unknown) {
	const spy = { hits: 0 }
	const handler = http.get(`${EXAMREG_PATH}/${action}`, () => {
		spy.hits += 1
		return HttpResponse.json(memberPortalEnvelope(respond(spy.hits)))
	})
	return { spy, handler }
}
