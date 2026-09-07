import { act } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { http, HttpResponse } from "msw"

import { AppError } from "@/api/client"
import {
	useExamRegistrationSubmit,
	type ExamSubmitInput,
	type ExamSubmitOutcome,
} from "@/hooks/use-exam-registration-submit"
import {
	examRegisterRequest,
	examRegisterResult,
	verifyCustomerResult,
} from "@/testing/factories/exam"
import { stagedRegisterResult } from "@/testing/factories/exam-payment"
import { memberPortalError } from "@/testing/factories/envelope"
import { EXAMREG_PATH, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

/** Runs the submit mutation once and returns whatever it settled with. */
async function submit(input: ExamSubmitInput) {
	const { result } = renderHookWithProviders(() => useExamRegistrationSubmit())
	let outcome: ExamSubmitOutcome | undefined
	let failure: unknown
	await act(async () => {
		try {
			outcome = await result.current.mutateAsync(input)
		} catch (error) {
			failure = error
		}
	})
	return { outcome, failure }
}

/** Every payment path passes identity first — give it a standing yes. */
function identityHandlers() {
	const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
	server.use(verify.handler)
	return verify
}

describe("useExamRegistrationSubmit — payment", () => {
	it.each(["Wire Transfer", "ACH"] as const)(
		"an offline %s order pays exactly once, polls, and resolves invoiced",
		async (paymentType) => {
			identityHandlers()
			const register = examregPost("register", () =>
				examRegisterResult({ orderId: "801-off" }),
			)
			const pay = examregPost("payOrder", () => ({}))
			// Finance settles wire/ACH days later, so "no payment recorded" is
			// the normal answer and the poll accepts it first time.
			const status = examregPost("paymentStatus", () => ({
				isOrderFound: true,
				isPaymentFound: false,
			}))
			const rollback = examregPost("rollback", () => ({ success: true }))
			server.use(register.handler, pay.handler, status.handler, rollback.handler)

			const { outcome } = await submit({
				request: examRegisterRequest({ paymentType }),
				checkAddress: false,
				session: null,
			})

			expect(register.spy.hits).toBe(1)
			// payOrder is NOT idempotent server-side — exactly once, never retried.
			expect(pay.spy.hits).toBe(1)
			expect(pay.spy.bodies[0]).toEqual({ orderId: "801-off", paymentType })
			expect(status.spy.hits).toBe(1)
			expect(outcome).toMatchObject({ kind: "invoiced", settlementId: "801-off" })
			// A placed order is finance's now — nothing to roll back.
			expect(rollback.spy.hits).toBe(0)
		},
	)

	it("a non-Stripe, non-offline order with an orderId resolves registered", async () => {
		identityHandlers()
		const register = examregPost("register", () =>
			examRegisterResult({ orderId: "801-free", hasBilling: false, total: 0 }),
		)
		const pay = examregPost("payOrder", () => ({}))
		const status = examregPost("paymentStatus", () => ({
			isOrderFound: true,
			isPaymentFound: true,
		}))
		server.use(register.handler, pay.handler, status.handler)

		const { outcome } = await submit({
			request: examRegisterRequest({ paymentType: null }),
			checkAddress: false,
			session: null,
		})

		expect(pay.spy.hits).toBe(1)
		expect(pay.spy.bodies[0]).toEqual({ orderId: "801-free", paymentType: null })
		expect(outcome?.kind).toBe("registered")
	})

	it("no orderId at all resolves registered without touching payOrder", async () => {
		identityHandlers()
		const register = examregPost("register", () =>
			examRegisterResult({ orderId: null, hasBilling: false, total: 0 }),
		)
		const pay = examregPost("payOrder", () => ({}))
		server.use(register.handler, pay.handler)

		const { outcome } = await submit({
			request: examRegisterRequest({ paymentType: "Wire Transfer" }),
			checkAddress: false,
			session: null,
		})

		expect(pay.spy.hits).toBe(0)
		expect(outcome?.kind).toBe("registered")
	})

	it("Stripe + billed starts checkout with the return and cancel URLs", async () => {
		identityHandlers()
		const register = examregPost("register", () =>
			examRegisterResult({ orderId: "801-str", orderNumber: "ORD-77" }),
		)
		const checkout = examregPost<{
			orderId: string
			successUrl: string
			cancelUrl: string
		}>("checkout", () => ({
			checkoutUrl: "https://checkout.stripe.com/c/pay/cs_test",
		}))
		const pay = examregPost("payOrder", () => ({}))
		server.use(register.handler, checkout.handler, pay.handler)

		// The later window.location.href assignment logs jsdom's harmless
		// "Not implemented: navigation" — the request body is the real assertion.
		const { outcome } = await submit({
			request: examRegisterRequest({ paymentType: "Stripe" }),
			checkAddress: false,
			session: null,
		})

		expect(outcome).toEqual({ kind: "redirecting" })
		expect(checkout.spy.hits).toBe(1)
		expect(pay.spy.hits).toBe(0)

		const body = checkout.spy.bodies[0]
		const base = `${window.location.origin}${window.location.pathname}`
		expect(body.orderId).toBe("801-str")
		const success = new URL(body.successUrl)
		expect(`${success.origin}${success.pathname}`).toBe(base)
		expect(success.searchParams.get("stripe_return")).toBe("1")
		expect(success.searchParams.get("oid")).toBe("801-str")
		// The order NUMBER does not travel — the status poll answers with it,
		// and under the deferred flow there is none yet anyway.
		expect(success.searchParams.has("on")).toBe(false)
		// The cancel leg carries the id the rollback depends on.
		const cancel = new URL(body.cancelUrl)
		expect(`${cancel.origin}${cancel.pathname}`).toBe(base)
		expect(cancel.searchParams.get("checkout_cancelled")).toBe("1")
		expect(cancel.searchParams.get("oid")).toBe("801-str")
	})

	it("DEFERRED FLOW: a staged register result goes to checkout under its staged id", async () => {
		identityHandlers()
		const register = examregPost("register", () => stagedRegisterResult())
		const checkout = examregPost<{ orderId: string; successUrl: string }>(
			"checkout",
			() => ({ checkoutUrl: "https://checkout.stripe.com/c/pay/cs_staged" }),
		)
		const pay = examregPost("payOrder", () => ({}))
		server.use(register.handler, checkout.handler, pay.handler)

		const { outcome } = await submit({
			request: examRegisterRequest({ paymentType: "Stripe" }),
			checkAddress: false,
			session: null,
		})

		// No orderId at all — the staged id is what names this registration
		// from here on. Falling through to "registered" here is the live bug
		// this test pins shut: an unpaid card registration shown as complete.
		expect(outcome).toEqual({ kind: "redirecting" })
		expect(checkout.spy.hits).toBe(1)
		expect(checkout.spy.bodies[0].orderId).toBe("a0H-staged")
		expect(new URL(checkout.spy.bodies[0].successUrl).searchParams.get("oid")).toBe(
			"a0H-staged",
		)
		expect(pay.spy.hits).toBe(0)
	})

	it("echoes resumeStagedId in the register body so a retry reuses its row", async () => {
		identityHandlers()
		const register = examregPost<{ resumeStagedId: string | null }>(
			"register",
			() => stagedRegisterResult(),
		)
		const checkout = examregPost("checkout", () => ({
			checkoutUrl: "https://checkout.stripe.com/c/pay/cs_retry",
		}))
		server.use(register.handler, checkout.handler)

		await submit({
			request: examRegisterRequest({ paymentType: "Stripe" }),
			checkAddress: false,
			session: null,
			resumeStagedId: "a0H-staged",
		})

		expect(register.spy.bodies[0].resumeStagedId).toBe("a0H-staged")
	})

	it("Stripe without a checkoutUrl surfaces the server message, then the fallback", async () => {
		identityHandlers()
		const register = examregPost("register", () =>
			examRegisterResult({ orderId: "801-str2", orderNumber: null }),
		)
		const checkout = examregPost("checkout", (_body, hits) => ({
			checkoutUrl: null,
			msg: hits === 1 ? "Stripe is unavailable right now." : "  ",
		}))
		const rollback = examregPost<{ orderId: string; reason: string }>(
			"rollback",
			() => ({ success: true }),
		)
		server.use(register.handler, checkout.handler, rollback.handler)

		const first = await submit({
			request: examRegisterRequest({ paymentType: "Stripe" }),
			checkAddress: false,
			session: null,
		})
		expect(first.failure).toBeInstanceOf(AppError)
		expect((first.failure as AppError).status).toBe(502)
		expect((first.failure as AppError).messages).toEqual([
			"Stripe is unavailable right now.",
		])

		const second = await submit({
			request: examRegisterRequest({ paymentType: "Stripe" }),
			checkAddress: false,
			session: null,
		})
		expect((second.failure as AppError).messages).toEqual([
			"Unable to start checkout.",
		])
		// Each failed attempt left an order behind that nobody will pay —
		// each is rolled back, and the failure shown is still the checkout one.
		expect(rollback.spy.hits).toBe(2)
		expect(rollback.spy.bodies[0]).toEqual({
			orderId: "801-str2",
			reason: "Registration not completed",
		})
	})

	it("a rollback that itself fails does not replace the checkout error", async () => {
		identityHandlers()
		const register = examregPost("register", () =>
			examRegisterResult({ orderId: "801-str3" }),
		)
		const checkout = examregPost("checkout", () => ({ isError: true, msg: "Declined" }))
		server.use(
			register.handler,
			checkout.handler,
			http.post(`${EXAMREG_PATH}/rollback`, () =>
				HttpResponse.json(memberPortalError(400, "Order not found"), { status: 400 }),
			),
		)

		const { failure } = await submit({
			request: examRegisterRequest({ paymentType: "Stripe" }),
			checkAddress: false,
			session: null,
		})

		expect((failure as AppError).messages).toEqual(["Declined"])
	})

	it("Stripe with nothing to bill settles server-side instead of checking out", async () => {
		identityHandlers()
		const register = examregPost("register", () =>
			examRegisterResult({ orderId: "801-zero", hasBilling: false, total: 0 }),
		)
		const checkout = examregPost("checkout", () => ({}))
		const pay = examregPost("payOrder", () => ({}))
		const status = examregPost("paymentStatus", () => ({
			isPaymentFound: true,
			isPaymentSuccess: true,
		}))
		server.use(register.handler, checkout.handler, pay.handler, status.handler)

		const { outcome } = await submit({
			request: examRegisterRequest({ paymentType: "Stripe" }),
			checkAddress: false,
			session: null,
		})

		expect(checkout.spy.hits).toBe(0)
		expect(pay.spy.hits).toBe(1)
		expect(outcome).toMatchObject({ kind: "registered", settlementId: "801-zero" })
	})

	it("VERIFIED QUIRK: a rolled-back order still resolves invoiced", async () => {
		/*
		 * pollPaymentStatus throws AppError(402, "…registration was cancelled")
		 * for a rolled-back order, but the submit mutation swallows it:
		 * `await pollPaymentStatus(...).catch(() => undefined)`. The candidate
		 * is shown an "invoiced" confirmation for a registration that no longer
		 * exists. This asserts the ACTUAL behavior — flagged as a possible
		 * product bug for the team; do NOT "fix" the test to expect a rejection.
		 */
		identityHandlers()
		const register = examregPost("register", () =>
			examRegisterResult({ orderId: "801-rb" }),
		)
		const pay = examregPost("payOrder", () => ({}))
		const status = examregPost("paymentStatus", () => ({
			isOrderFound: true,
			isOrderRolledback: true,
		}))
		server.use(register.handler, pay.handler, status.handler)

		const { outcome, failure } = await submit({
			request: examRegisterRequest({ paymentType: "Wire Transfer" }),
			checkAddress: false,
			session: null,
		})

		expect(failure).toBeUndefined()
		expect(status.spy.hits).toBe(1)
		expect(outcome?.kind).toBe("invoiced")
	})
})
