import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { payOrder } from "@/api/orders/pay-order"
import { server } from "@/testing/msw/server"

const PAY_PATH = "/services/apexrest/memberportal/payOrder"

/** `payOrder` lifts its result's statusCode onto the envelope — mirror that. */
function payEnvelope(
	statusCode: number,
	data?: { statusMessage: string | null; statusCode?: number },
	errorMessage: string | null = null,
) {
	return HttpResponse.json({
		status: statusCode < 400 ? "Success" : "Error",
		statusCode,
		errorMessage,
		...(data === undefined ? {} : { data }),
	})
}

describe("payOrder", () => {
	it("refuses a blank id before it reaches the network", async () => {
		await expect(payOrder("  ")).rejects.toMatchObject({
			messages: ["An order id is required."],
			status: 400,
		})
	})

	it("accepts 201 — a zero-value order that closed without Stripe", async () => {
		server.use(
			http.post(PAY_PATH, () =>
				payEnvelope(201, { statusMessage: "Order closed", statusCode: 201 }),
			),
		)

		await expect(payOrder("006xx1")).resolves.toEqual({
			statusCode: 201,
			statusMessage: "Order closed",
		})
	})

	it("falls back to the envelope statusCode when the payload has none", async () => {
		server.use(
			http.post(PAY_PATH, () => payEnvelope(200, { statusMessage: null })),
		)

		await expect(payOrder("006xx1")).resolves.toEqual({
			statusCode: 200,
			statusMessage: null,
		})
	})

	it("prefers the envelope errorMessage on a refusal", async () => {
		server.use(
			http.post(PAY_PATH, () =>
				payEnvelope(502, { statusMessage: "inner detail" }, " Payment window closed "),
			),
		)

		await expect(payOrder("006xx1")).rejects.toMatchObject({
			messages: ["Payment window closed"],
			status: 502,
		})
	})

	it("falls back to the payload statusMessage, then generic wording", async () => {
		server.use(
			http.post(PAY_PATH, () =>
				payEnvelope(502, { statusMessage: "Order already paid" }),
			),
		)
		await expect(payOrder("006xx1")).rejects.toMatchObject({
			messages: ["Order already paid"],
		})

		server.use(http.post(PAY_PATH, () => payEnvelope(502)))
		await expect(payOrder("006xx1")).rejects.toMatchObject({
			messages: ["This order could not be prepared for payment."],
		})
	})

	it("throws when a 200 envelope carries no payment result at all", async () => {
		server.use(http.post(PAY_PATH, () => payEnvelope(200)))

		await expect(payOrder("006xx1")).rejects.toMatchObject({
			messages: ["No payment result was returned."],
			status: 200,
		})
	})
})
