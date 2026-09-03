import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { cancelOrder } from "@/api/orders/cancel-order"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const CANCEL_PATH = "/services/apexrest/memberportal/cancelOrder"

describe("cancelOrder", () => {
	it("refuses a blank id before it reaches the network", async () => {
		await expect(cancelOrder("   ")).rejects.toMatchObject({
			messages: ["An order id is required."],
			status: 400,
		})
	})

	it("posts the trimmed id and returns the result", async () => {
		let body: unknown
		server.use(
			http.post(CANCEL_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(
					memberPortalEnvelope({ statusMessage: "Cancelled", statusCode: 200 }),
				)
			}),
		)

		await expect(cancelOrder(" 006xx1 ")).resolves.toEqual({
			statusMessage: "Cancelled",
			statusCode: 200,
		})
		expect(body).toEqual({ orderId: "006xx1" })
	})

	it("throws the inner refusal — an order past New Lead cannot cancel", async () => {
		server.use(
			http.post(CANCEL_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "Order is no longer cancellable",
						statusCode: 409,
					}),
				),
			),
		)

		await expect(cancelOrder("006xx1")).rejects.toMatchObject({
			messages: ["Order is no longer cancellable"],
			status: 409,
		})
	})

	it("falls back to readable wording for a silent refusal", async () => {
		server.use(
			http.post(CANCEL_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ statusMessage: null, statusCode: 500 }),
				),
			),
		)

		await expect(cancelOrder("006xx1")).rejects.toMatchObject({
			messages: ["Your order could not be cancelled."],
		})
	})

	it("surfaces the server's error message on a transport failure", async () => {
		server.use(
			http.post(CANCEL_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Cancel service down"), {
					status: 500,
				}),
			),
		)

		await expect(cancelOrder("006xx1")).rejects.toMatchObject({
			messages: ["Cancel service down"],
		})
	})
})
