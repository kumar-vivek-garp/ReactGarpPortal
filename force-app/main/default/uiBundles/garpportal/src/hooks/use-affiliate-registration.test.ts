import { act } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"

import type {
	AffiliateRegisterRequest,
	AffiliateRegistrationLoad,
	RegisterResult,
} from "@/api/registration"
import {
	MustSignInError,
	useAffiliateRegistration,
	useAffiliateSignUp,
	useVerifyAffiliateEmail,
	type AffiliateSignUpInput,
	type VerifiedSession,
} from "@/hooks/use-affiliate-registration"
import { verifyCustomerResult } from "@/testing/factories/exam"
import { examregGet, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

const registered: RegisterResult = {
	orderId: "801-aff",
	orderNumber: "A-1001",
	contactId: "003-aff",
	accountId: "001-aff",
	total: 0,
	hasBilling: false,
}

function signUpInput(
	overrides: Partial<AffiliateSignUpInput> = {},
): AffiliateSignUpInput {
	return {
		firstName: " Ada ",
		lastName: " Lovelace ",
		email: " ada@garp.org ",
		mobilePhoneCode: "United States (+1)",
		mobilePhone: " 5551234 ",
		smsPromotionalUpdates: true,
		country: "United States",
		privacyPolicy: true,
		...overrides,
	}
}

async function signUp(input: AffiliateSignUpInput) {
	const { result } = renderHookWithProviders(() => useAffiliateSignUp())
	let outcome: RegisterResult | undefined
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

describe("useAffiliateSignUp", () => {
	it("runs verify → register → payOrder in order, each exactly once", async () => {
		const calls: string[] = []
		const verify = examregPost("verifyCustomer", () => {
			calls.push("verifyCustomer")
			return verifyCustomerResult()
		})
		const register = examregPost<AffiliateRegisterRequest>("register", () => {
			calls.push("register")
			return registered
		})
		const pay = examregPost("payOrder", () => {
			calls.push("payOrder")
			return { completed: true }
		})
		server.use(verify.handler, register.handler, pay.handler)

		const { outcome } = await signUp(signUpInput())

		expect(calls).toEqual(["verifyCustomer", "register", "payOrder"])
		expect(verify.spy.hits).toBe(1)
		expect(register.spy.hits).toBe(1)
		// completeAffiliateOrder is NOT idempotent server-side — exactly once.
		expect(pay.spy.hits).toBe(1)
		expect(pay.spy.bodies[0]).toEqual({ orderId: "801-aff" })
		expect(outcome).toEqual(registered)
	})

	it("trims the fields into both payloads and quotes the session back", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const register = examregPost<AffiliateRegisterRequest>(
			"register",
			() => registered,
		)
		const pay = examregPost("payOrder", () => ({}))
		server.use(verify.handler, register.handler, pay.handler)

		await signUp(signUpInput())

		expect(verify.spy.bodies[0]).toEqual({
			type: "affiliate",
			email: "ada@garp.org",
			firstName: "Ada",
			lastName: "Lovelace",
		})
		expect(register.spy.bodies[0]).toEqual({
			type: "affiliate",
			sessionId: "S-1",
			customer: {
				contactId: "003-verified",
				accountId: "001-verified",
				leadId: null,
				firstName: "Ada",
				lastName: "Lovelace",
				email: "ada@garp.org",
				mobilePhoneCode: "United States (+1)",
				mobilePhone: "5551234",
				smsPromotionalUpdates: true,
			},
			billingAddress: { country: "United States" },
			billingAndShippingSame: true,
			consent: { privacyPolicy: true },
		})
	})

	it("reuses a blur-check session for the same email, skipping verify", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const register = examregPost<AffiliateRegisterRequest>(
			"register",
			() => registered,
		)
		const pay = examregPost("payOrder", () => ({}))
		server.use(verify.handler, register.handler, pay.handler)

		const session: VerifiedSession = {
			...verifyCustomerResult({ sessionId: "S-blur" }),
			email: "ada@garp.org",
		}
		await signUp(signUpInput({ session }))

		expect(verify.spy.hits).toBe(0)
		expect(register.spy.bodies[0].sessionId).toBe("S-blur")
	})

	it("re-verifies when the session was for a different email", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const register = examregPost<AffiliateRegisterRequest>(
			"register",
			() => registered,
		)
		const pay = examregPost("payOrder", () => ({}))
		server.use(verify.handler, register.handler, pay.handler)

		const session: VerifiedSession = {
			...verifyCustomerResult({ sessionId: "S-stale" }),
			email: "other@garp.org",
		}
		await signUp(signUpInput({ session }))

		expect(verify.spy.hits).toBe(1)
		expect(register.spy.bodies[0].sessionId).toBe("S-1")
	})

	it("rejects with MustSignInError and never registers", async () => {
		const verify = examregPost("verifyCustomer", () =>
			verifyCustomerResult({ mustSignIn: true }),
		)
		const register = examregPost("register", () => registered)
		server.use(verify.handler, register.handler)

		const { outcome, failure } = await signUp(signUpInput())

		expect(outcome).toBeUndefined()
		expect(failure).toBeInstanceOf(MustSignInError)
		expect((failure as MustSignInError).status).toBe(409)
		expect((failure as MustSignInError).messages).toEqual([
			"An account already exists for this email address. Please sign in instead.",
		])
		expect(register.spy.hits).toBe(0)
	})

	it("skips completeAffiliateOrder when no order came back", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const register = examregPost("register", () => ({
			...registered,
			orderId: null,
		}))
		const pay = examregPost("payOrder", () => ({}))
		server.use(verify.handler, register.handler, pay.handler)

		const { outcome } = await signUp(signUpInput())

		expect(pay.spy.hits).toBe(0)
		expect(outcome?.orderId).toBeNull()
	})
})

describe("useVerifyAffiliateEmail", () => {
	it("trims the fields and tags the result with the trimmed email", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		server.use(verify.handler)

		const { result } = renderHookWithProviders(() => useVerifyAffiliateEmail())
		let session: VerifiedSession | undefined
		await act(async () => {
			session = await result.current.mutateAsync({
				email: " jo@garp.org ",
				firstName: " Jo ",
				lastName: " March ",
			})
		})

		expect(verify.spy.bodies[0]).toEqual({
			type: "affiliate",
			email: "jo@garp.org",
			firstName: "Jo",
			lastName: "March",
		})
		expect(session).toEqual({ ...verifyCustomerResult(), email: "jo@garp.org" })
	})
})

describe("useAffiliateRegistration", () => {
	it("loads countries and eligibility from /info", async () => {
		const load: AffiliateRegistrationLoad = {
			program: { type: "affiliate", kind: "membership" },
			isAuthenticated: false,
			contact: null,
			eligibility: { isEligible: true },
			countries: [
				{
					id: "cc-us",
					name: "United States",
					countryCode: "United States",
					phoneCode: "1",
				},
			],
		}
		const info = examregGet("info", () => load)
		server.use(info.handler)

		const { result } = renderHookWithProviders(() => useAffiliateRegistration())

		await vi.waitFor(() => {
			expect(result.current.isSuccess).toBe(true)
		})
		expect(info.spy.hits).toBe(1)
		expect(result.current.data?.countries).toHaveLength(1)
		expect(result.current.data?.program.kind).toBe("membership")
	})
})
