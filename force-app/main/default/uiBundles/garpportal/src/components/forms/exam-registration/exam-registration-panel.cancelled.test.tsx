import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import { ExamRegistrationPanel } from "@/components/forms/exam-registration/exam-registration-panel"
import { EXAM_PROGRAMS } from "@/config/registration"
import { memberPortalError } from "@/testing/factories/envelope"
import { examLoad } from "@/testing/factories/exam"
import {
	EXAMREG_PATH,
	examregGet,
	examregPost,
} from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

async function renderCancelled(orderId?: string) {
	return renderWithRouterProviders(
		<ExamRegistrationPanel
			program={EXAM_PROGRAMS.frm}
			programType="frm"
			onNavigateBack={vi.fn()}
			checkoutCancelled={{ orderId }}
		/>,
		{ user: null },
	)
}

async function flushNetwork() {
	await new Promise((resolve) => {
		setTimeout(resolve, 30)
	})
}

/**
 * The provider's cancel leg for an ORDER. The registration created real
 * records nobody paid for, so the first thing the screen does is undo them.
 */
describe("ExamRegistrationPanel — cancelled checkout", () => {
	it("rolls the order back exactly once (under StrictMode) and offers a restart", async () => {
		const info = examregGet("info", () => examLoad())
		const rollback = examregPost<{ orderId: string; reason: string }>(
			"rollback",
			() => ({ success: true }),
		)
		server.use(info.handler, rollback.handler)

		await renderCancelled("801-order")

		expect(
			screen.getByRole("heading", { name: "Payment was not completed" }),
		).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Start again" })).toBeInTheDocument()
		expect(screen.queryByText("Loading your registration…")).not.toBeInTheDocument()

		await flushNetwork()
		expect(rollback.spy.hits).toBe(1)
		expect(rollback.spy.bodies[0]).toEqual({
			orderId: "801-order",
			reason: "Checkout cancelled",
		})
		// The form is never loaded on this leg.
		expect(info.spy.hits).toBe(0)
	})

	it("does nothing without an order id — there is nothing to undo", async () => {
		const rollback = examregPost("rollback", () => ({ success: true }))
		server.use(rollback.handler)

		await renderCancelled(undefined)

		expect(
			screen.getByRole("heading", { name: "Payment was not completed" }),
		).toBeInTheDocument()
		await flushNetwork()
		expect(rollback.spy.hits).toBe(0)
	})

	it("keeps the outcome on screen when the rollback itself fails", async () => {
		server.use(
			http.post(`${EXAMREG_PATH}/rollback`, () =>
				HttpResponse.json(memberPortalError(400, "Order not found"), { status: 400 }),
			),
		)

		await renderCancelled("801-gone")

		await flushNetwork()
		// The candidate is told the same thing either way; the failure is a
		// toast and a server-side log, not something put in their way.
		expect(
			screen.getByRole("heading", { name: "Payment was not completed" }),
		).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Start again" })).toBeInTheDocument()
	})
})
