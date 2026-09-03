import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchOrderDetail } from "@/api/orders/order-detail"
import { orderDetailQueryOptions } from "@/api/orders/query-options"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { portalOrder } from "@/testing/factories/orders"
import { server } from "@/testing/msw/server"

const ORDER_DETAIL_PATH = "/services/apexrest/memberportal/orderDetail"

describe("fetchOrderDetail", () => {
	it("refuses a blank order number before it reaches the network", async () => {
		await expect(fetchOrderDetail("  ")).rejects.toMatchObject({
			messages: ["An order number is required."],
			status: 400,
		})
	})

	it("sends the key as a URL-encoded query param and unwraps the order", async () => {
		let search: URLSearchParams | undefined
		const detail = {
			statusMessage: null,
			statusCode: 200,
			order: portalOrder({ invoiceNumber: "INV 42/A" }),
		}
		server.use(
			http.get(ORDER_DETAIL_PATH, ({ request }) => {
				search = new URL(request.url).searchParams
				return HttpResponse.json(memberPortalEnvelope(detail))
			}),
		)

		await expect(fetchOrderDetail(" INV 42/A ")).resolves.toEqual(detail)
		expect(search?.get("orderNumber")).toBe("INV 42/A")
	})

	it("throws the inner refusal even on an HTTP 200", async () => {
		server.use(
			http.get(ORDER_DETAIL_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "Order not found",
						statusCode: 404,
						order: null,
					}),
				),
			),
		)

		await expect(fetchOrderDetail("INV-0404")).rejects.toMatchObject({
			messages: ["Order not found"],
			status: 404,
		})
	})

	it("surfaces the server's error message on a transport failure", async () => {
		server.use(
			http.get(ORDER_DETAIL_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Order lookup down"), {
					status: 500,
				}),
			),
		)

		await expect(fetchOrderDetail("INV-1")).rejects.toMatchObject({
			messages: ["Order lookup down"],
		})
	})
})

describe("orderDetailQueryOptions", () => {
	it("trims the key and disables itself when blank", () => {
		const options = orderDetailQueryOptions(" INV-7 ")
		expect(options.queryKey).toEqual(["orders", "detail", "INV-7"])
		expect(options.enabled).toBe(true)
		expect(orderDetailQueryOptions("   ").enabled).toBe(false)
	})
})
