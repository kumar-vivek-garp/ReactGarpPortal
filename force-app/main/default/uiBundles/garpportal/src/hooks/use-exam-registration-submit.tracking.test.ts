import { act } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { ExamVerifyCustomerRequest } from "@/api/registration/exam-types"
import {
	useExamRegistrationSubmit,
	useVerifyExamCustomer,
	type ExamSubmitInput,
} from "@/hooks/use-exam-registration-submit"
import {
	examRegisterRequest,
	examRegisterResult,
	verifyCustomerResult,
} from "@/testing/factories/exam"
import { examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

/**
 * `track_cta` attribution. It rides `verifyCustomer` and NOTHING else — Apex
 * writes it to the form session (`Form_Data__c.Track_CTA__c`) and neither
 * `fees` nor `register` has a field for it. And when there is no tag, the
 * `tracking` key is absent, not `{ trackCta: undefined }`: every existing
 * body assertion in the suite depends on that.
 */

async function submit(input: ExamSubmitInput) {
	const { result } = renderHookWithProviders(() => useExamRegistrationSubmit())
	await act(async () => {
		await result.current.mutateAsync(input)
	})
}

/** A register answer with no order, so the flow ends before any payment. */
const unbilledRegister = () =>
	examRegisterResult({ orderId: null, orderNumber: null, hasBilling: false, total: 0 })

describe("useVerifyExamCustomer — attribution", () => {
	it("sends the tag inside `tracking` on the blur check", async () => {
		const verify = examregPost<ExamVerifyCustomerRequest>("verifyCustomer", () =>
			verifyCustomerResult(),
		)
		server.use(verify.handler)

		const { result } = renderHookWithProviders(() => useVerifyExamCustomer())
		await act(async () => {
			await result.current.mutateAsync({
				type: "mem",
				email: "jo@example.org",
				firstName: "Jo",
				lastName: "March",
				trackCta: "PortalMyAccountPage",
			})
		})

		expect(verify.spy.bodies[0]).toEqual({
			type: "mem",
			courseCode: null,
			email: "jo@example.org",
			firstName: "Jo",
			lastName: "March",
			tracking: { trackCta: "PortalMyAccountPage" },
		})
	})

	it("omits the key entirely when there is no tag, or only whitespace", async () => {
		const verify = examregPost<ExamVerifyCustomerRequest>("verifyCustomer", () =>
			verifyCustomerResult(),
		)
		server.use(verify.handler)

		const { result } = renderHookWithProviders(() => useVerifyExamCustomer())
		await act(async () => {
			await result.current.mutateAsync({
				type: "frm",
				email: "jo@example.org",
				firstName: "Jo",
				lastName: "March",
				trackCta: "  ",
			})
		})

		expect(verify.spy.bodies[0]).not.toHaveProperty("tracking")
	})
})

describe("useExamRegistrationSubmit — attribution", () => {
	it("tags the in-submit verify — the member path, where no blur check ran", async () => {
		const verify = examregPost<ExamVerifyCustomerRequest>("verifyCustomer", () =>
			verifyCustomerResult(),
		)
		const register = examregPost("register", () => unbilledRegister())
		server.use(verify.handler, register.handler)

		await submit({
			request: examRegisterRequest({ type: "mem" }),
			checkAddress: false,
			trackCta: "PortalMembershipPage",
		})

		expect(verify.spy.hits).toBe(1)
		expect(verify.spy.bodies[0]).toMatchObject({
			type: "mem",
			tracking: { trackCta: "PortalMembershipPage" },
		})
		// Never on register: the request has no field for it.
		expect(register.spy.bodies[0]).not.toHaveProperty("tracking")
	})

	it("leaves the register body alone and the verify untagged without one", async () => {
		const verify = examregPost<ExamVerifyCustomerRequest>("verifyCustomer", () =>
			verifyCustomerResult(),
		)
		const register = examregPost("register", () => unbilledRegister())
		server.use(verify.handler, register.handler)

		await submit({
			request: examRegisterRequest(),
			checkAddress: false,
		})

		expect(verify.spy.bodies[0]).not.toHaveProperty("tracking")
		expect(register.spy.bodies[0]).not.toHaveProperty("tracking")
	})

	it("a reused blur session means no second verify — the tag already rode the first", async () => {
		const verify = examregPost<ExamVerifyCustomerRequest>("verifyCustomer", () =>
			verifyCustomerResult(),
		)
		const register = examregPost("register", () => unbilledRegister())
		server.use(verify.handler, register.handler)

		await submit({
			request: examRegisterRequest(),
			checkAddress: false,
			session: { ...verifyCustomerResult(), email: "ada@example.org" },
			trackCta: "PortalGatedContent",
		})

		expect(verify.spy.hits).toBe(0)
		expect(register.spy.hits).toBe(1)
	})
})
