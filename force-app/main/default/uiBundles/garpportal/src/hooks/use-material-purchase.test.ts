import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { afterEach, describe, expect, it } from "vitest"

import {
	memberPortalError,
} from "@/testing/factories/envelope"
import {
	materialPurchaseResult,
	materialShipTo,
} from "@/testing/factories/study-material-purchase"
import {
	MATERIAL_PURCHASE_PATH,
	materialPurchaseOrg,
	ORDER_CHECKOUT_PATH,
} from "@/testing/msw/handlers/study-materials"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

import {
	CheckoutUnavailableError,
	useMaterialPurchaseSubmit,
} from "./use-material-purchase"

const request = { productCode: "SCRH", shipTo: materialShipTo() }

afterEach(() => {
	// The happy path assigns a hash-only URL — the one navigation jsdom
	// implements — so the redirect is observable; undo it here.
	window.history.replaceState(null, "", "/study-materials/purchase/SCRH")
})

describe("useMaterialPurchaseSubmit — the sequence", () => {
	it("raises the order, opens checkout with both return addresses, and leaves", async () => {
		window.history.replaceState(null, "", "/study-materials/purchase/SCRH")
		const org = materialPurchaseOrg()
		server.use(...org.handlers)

		const { result } = renderHookWithProviders(() => useMaterialPurchaseSubmit())
		await act(async () => {
			await result.current.mutateAsync(request)
		})

		expect(org.purchaseSpy.bodies).toEqual([request])
		expect(org.checkoutSpy.bodies).toEqual([
			{
				orderId: "006PUR00000000001",
				successUrl: `${window.location.origin}/study-materials?purchased=1`,
				cancelUrl: `${window.location.origin}/study-materials/purchase/SCRH?checkout_cancelled=1`,
			},
		])
		expect(window.location.hash).toBe("#hosted-checkout")
	})

	it("hands the staged row to checkout under the deferred flow", async () => {
		const org = materialPurchaseOrg({
			purchaseRespond: () =>
				materialPurchaseResult({
					orderId: null,
					orderNumber: null,
					stagedId: "a0H000000000001",
					registrationRef: "REG-0001",
				}),
		})
		server.use(...org.handlers)

		const { result } = renderHookWithProviders(() => useMaterialPurchaseSubmit())
		await act(async () => {
			await result.current.mutateAsync(request)
		})

		expect(org.checkoutSpy.bodies[0]?.orderId).toBe("a0H000000000001")
	})

	it("reopens checkout for the order already raised rather than raising another", async () => {
		const org = materialPurchaseOrg()
		server.use(...org.handlers)

		const { result } = renderHookWithProviders(() => useMaterialPurchaseSubmit())
		await act(async () => {
			await result.current.mutateAsync(request)
		})
		// Back from the provider, same item and address, Continue again.
		await act(async () => {
			await result.current.mutateAsync(request)
		})

		expect(org.purchaseSpy.hits).toBe(1)
		expect(org.checkoutSpy.hits).toBe(2)
		expect(org.checkoutSpy.bodies[1]?.orderId).toBe("006PUR00000000001")

		// A different address is a different order.
		await act(async () => {
			await result.current.mutateAsync({
				...request,
				shipTo: { ...request.shipTo, city: "Hoboken" },
			})
		})
		expect(org.purchaseSpy.hits).toBe(2)
	})

	it("stops when no id comes back — nothing to pay for", async () => {
		const org = materialPurchaseOrg({
			purchaseRespond: () =>
				materialPurchaseResult({ orderId: null, stagedId: null, statusMessage: "Odd" }),
		})
		server.use(...org.handlers)

		const { result } = renderHookWithProviders(() => useMaterialPurchaseSubmit())
		await act(async () => {
			await result.current.mutateAsync(request).catch(() => undefined)
		})

		await waitFor(() => expect(result.current.isError).toBe(true))
		expect(result.current.error).toMatchObject({ messages: ["Odd"] })
		expect(org.checkoutSpy.hits).toBe(0)
	})
})

describe("useMaterialPurchaseSubmit — failures", () => {
	it("surfaces the purchase refusal, calls it exactly once, and never reaches checkout", async () => {
		const org = materialPurchaseOrg()
		server.use(...org.handlers)
		let purchaseHits = 0
		server.use(
			http.post(MATERIAL_PURCHASE_PATH, () => {
				purchaseHits += 1
				return HttpResponse.json(
					memberPortalError(501, "A full shipping address is required for a printed book."),
					{ status: 501 },
				)
			}),
		)

		const { result } = renderHookWithProviders(() => useMaterialPurchaseSubmit())
		await act(async () => {
			await result.current.mutateAsync(request).catch(() => undefined)
		})

		await waitFor(() => expect(result.current.isError).toBe(true))
		expect(result.current.error).toMatchObject({
			messages: ["A full shipping address is required for a printed book."],
		})
		expect(purchaseHits).toBe(1)
		expect(org.checkoutSpy.hits).toBe(0)
	})

	it("reports a saved order when checkout will not open under the immediate flow", async () => {
		const org = materialPurchaseOrg()
		server.use(...org.handlers)
		server.use(
			http.post(ORDER_CHECKOUT_PATH, () =>
				HttpResponse.json(memberPortalError(501, "Open Order not found"), { status: 501 }),
			),
		)

		const { result } = renderHookWithProviders(() => useMaterialPurchaseSubmit())
		await act(async () => {
			await result.current.mutateAsync(request).catch(() => undefined)
		})

		await waitFor(() => expect(result.current.isError).toBe(true))
		const error = result.current.error
		expect(error).toBeInstanceOf(CheckoutUnavailableError)
		expect((error as CheckoutUnavailableError).purchase.orderNumber).toBe("INV-0009")
		expect((error as CheckoutUnavailableError).messages[0]).toContain("Order History")
		expect(window.location.hash).toBe("")
	})

	it("says nothing was charged when checkout fails for a staged row", async () => {
		const org = materialPurchaseOrg({
			purchaseRespond: () =>
				materialPurchaseResult({ orderId: null, orderNumber: null, stagedId: "a0H1" }),
		})
		server.use(...org.handlers)
		server.use(
			http.post(ORDER_CHECKOUT_PATH, () =>
				HttpResponse.json(memberPortalError(502, "Stripe unavailable"), { status: 502 }),
			),
		)

		const { result } = renderHookWithProviders(() => useMaterialPurchaseSubmit())
		await act(async () => {
			await result.current.mutateAsync(request).catch(() => undefined)
		})

		await waitFor(() => expect(result.current.isError).toBe(true))
		expect((result.current.error as CheckoutUnavailableError).messages[0]).toContain(
			"Nothing has been charged",
		)
	})
})
