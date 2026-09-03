import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	turnOffMembershipAutoRenew,
	turnOnMembershipAutoRenew,
} from "@/api/account/auto-renew"
import { AppError } from "@/api/client"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const OFF_PATH = "/services/apexrest/memberportal/membershipAutoRenewOff"
const ON_PATH = "/services/apexrest/memberportal/membershipAutoRenewOn"

describe("turnOffMembershipAutoRenew", () => {
	it("posts an empty body and returns the result", async () => {
		let body: unknown
		server.use(
			http.post(OFF_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(
					memberPortalEnvelope({ statusMessage: "Auto-renew off", statusCode: 200 }),
				)
			}),
		)

		await expect(turnOffMembershipAutoRenew()).resolves.toEqual({
			statusMessage: "Auto-renew off",
			statusCode: 200,
		})
		expect(body).toEqual({})
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.post(OFF_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Contract locked"), {
					status: 500,
				}),
			),
		)

		const failure = turnOffMembershipAutoRenew()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({ messages: ["Contract locked"] })
	})
})

describe("turnOnMembershipAutoRenew", () => {
	it("passes needPaymentInfo through when true, with the Stripe order id", async () => {
		server.use(
			http.post(ON_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						needPaymentInfo: true,
						orderId: "006xx1",
					}),
				),
			),
		)

		await expect(turnOnMembershipAutoRenew()).resolves.toMatchObject({
			needPaymentInfo: true,
			orderId: "006xx1",
		})
	})

	it("coerces a missing needPaymentInfo to false", async () => {
		server.use(
			http.post(ON_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ statusMessage: "Enabled", statusCode: 200 }),
				),
			),
		)

		await expect(turnOnMembershipAutoRenew()).resolves.toMatchObject({
			needPaymentInfo: false,
		})
	})
})
