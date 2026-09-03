import { screen } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { personalInfoQueryKeys } from "@/api/personal-info/query-options"
import { ExamRegistrationPanel } from "@/components/forms/exam-registration/exam-registration-panel"
import { EXAM_PROGRAMS } from "@/config/registration"
import { examLoad, feesResult } from "@/testing/factories/exam"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { examregGet, examregPost } from "@/testing/msw/handlers/examreg"
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

/** Spies on every endpoint the panel could possibly reach. */
function armExamregSpies() {
	const info = examregGet("info", () => examLoad())
	const fees = examregPost("fees", () => feesResult(100))
	const register = examregPost("register", () => ({}))
	const payOrder = examregPost("payOrder", () => ({}))
	server.use(info.handler, fees.handler, register.handler, payOrder.handler)
	return { info, fees, register, payOrder }
}

async function renderPaymentReturn(
	user: CurrentUser | null,
	orderNumber?: string,
) {
	const queryClient = createTestQueryClient(user)
	if (user?.contactId) {
		// Seed the member's profile so the secondary GraphQL read stays off the
		// wire — the panel's payment-return branch is what is under test here.
		queryClient.setQueryData(
			personalInfoQueryKeys.edit(user.contactId),
			personalInfoEditData({ contactId: user.contactId }),
		)
	}
	return renderWithRouterProviders(
		<ExamRegistrationPanel
			program={EXAM_PROGRAMS.frm}
			programType="frm"
			onNavigateBack={vi.fn()}
			paymentReturn={{ orderNumber }}
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
	it("shows the paid outcome instead of the form and never prices or registers", async () => {
		const spies = armExamregSpies()
		await renderPaymentReturn(null, "ORD-2001")

		// The outcome is on screen synchronously — no skeleton, no form, so
		// there is no way to re-submit the registration that was just paid for.
		expect(
			screen.getByRole("heading", { name: "Thank you — payment received" }),
		).toBeInTheDocument()
		expect(screen.getByText("ORD-2001")).toBeInTheDocument()
		expect(screen.queryByText("Loading your registration…")).not.toBeInTheDocument()
		expect(screen.queryByRole("button", { name: /register/i })).not.toBeInTheDocument()

		// The guard against double registration: nothing that writes or prices
		// an order may fire on this leg.
		await flushNetwork()
		expect(spies.fees.spy.hits).toBe(0)
		expect(spies.register.spy.hits).toBe(0)
		expect(spies.payOrder.spy.hits).toBe(0)
		/*
		 * SUSPECTED BUG, pinned deliberately: the panel's own comment says the
		 * payment return is "shown before anything else is fetched", but the
		 * load query (`GET examreg/info`) is mounted unconditionally above the
		 * short-circuit, so it still fires once in the background. Harmless to
		 * the double-registration guard (read-only, and the form never renders),
		 * but it is a wasted request on a leg that should be network-silent. If
		 * this assertion starts failing with 0, the query was gated — update
		 * this pin and delete the comment.
		 */
		expect(spies.info.spy.hits).toBe(1)
	})

	it("renders a purely numeric order number (the JSON-parsed search param)", async () => {
		armExamregSpies()
		// `?on=8013` arrives as the number 8013 and is coerced back to a string
		// by the route schema — the panel must render it, not drop it.
		await renderPaymentReturn(null, "8013")

		expect(screen.getByText("8013")).toBeInTheDocument()
	})

	it("still shows the outcome when the provider sent no order number", async () => {
		armExamregSpies()
		await renderPaymentReturn(null, undefined)

		expect(
			screen.getByRole("heading", { name: "Thank you — payment received" }),
		).toBeInTheDocument()
		expect(screen.queryByText("Order")).not.toBeInTheDocument()
	})

	it("offers a guest only public-safe destinations", async () => {
		armExamregSpies()
		await renderPaymentReturn(null, "ORD-2001")

		expect(screen.getByRole("link", { name: "Sign in" })).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Back to GARP.org" }),
		).toHaveAttribute("href", "https://www.garp.org")
		expect(
			screen.queryByRole("link", { name: "Go to dashboard" }),
		).not.toBeInTheDocument()
	})

	it("offers a member the in-app destinations", async () => {
		const spies = armExamregSpies()
		await renderPaymentReturn(MEMBER, "ORD-2001")

		expect(
			screen.getByRole("link", { name: "Go to dashboard" }),
		).toHaveAttribute("href", "/dashboard")
		expect(
			screen.getByRole("link", { name: "Back to programmes" }),
		).toHaveAttribute("href", "/programs")
		expect(screen.queryByRole("link", { name: "Sign in" })).not.toBeInTheDocument()

		// Same background-load pin as above — and still nothing order-writing.
		await flushNetwork()
		expect(spies.info.spy.hits).toBe(1)
		expect(spies.register.spy.hits).toBe(0)
		expect(spies.payOrder.spy.hits).toBe(0)
	})
})
