import { act } from "@testing-library/react"
import { describe, expect, it } from "vitest"

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
import { examregPost } from "@/testing/msw/handlers/examreg"
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
			const status = examregPost("paymentStatus", () => ({
				isOrderFound: true,
				isPaymentFound: true,
			}))
			server.use(register.handler, pay.handler, status.handler)

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
			expect(outcome?.kind).toBe("invoiced")
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
		expect(body.cancelUrl).toBe(base)
		const success = new URL(body.successUrl)
		expect(`${success.origin}${success.pathname}`).toBe(base)
		expect(success.searchParams.get("stripe_return")).toBe("1")
		expect(success.searchParams.get("oid")).toBe("801-str")
		expect(success.searchParams.get("on")).toBe("ORD-77")
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
		server.use(register.handler, checkout.handler)

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
		}))
		server.use(register.handler, checkout.handler, pay.handler, status.handler)

		const { outcome } = await submit({
			request: examRegisterRequest({ paymentType: "Stripe" }),
			checkAddress: false,
			session: null,
		})

		expect(checkout.spy.hits).toBe(0)
		expect(pay.spy.hits).toBe(1)
		expect(outcome?.kind).toBe("registered")
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
