import { screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { ExamRegistrationPanel } from "@/components/forms/exam-registration/exam-registration-panel"
import { EXAM_PROGRAMS } from "@/config/registration"
import { memberPortalError } from "@/testing/factories/envelope"
import { examLoad, feesResult } from "@/testing/factories/exam"
import {
	demographicsOptions,
	paymentStatusResult,
	stagedPaymentStatus,
} from "@/testing/factories/exam-payment"
import {
	personalInfoEditData,
	seedPersonalInfoCache,
} from "@/testing/factories/personal-info"
import {
	EXAMREG_PATH,
	examregGet,
	examregPost,
} from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003-member",
	photoUrl: null,
}

/** Spies on every endpoint the panel could possibly reach besides the poll. */
function armExamregSpies() {
	const info = examregGet("info", () => examLoad())
	const fees = examregPost("fees", () => feesResult(100))
	const register = examregPost("register", () => ({}))
	const payOrder = examregPost("payOrder", () => ({}))
	const rollback = examregPost("rollback", () => ({}))
	const demographics = examregGet("demographics", () => demographicsOptions())
	const options = examregGet("options", () => ({ companies: ["Acme"], schools: [] }))
	server.use(
		info.handler,
		fees.handler,
		register.handler,
		payOrder.handler,
		rollback.handler,
		demographics.handler,
		options.handler,
	)
	return { info, fees, register, payOrder, rollback }
}

async function renderPaymentReturn(
	user: CurrentUser | null,
	paymentReturn: { statusId?: string; orderNumber?: string },
) {
	const queryClient = createTestQueryClient(user)
	if (user?.contactId) {
		seedPersonalInfoCache(
			queryClient,
			personalInfoEditData({ contactId: user.contactId }),
		)
	}
	return renderWithRouterProviders(
		<ExamRegistrationPanel
			program={EXAM_PROGRAMS.frm}
			programType="frm"
			onNavigateBack={vi.fn()}
			paymentReturn={paymentReturn}
		/>,
		{ user, queryClient },
	)
}

/** Lets any wrongly-issued fetch reach the spies before the counters are read. */
async function flushNetwork() {
	await new Promise((resolve) => {
		setTimeout(resolve, 30)
	})
}

