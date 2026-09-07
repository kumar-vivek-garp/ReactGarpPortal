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
const RETURN_URL = "https://portal.example/my-account?status=autorenewsetupcomplete"

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
	it("posts the return URL and hands back Stripe's setup page", async () => {
		let body: unknown
		server.use(
			http.post(ON_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "Call Succuess",
						statusCode: 200,
						needPaymentInfo: true,
						setupUrl: "https://checkout.stripe.com/c/setup/abc",
					}),
				)
			}),
		)

		await expect(turnOnMembershipAutoRenew(RETURN_URL)).resolves.toEqual({
			statusMessage: "Call Succuess",
			statusCode: 200,
			needPaymentInfo: true,
			setupUrl: "https://checkout.stripe.com/c/setup/abc",
		})
		expect(body).toEqual({ returnUrl: RETURN_URL })
	})

	it("treats a 200 with no setup URL as a failure — there is nowhere to send the member", async () => {
		server.use(
			http.post(ON_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "No Stripe customer on file",
						statusCode: 200,
						setupUrl: null,
					}),
				),
			),
		)

		const failure = turnOnMembershipAutoRenew(RETURN_URL)
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["No Stripe customer on file"],
		})
	})

	it("surfaces the server's refusal as AppError", async () => {
		server.use(
			// 500, not 401: the SDK transport retries once on 400/401/403.
			http.post(ON_PATH, () =>
				HttpResponse.json(
					memberPortalError(500, "Active Membership contract not found"),
					{ status: 500 },
				),
			),
		)

		await expect(turnOnMembershipAutoRenew(RETURN_URL)).rejects.toMatchObject({
			messages: ["Active Membership contract not found"],
		})
	})
})
