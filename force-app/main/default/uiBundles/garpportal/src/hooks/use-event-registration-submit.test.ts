import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { afterEach, describe, expect, it } from "vitest"

import type {
	EventRegisterRequest,
	EventRegisterResult,
} from "@/api/registration/event-types"
import {
	useDeclineEventRsvp,
	useEventRegistrationSubmit,
} from "@/hooks/use-event-registration-submit"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

const REGISTER_PATH = "/services/apexrest/examreg/event/register"
const CHECKOUT_PATH = "/services/apexrest/examreg/checkout"
const DECLINE_PATH = "/services/apexrest/examreg/event/rsvpDecline"

const baseRequest: EventRegisterRequest = {
	variant: "event",
	eventId: "evt-1",
	email: "ada@example.test",
	firstName: "Ada",
	lastName: "Lovelace",
}

function registerResult(
	overrides: Partial<EventRegisterResult> = {},
): EventRegisterResult {
	return {
		registrationId: "reg-1",
		registrationNumber: "ER-1001",
		contactId: null,
		leadId: null,
		isFree: true,
		message: null,
		orderId: null,
		orderNumber: null,
		amountDue: 0,
		...overrides,
	}
}

/**
 * The submit sequence's happy paths. The compensating-transaction (rollback)
 * behaviour lives in `use-event-registration-submit.rollback.test.ts`.
 */
describe("useEventRegistrationSubmit", () => {
	afterEach(() => {
		// The paid path assigns `window.location.href`. The tests hand it a
		// hash-only URL — the one navigation jsdom implements — so the redirect
		// is observable; undo it here so later tests start from "/".
		window.history.replaceState(null, "", "/")
	})

	it("completes a free registration without touching checkout", async () => {
		let checkoutHits = 0
		server.use(
			http.post(REGISTER_PATH, ({ request }) => {
				// Plain events omit `eventType` — the Apex default.
				expect(new URL(request.url).searchParams.has("eventType")).toBe(false)
				return HttpResponse.json(memberPortalEnvelope(registerResult()))
			}),
			http.post(CHECKOUT_PATH, () => {
				checkoutHits += 1
				return HttpResponse.json(memberPortalEnvelope({}))
			}),
		)

		const { result } = renderHookWithProviders(() =>
			useEventRegistrationSubmit(),
		)
		act(() => {
			result.current.mutate({ request: baseRequest, variant: "event" })
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(result.current.data).toEqual({
			kind: "registered",
			result: registerResult(),
		})
		expect(checkoutHits).toBe(0)
	})

	it("keys the paid branch on the RESULT: isFree false with no orderId completes without checkout", async () => {
		let checkoutHits = 0
		server.use(
			http.post(REGISTER_PATH, ({ request }) => {
				// Non-event variants ride in the query string, never the body.
				expect(new URL(request.url).searchParams.get("eventType")).toBe(
					"webcast",
				)
				return HttpResponse.json(
					memberPortalEnvelope(
						registerResult({ isFree: false, orderId: null }),
					),
				)
			}),
			http.post(CHECKOUT_PATH, () => {
				checkoutHits += 1
				return HttpResponse.json(memberPortalEnvelope({}))
			}),
		)

		const { result } = renderHookWithProviders(() =>
			useEventRegistrationSubmit(),
		)
		act(() => {
			result.current.mutate({ request: baseRequest, variant: "webcast" })
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(result.current.data?.kind).toBe("registered")
		expect(checkoutHits).toBe(0)
	})

	it("hands a priced order to checkout with return URLs built from this route, then redirects", async () => {
		let checkoutBody: Record<string, string> | null = null
		server.use(
			http.post(REGISTER_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						registerResult({
							isFree: false,
							orderId: "o-1",
							orderNumber: "1001",
							amountDue: 150,
						}),
					),
				),
			),
			http.post(CHECKOUT_PATH, async ({ request }) => {
				checkoutBody = (await request.json()) as Record<string, string>
				return HttpResponse.json(
					memberPortalEnvelope({ checkoutUrl: "#hosted-checkout" }),
				)
			}),
		)

		const { result } = renderHookWithProviders(() =>
			useEventRegistrationSubmit(),
		)
		act(() => {
			result.current.mutate({ request: baseRequest, variant: "event" })
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(result.current.data).toEqual({ kind: "redirecting" })

		// Success carries the stripe_return trio; cancel is NOT bare — it keeps
		// the oid the abandoned-checkout rollback depends on.
		expect(checkoutBody).toEqual({
			orderId: "o-1",
			successUrl: "http://localhost:3000/?stripe_return=1&oid=o-1&on=1001",
			cancelUrl: "http://localhost:3000/?checkout_cancelled=1&oid=o-1",
		})
		// The browser was actually sent to the hosted page.
		expect(window.location.hash).toBe("#hosted-checkout")
	})
})

describe("useDeclineEventRsvp", () => {
	it("posts the decline body and resolves", async () => {
		let declineBody: Record<string, string> | null = null
		server.use(
			http.post(DECLINE_PATH, async ({ request }) => {
				declineBody = (await request.json()) as Record<string, string>
				return HttpResponse.json(memberPortalEnvelope({ declined: true }))
			}),
		)

		const { result } = renderHookWithProviders(() => useDeclineEventRsvp())
		act(() => {
			result.current.mutate({
				eventId: "evt-1",
				userEmail: "ada@example.test",
			})
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(declineBody).toEqual({
			eventId: "evt-1",
			userEmail: "ada@example.test",
		})
	})
})