describe("ExamRegistrationPanel — payment return", () => {
	it("confirms first, then shows the survey, then the closing copy — and never loads the form", async () => {
		const spies = armExamregSpies()
		const status = examregPost("paymentStatus", () => paymentStatusResult())
		server.use(status.handler)
		const user = userEvent.setup()

		await renderPaymentReturn(null, { statusId: "801-order" })

		// Not "paid" on arrival — the poll has not answered yet.
		expect(
			screen.getByRole("heading", { name: "Payment received" }),
		).toBeInTheDocument()
		expect(screen.queryByText("Loading your registration…")).not.toBeInTheDocument()

		// Confirmed: the reference from the poll, and the survey before any action.
		expect(
			await screen.findByRole("heading", { name: "Thank you — payment received" }),
		).toBeInTheDocument()
		expect(screen.getByText("ORD-1001")).toBeInTheDocument()
		expect(
			await screen.findByRole("heading", { name: /Help us tailor your/ }),
		).toBeInTheDocument()
		expect(screen.queryByRole("link", { name: "Sign in" })).not.toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "Skip for now" }))
		expect(screen.getByRole("link", { name: "Sign in" })).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Back to GARP.org" }),
		).toHaveAttribute("href", "https://www.garp.org")

		// The poll is the ONLY registration call this leg makes.
		await flushNetwork()
		expect(status.spy.bodies[0]).toEqual({ orderId: "801-order" })
		expect(spies.info.spy.hits).toBe(0)
		expect(spies.fees.spy.hits).toBe(0)
		expect(spies.register.spy.hits).toBe(0)
		expect(spies.payOrder.spy.hits).toBe(0)
		expect(spies.rollback.spy.hits).toBe(0)
	})

	it("DEFERRED FLOW: a Paid staged row reads as finalising, under its REG- reference", async () => {
		armExamregSpies()
		const status = examregPost("paymentStatus", () =>
			stagedPaymentStatus({ isComplete: false, orderNumber: null }),
		)
		server.use(status.handler)
		const user = userEvent.setup()

		await renderPaymentReturn(null, { statusId: "a0H-staged" })

		expect(await screen.findByText("REG-000123")).toBeInTheDocument()
		expect(screen.getByText("Reference")).toBeInTheDocument()
		await user.click(await screen.findByRole("button", { name: "Skip for now" }))
		expect(
			screen.getByText(/your registration is being finalised/i),
		).toBeInTheDocument()
	})

	it("a declined card offers Try again, pointing back at the form with the staged id", async () => {
		const spies = armExamregSpies()
		const status = examregPost("paymentStatus", () =>
			stagedPaymentStatus({
				registrationStatus: "Payment Failed",
				isPaymentSuccess: false,
				errorMessage: "Your card was declined.",
			}),
		)
		server.use(status.handler)

		await renderPaymentReturn(null, { statusId: "a0H-staged" })

		expect(
			await screen.findByRole("heading", {
				name: "There may have been an issue processing your payment",
			}),
		).toBeInTheDocument()
		expect(screen.getByText(/Your card was declined\./)).toBeInTheDocument()
		const tryAgain = screen.getByRole("link", { name: "Try again" })
		expect(new URL(tryAgain.getAttribute("href") ?? "", "http://x").searchParams.get("resume")).toBe(
			"a0H-staged",
		)
		// A decline never reaches the survey.
		expect(screen.queryByRole("heading", { name: /Help us tailor your/ })).not.toBeInTheDocument()
		expect(spies.rollback.spy.hits).toBe(0)
	})

	it("paid but rolled back or Failed is a failure that needs a human, never a success", async () => {
		armExamregSpies()
		const status = examregPost("paymentStatus", () =>
			paymentStatusResult({ isOrderRolledback: true }),
		)
		server.use(status.handler)

		await renderPaymentReturn(null, { statusId: "801-rb" })

		expect(
			await screen.findByRole("heading", { name: "We could not complete your registration" }),
		).toBeInTheDocument()
		expect(screen.queryByRole("heading", { name: /Help us tailor your/ })).not.toBeInTheDocument()
	})

	it("an answer with no trace of the registration is an issue, not a confirmation", async () => {
		armExamregSpies()
		const status = examregPost("paymentStatus", () => ({}))
		server.use(status.handler)

		await renderPaymentReturn(null, { statusId: "dead" })

		expect(
			await screen.findByRole("heading", {
				name: "There may have been an issue processing your payment",
			}),
		).toBeInTheDocument()
		// It will not become right by asking again: no further polling once
		// settled. (StrictMode's double-mounted effect may have asked twice on
		// arrival — the point is that the count stops moving.)
		const asked = status.spy.hits
		await flushNetwork()
		expect(status.spy.hits).toBe(asked)
	})

	it("a server refusal stops the poll and carries its message", async () => {
		armExamregSpies()
		server.use(
			http.post(`${EXAMREG_PATH}/paymentStatus`, () =>
				HttpResponse.json(memberPortalError(400, "Order not found"), { status: 400 }),
			),
		)

		await renderPaymentReturn(null, { statusId: "801-x" })

		const heading = await screen.findByRole("heading", {
			name: "There may have been an issue processing your payment",
		})
		expect(within(heading.parentElement as HTMLElement).getByText(/Order not found/)).toBeInTheDocument()
	})

	it("with no id at all there is nothing to poll — settled as an issue at once", async () => {
		armExamregSpies()
		const status = examregPost("paymentStatus", () => paymentStatusResult())
		server.use(status.handler)

		await renderPaymentReturn(null, { orderNumber: "8013" })

		expect(
			screen.getByRole("heading", {
				name: "There may have been an issue processing your payment",
			}),
		).toBeInTheDocument()
		await flushNetwork()
		expect(status.spy.hits).toBe(0)
	})

	it("offers a member the in-app destinations once the survey is done", async () => {
		const spies = armExamregSpies()
		const status = examregPost("paymentStatus", () => paymentStatusResult())
		server.use(status.handler)
		const user = userEvent.setup()

		await renderPaymentReturn(MEMBER, { statusId: "801-order" })

		// A member's survey reads the member portal, which is not mocked here,
		// so the survey reports itself unavailable — and still stands between
		// the confirmation and the actions.
		await user.click(await screen.findByRole("button", { name: "Continue" }))
		expect(
			screen.getByRole("link", { name: "Go to dashboard" }),
		).toHaveAttribute("href", "/dashboard")
		expect(screen.queryByRole("link", { name: "Sign in" })).not.toBeInTheDocument()
		await flushNetwork()
		expect(spies.info.spy.hits).toBe(0)
		expect(spies.register.spy.hits).toBe(0)
	})
})
