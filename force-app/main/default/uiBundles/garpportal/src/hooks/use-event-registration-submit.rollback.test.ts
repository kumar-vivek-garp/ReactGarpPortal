import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import type {
	EventRegisterRequest,
	EventRegisterResult,
} from "@/api/registration/event-types"
import { useEventRegistrationSubmit } from "@/hooks/use-event-registration-submit"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

const REGISTER_PATH = "/services/apexrest/examreg/event/register"
const CHECKOUT_PATH = "/services/apexrest/examreg/checkout"
const ROLLBACK_PATH = "/services/apexrest/examreg/event/rollback"

const CHECKOUT_FAILED_MESSAGE =
	"We could not open the payment page, so your registration was not completed. Please try again."

const baseRequest: EventRegisterRequest = {
	variant: "event",
	eventId: "evt-1",
	email: "ada@example.test",
	firstName: "Ada",
	lastName: "Lovelace",
}

function paidResult(): EventRegisterResult {
	return {
		registrationId: "reg-1",
		registrationNumber: "ER-1001",
		contactId: null,
		leadId: null,
		isFree: false,
		message: null,
		orderId: "o-1",
		orderNumber: "1001",
		amountDue: 150,
	}
}

function submit() {
	const { result } = renderHookWithProviders(() => useEventRegistrationSubmit())
	act(() => {
		result.current.mutate({ request: baseRequest, variant: "event" })
	})
	return result
}

/**
 * The compensating transaction: past `register` a paid submit has written
 * records, and an orphaned pending order makes every later load report
 * `alreadyRegistered` — permanently locking the person out. So when checkout
 * will not open, the hook must roll the registration back BEFORE surfacing
 * the failure.
 */
describe("useEventRegistrationSubmit — rollback", () => {
	it("rolls back before throwing when checkout answers with no URL", async () => {
		const sequence: string[] = []
		let rollbackBody: Record<string, string> | null = null
		server.use(
			http.post(REGISTER_PATH, () => {
				sequence.push("register")
				return HttpResponse.json(memberPortalEnvelope(paidResult()))
			}),
			http.post(CHECKOUT_PATH, () => {
				sequence.push("checkout")
				return HttpResponse.json(
					memberPortalEnvelope({
						checkoutUrl: null,
						isError: true,
						msg: "no session",
					}),
				)
			}),
			http.post(ROLLBACK_PATH, async ({ request }) => {
				sequence.push("rollback")
				rollbackBody = (await request.json()) as Record<string, string>
				return HttpResponse.json(memberPortalEnvelope({ rolledBack: true }))
			}),
		)

		const result = submit()

		await waitFor(() => expect(result.current.isError).toBe(true))
		// Exactly one rollback, and it ran before the error surfaced.
		expect(sequence).toEqual(["register", "checkout", "rollback"])
		expect(rollbackBody).toEqual({
			orderId: "o-1",
			reason: "Checkout unavailable",
		})
		expect(result.current.error).toBeInstanceOf(AppError)
		expect((result.current.error as AppError).messages).toEqual([
			CHECKOUT_FAILED_MESSAGE,
		])
		expect((result.current.error as AppError).status).toBe(502)
	})

	it("rolls back when the checkout call itself fails", async () => {
		let rollbackHits = 0
		server.use(
			http.post(REGISTER_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(paidResult())),
			),
			// 500, not 4xx: the SDK transport retries once on 400/401/403.
			http.post(CHECKOUT_PATH, () =>
				HttpResponse.json(memberPortalError(500, "checkout down"), {
					status: 500,
				}),
			),
			http.post(ROLLBACK_PATH, () => {
				rollbackHits += 1
				return HttpResponse.json(memberPortalEnvelope({ rolledBack: true }))
			}),
		)

		const result = submit()

		await waitFor(() => expect(result.current.isError).toBe(true))
		expect(rollbackHits).toBe(1)
		// The surfaced error is the hook's own, not the swallowed transport one.
		expect((result.current.error as AppError).messages).toEqual([
			CHECKOUT_FAILED_MESSAGE,
		])
	})

	it("still surfaces the checkout error when the rollback itself fails", async () => {
		let rollbackHits = 0
		server.use(
			http.post(REGISTER_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(paidResult())),
			),
			http.post(CHECKOUT_PATH, () =>
				HttpResponse.json(memberPortalEnvelope({ checkoutUrl: null })),
			),
			http.post(ROLLBACK_PATH, () => {
				rollbackHits += 1
				return HttpResponse.json(memberPortalError(500, "rollback down"), {
					status: 500,
				})
			}),
		)

		const result = submit()

		await waitFor(() => expect(result.current.isError).toBe(true))
		expect(rollbackHits).toBe(1)
		expect((result.current.error as AppError).messages).toEqual([
			CHECKOUT_FAILED_MESSAGE,
		])
	})

	it("surfaces a register failure untouched — no checkout, no rollback to run", async () => {
		let checkoutHits = 0
		let rollbackHits = 0
		server.use(
			http.post(REGISTER_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Registration closed"), {
					status: 500,
				}),
			),
			http.post(CHECKOUT_PATH, () => {
				checkoutHits += 1
				return HttpResponse.json(memberPortalEnvelope({}))
			}),
			http.post(ROLLBACK_PATH, () => {
				rollbackHits += 1
				return HttpResponse.json(memberPortalEnvelope({}))
			}),
		)

		const result = submit()

		await waitFor(() => expect(result.current.isError).toBe(true))
		expect((result.current.error as AppError).messages).toEqual([
			"Registration closed",
		])
		expect(checkoutHits).toBe(0)
		expect(rollbackHits).toBe(0)
	})
})
