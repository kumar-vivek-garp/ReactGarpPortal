/**
 * Extra hook picked up by the phase sweep: usePayOrder is more than a
 * boilerplate mutation wrapper — it branches on Apex's 200/201 payment codes,
 * writes the legacy checkout cookie, and hands off to Stripe.
 *
 * The Stripe hand-off is `window.location.assign(...)`. jsdom's Location is
 * [LegacyUnforgeable] — non-configurable own properties — so the call can be
 * neither spied on nor replaced. The line executes (jsdom logs "Not
 * implemented: navigation" and returns), so the tests assert the observable
 * tail around it: the checkout cookie, the invalidation, and the resolved
 * status code. The assigned URL itself cannot be asserted.
 */
import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { afterEach, describe, expect, it } from "vitest"

import { ordersQueryKeys } from "@/api/orders"
import { usePayOrder } from "@/hooks/use-pay-order"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderHookWithProviders } from "@/testing/render"

const PAY_ORDER_PATH = "/services/apexrest/memberportal/payOrder"
const CHECKOUT_COOKIE = "garp-checkout-session-token"

afterEach(() => {
	document.cookie = `${CHECKOUT_COOKIE}=; path=/; max-age=0`
})

function payResult(statusCode: number) {
	return HttpResponse.json(
		memberPortalEnvelope({ statusCode, statusMessage: null }),
	)
}

function renderPayOrder() {
	const queryClient = createTestQueryClient()
	queryClient.setQueryData(ordersQueryKeys.list, { seeded: true })
	return renderHookWithProviders(() => usePayOrder(), { queryClient })
}

function ordersInvalidated(queryClient: {
	getQueryState: (key: readonly unknown[]) => { isInvalidated: boolean } | undefined
}) {
	return queryClient.getQueryState(ordersQueryKeys.list)?.isInvalidated
}

describe("usePayOrder", () => {
	it("closes a zero-value order (201) without touching Stripe", async () => {
		server.use(http.post(PAY_ORDER_PATH, () => payResult(201)))

		const { result, queryClient } = renderPayOrder()
		act(() => {
			result.current.mutate("801XX000000ZERO")
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(result.current.data?.statusCode).toBe(201)
		expect(ordersInvalidated(queryClient)).toBe(true)
		// No hand-off: the checkout session cookie must not be written.
		expect(document.cookie).not.toContain(CHECKOUT_COOKIE)
	})

	it("prepares Stripe checkout (200): invalidates, then sets the session cookie", async () => {
		let requestBody: Record<string, string> | null = null
		server.use(
			http.post(PAY_ORDER_PATH, async ({ request }) => {
				requestBody = (await request.json()) as Record<string, string>
				return payResult(200)
			}),
		)

		const { result, queryClient } = renderPayOrder()
		act(() => {
			result.current.mutate("801XX00000STRIPE")
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(requestBody).toEqual({ orderId: "801XX00000STRIPE" })
		expect(ordersInvalidated(queryClient)).toBe(true)
		// Legacy cookie shape: `orders:{orderId}`, URL-encoded.
		expect(document.cookie).toContain(
			`${CHECKOUT_COOKIE}=orders%3A801XX00000STRIPE`,
		)
		// window.location.assign(stripeOrdersCheckoutUrl(...)) runs here but is
		// unassertable in jsdom — see the header comment.
	})

	it("surfaces a refusal without invalidating or writing the cookie", async () => {
		server.use(
			// 500, not 4xx: the SDK transport retries once on 400/401/403.
			http.post(PAY_ORDER_PATH, () =>
				HttpResponse.json(memberPortalError(500, "payment refused"), {
					status: 500,
				}),
			),
		)

		const { result, queryClient } = renderPayOrder()
		act(() => {
			result.current.mutate("801XX0000000BAD")
		})

		await waitFor(() => expect(result.current.isError).toBe(true))
		expect(result.current.error?.message).toBe("payment refused")
		expect(ordersInvalidated(queryClient)).toBe(false)
		expect(document.cookie).not.toContain(CHECKOUT_COOKIE)
	})

	it("rejects a blank order id before any request is made", async () => {
		// No MSW handler on purpose: a request here would fail the strict
		// onUnhandledRequest policy, proving the client-side guard ran first.
		const { result, queryClient } = renderPayOrder()
		act(() => {
			result.current.mutate("   ")
		})

		await waitFor(() => expect(result.current.isError).toBe(true))
		expect(result.current.error?.message).toBe("An order id is required.")
		expect(ordersInvalidated(queryClient)).toBe(false)
	})
})
