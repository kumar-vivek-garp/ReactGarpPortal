import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { orderCheckoutResult } from "@/testing/factories/study-material-purchase"
import { server } from "@/testing/msw/server"

import { orderCheckout, ORDER_CHECKOUT_PATH } from "./order-checkout"

const request = {
	orderId: "006PUR00000000001",
	successUrl: "https://portal.example/study-materials?purchased=1",
	cancelUrl: "https://portal.example/study-materials/purchase/SCRH?checkout_cancelled=1",
}

describe("orderCheckout", () => {
	it("posts the id and both return addresses, and hands back the hosted page", async () => {
		let body: unknown = null
		server.use(
			http.post(ORDER_CHECKOUT_PATH, async ({ request: incoming }) => {
				body = await incoming.json()
				return HttpResponse.json(
					memberPortalEnvelope(
						orderCheckoutResult({ checkoutUrl: "https://checkout.stripe.com/c/pay/cs_1" }),
					),
				)
			}),
		)

		const session = await orderCheckout(request)
		expect(body).toEqual(request)
		expect(session).toEqual({
			checkoutUrl: "https://checkout.stripe.com/c/pay/cs_1",
			orderNumber: "INV-0009",
		})
	})

	it("throws the service's refusal — an order that is not open", async () => {
		server.use(
			http.post(ORDER_CHECKOUT_PATH, () =>
				HttpResponse.json(memberPortalError(501, "Open Order not found"), {
					status: 501,
				}),
			),
		)

		const failure = orderCheckout(request)
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Open Order not found"],
		})
	})

	it("throws when a 200 carries no checkout URL", async () => {
		server.use(
			http.post(ORDER_CHECKOUT_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 200,
						statusMessage: "We could not open the payment page.",
						checkoutUrl: "  ",
					}),
				),
			),
		)

		await expect(orderCheckout(request)).rejects.toMatchObject({
			messages: ["We could not open the payment page."],
		})
	})
})
