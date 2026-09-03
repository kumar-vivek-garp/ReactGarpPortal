import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { fetchOrders } from "@/api/orders/orders"
import type { OrdersView } from "@/api/orders/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { portalOrder } from "@/testing/factories/orders"
import { server } from "@/testing/msw/server"

const ORDERS_PATH = "/services/apexrest/memberportal/orders"

describe("fetchOrders", () => {
	it("unwraps the purchase history buckets", async () => {
		const view: OrdersView = {
			unpaidOrders: [portalOrder()],
			paidOrders: [portalOrder({ id: "006xx2", isPaid: true, canPay: false })],
		}
		server.use(
			http.get(ORDERS_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(view)),
			),
		)

		await expect(fetchOrders()).resolves.toEqual(view)
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.get(ORDERS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Orders backend down"), {
					status: 500,
				}),
			),
		)

		const failure = fetchOrders()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Orders backend down"],
		})
	})
})
