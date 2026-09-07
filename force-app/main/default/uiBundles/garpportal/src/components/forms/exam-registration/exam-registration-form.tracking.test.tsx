import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import type {
	ExamRegisterRequest,
	ExamVerifyCustomerRequest,
	FeesRequest,
} from "@/api/registration/exam-types"
import { EXAM_PROGRAMS } from "@/config/registration"
import { examRegisterResult, verifyCustomerResult } from "@/testing/factories/exam"
import {
	membershipFeesResult,
	membershipLoad,
} from "@/testing/factories/membership-registration"
import { renderExamForm } from "@/testing/exam-registration-ui"
import { examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"

/**
 * `?track_cta=` attribution, end to end through the form: it reaches
 * `verifyCustomer` — on blur for a guest, inside the submit for a member —
 * and never `fees` or `register`, which have no field for it.
 */

function arm() {
	const verify = examregPost<ExamVerifyCustomerRequest>("verifyCustomer", () =>
		verifyCustomerResult(),
	)
	const fees = examregPost<FeesRequest>("fees", () => membershipFeesResult())
	const register = examregPost<ExamRegisterRequest>("register", () =>
		examRegisterResult({
			orderId: null,
			orderNumber: "ORD-MEM",
			hasBilling: false,
			total: 0,
		}),
	)
	server.use(verify.handler, fees.handler, register.handler)
	return { verify, fees, register }
}

describe("ExamRegistrationForm — track_cta", () => {
	it("a guest's blur check carries the tag", async () => {
		const { verify, fees } = arm()
		const user = userEvent.setup()
		await renderExamForm({
			load: membershipLoad(),
			program: EXAM_PROGRAMS.membership,
			profile: null,
			isAuthenticated: false,
			trackCta: "PortalMyAccountPage",
		})

		await user.type(screen.getByLabelText(/First name/), "Jo")
		await user.type(screen.getByLabelText(/Last name/), "March")
		await user.type(screen.getByLabelText(/Email/), "jo@example.org")
		await user.tab()

		await waitFor(() => expect(verify.spy.hits).toBe(1))
		expect(verify.spy.bodies[0]).toMatchObject({
			type: "mem",
			email: "jo@example.org",
			tracking: { trackCta: "PortalMyAccountPage" },
		})
		await waitFor(() => expect(fees.spy.hits).toBeGreaterThan(0))
		expect(fees.spy.bodies[0]).not.toHaveProperty("tracking")
	})

	it("a member's in-submit check carries it; register does not", async () => {
		const { verify, register } = arm()
		const user = userEvent.setup()
		await renderExamForm({
			load: membershipLoad({ isAuthenticated: true, contact: { id: "003-member" } }),
			program: EXAM_PROGRAMS.membership,
			trackCta: "PortalMembershipPage",
		})

		await user.click(await screen.findByRole("radio", { name: /^Card$/ }))
		const submit = screen.getByRole("button", { name: "Pay and Register" })
		await waitFor(() => expect(submit).toBeEnabled())
		await user.click(submit)
		const dialog = await screen.findByRole("dialog", {
			name: "Confirm your registration",
		})
		await user.click(
			within(dialog).getByRole("button", { name: "Pay and Register" }),
		)

		await waitFor(() => expect(register.spy.hits).toBe(1))
		expect(verify.spy.hits).toBe(1)
		expect(verify.spy.bodies[0]).toMatchObject({
			type: "mem",
			tracking: { trackCta: "PortalMembershipPage" },
		})
		expect(register.spy.bodies[0]).not.toHaveProperty("tracking")
	})

	it("sends no tracking block at all when the page was reached untagged", async () => {
		const { verify } = arm()
		const user = userEvent.setup()
		await renderExamForm({
			load: membershipLoad(),
			program: EXAM_PROGRAMS.membership,
			profile: null,
			isAuthenticated: false,
		})

		await user.type(screen.getByLabelText(/Email/), "jo@example.org")
		await user.tab()

		await waitFor(() => expect(verify.spy.hits).toBe(1))
		expect(verify.spy.bodies[0]).not.toHaveProperty("tracking")
	})
})
