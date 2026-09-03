import { act } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { ExamRegisterRequest } from "@/api/registration/exam-types"
import {
	AddressRejectedError,
	MustSignInError,
	useExamRegistrationSubmit,
	useVerifyExamCustomer,
	type ExamSubmitInput,
	type ExamSubmitOutcome,
	type VerifiedSession,
} from "@/hooks/use-exam-registration-submit"
import {
	examCustomer,
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

/** A register answer with no order, so the flow stops before any payment. */
const unbilledRegister = () =>
	examRegisterResult({ orderId: null, orderNumber: null, hasBilling: false, total: 0 })

describe("useVerifyExamCustomer", () => {
	it("trims the fields and tags the result with the trimmed email", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		server.use(verify.handler)

		const { result } = renderHookWithProviders(() => useVerifyExamCustomer())
		let session: VerifiedSession | undefined
		await act(async () => {
			session = await result.current.mutateAsync({
				type: "frm",
				email: "  jo@example.org ",
				firstName: " Jo ",
				lastName: " March ",
			})
		})

		expect(verify.spy.hits).toBe(1)
		expect(verify.spy.bodies[0]).toEqual({
			type: "frm",
			courseCode: null,
			email: "jo@example.org",
			firstName: "Jo",
			lastName: "March",
		})
		expect(session).toEqual({
			...verifyCustomerResult(),
			email: "jo@example.org",
		})
	})
})

describe("useExamRegistrationSubmit — identity", () => {
	it("reuses a session whose email matches and skips the verify call", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const register = examregPost<ExamRegisterRequest>("register", unbilledRegister)
		server.use(verify.handler, register.handler)

		const session: VerifiedSession = {
			...verifyCustomerResult({ sessionId: "S-reused", contactId: "003-blur" }),
			email: "ada@example.org",
		}
		const { outcome } = await submit({
			request: examRegisterRequest({
				customer: examCustomer({ email: " ada@example.org " }),
			}),
			checkAddress: false,
			session,
		})

		expect(verify.spy.hits).toBe(0)
		expect(register.spy.hits).toBe(1)
		expect(register.spy.bodies[0].sessionId).toBe("S-reused")
		expect(register.spy.bodies[0].customer.contactId).toBe("003-blur")
		expect(outcome?.kind).toBe("registered")
	})

	it("re-verifies when the session was obtained for a different email", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const register = examregPost<ExamRegisterRequest>("register", unbilledRegister)
		server.use(verify.handler, register.handler)

		const session: VerifiedSession = {
			...verifyCustomerResult({ sessionId: "S-stale" }),
			email: "old@example.org",
		}
		await submit({
			request: examRegisterRequest(),
			checkAddress: false,
			session,
		})

		expect(verify.spy.hits).toBe(1)
		expect(verify.spy.bodies[0]).toEqual({
			type: "frm",
			courseCode: null,
			email: "ada@example.org",
			firstName: "Ada",
			lastName: "Lovelace",
		})
		// The fresh verify's session wins over the stale one.
		expect(register.spy.bodies[0].sessionId).toBe("S-1")
	})

	it("falls back to the request's own ids when verify returns none", async () => {
		const verify = examregPost("verifyCustomer", () =>
			verifyCustomerResult({
				sessionId: null,
				contactId: null,
				accountId: null,
				leadId: null,
			}),
		)
		const register = examregPost<ExamRegisterRequest>("register", unbilledRegister)
		server.use(verify.handler, register.handler)

		await submit({
			request: examRegisterRequest({
				sessionId: "S-request",
				customer: examCustomer({
					contactId: "003-req",
					accountId: "001-req",
					leadId: "00Q-req",
				}),
			}),
			checkAddress: false,
			session: null,
		})

		const body = register.spy.bodies[0]
		expect(body.sessionId).toBe("S-request")
		expect(body.customer.contactId).toBe("003-req")
		expect(body.customer.accountId).toBe("001-req")
		expect(body.customer.leadId).toBe("00Q-req")
	})

	it("rejects with MustSignInError and calls nothing afterwards", async () => {
		const verify = examregPost("verifyCustomer", () =>
			verifyCustomerResult({ mustSignIn: true }),
		)
		const address = examregPost("verifyAddress", () => ({}))
		const register = examregPost("register", () => examRegisterResult())
		server.use(verify.handler, address.handler, register.handler)

		const { failure, outcome } = await submit({
			request: examRegisterRequest(),
			checkAddress: true,
			session: null,
		})

		expect(outcome).toBeUndefined()
		expect(failure).toBeInstanceOf(MustSignInError)
		expect((failure as MustSignInError).status).toBe(409)
		expect(address.spy.hits).toBe(0)
		expect(register.spy.hits).toBe(0)
	})
})

describe("useExamRegistrationSubmit — address check", () => {
	it.each([
		"billingValid",
		"billingAllowed",
		"shippingValid",
		"shippingAllowed",
	] as const)("rejects with the server wording when %s is false", async (field) => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const address = examregPost("verifyAddress", () => ({
			[field]: false,
			message: "We cannot ship to this country.",
		}))
		const register = examregPost("register", () => examRegisterResult())
		server.use(verify.handler, address.handler, register.handler)

		const { failure } = await submit({
			request: examRegisterRequest(),
			checkAddress: true,
			session: null,
		})

		expect(failure).toBeInstanceOf(AddressRejectedError)
		expect((failure as AddressRejectedError).messages).toEqual([
			"We cannot ship to this country.",
		])
		expect(register.spy.hits).toBe(0)
	})

	it("falls back to its own wording when the server message is blank", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const address = examregPost<ExamRegisterRequest>("verifyAddress", () => ({
			billingAllowed: false,
			message: "  ",
		}))
		server.use(verify.handler, address.handler)

		const { failure } = await submit({
			request: examRegisterRequest(),
			checkAddress: true,
			session: null,
		})

		expect(failure).toBeInstanceOf(AddressRejectedError)
		expect((failure as AddressRejectedError).messages).toEqual([
			"Please check the address you entered.",
		])
		// verifyAddress gets the SAME body as register — verified session merged in.
		expect(address.spy.bodies[0].sessionId).toBe("S-1")
		expect(address.spy.bodies[0].customer.contactId).toBe("003-verified")
	})

	it("skips verifyAddress entirely when checkAddress is false", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const address = examregPost("verifyAddress", () => ({}))
		const register = examregPost("register", unbilledRegister)
		server.use(verify.handler, address.handler, register.handler)

		const { outcome } = await submit({
			request: examRegisterRequest(),
			checkAddress: false,
			session: null,
		})

		expect(address.spy.hits).toBe(0)
		expect(register.spy.hits).toBe(1)
		expect(outcome?.kind).toBe("registered")
	})

	it("proceeds to register when the server accepts the address", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		// All four flags undefined means "not refused" — only explicit false blocks.
		const address = examregPost("verifyAddress", () => ({}))
		const register = examregPost("register", unbilledRegister)
		server.use(verify.handler, address.handler, register.handler)

		const { outcome } = await submit({
			request: examRegisterRequest(),
			checkAddress: true,
			session: null,
		})

		expect(address.spy.hits).toBe(1)
		expect(register.spy.hits).toBe(1)
		expect(outcome?.kind).toBe("registered")
	})
})
