import { screen, waitFor } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { toast } from "sonner"
import { describe, expect, it, vi } from "vitest"

import { EventRegistrationPanel } from "@/components/forms/event-registration/event-registration-panel"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { eventLoad } from "@/testing/factories/event"
import { examregGet, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const INFO_PATH = "/services/apexrest/examreg/event/info"
const ROLLBACK_PATH = "/services/apexrest/examreg/event/rollback"

type RollbackBody = { orderId: string; reason: string }

function renderPanel(props: {
	paymentReturn?: { orderNumber?: string | null } | null
	checkoutCancelled?: { orderId?: string | null } | null
}) {
	return renderWithRouterProviders(
		<EventRegistrationPanel
			variant="event"
			eventId="evt-1"
			paymentReturn={props.paymentReturn ?? null}
			checkoutCancelled={props.checkoutCancelled ?? null}
		/>,
		{ user: null },
	)
}

/** Lets any wrongly-issued request reach the spies before counters are read. */
async function flushNetwork() {
	await new Promise((resolve) => {
		setTimeout(resolve, 30)
	})
}

describe("EventRegistrationPanel — cancelled checkout rollback", () => {
	it("rolls the abandoned order back EXACTLY once — the ref survives StrictMode's double effect run", async () => {
		const info = examregGet("event/info", () => eventLoad())
		const rollback = examregPost<RollbackBody>("event/rollback", () => ({}))
		server.use(info.handler, rollback.handler)

		// The harness renders under StrictMode by default — the effect body runs
		// twice on mount, which IS the regression this test exists to catch.
		await renderPanel({ checkoutCancelled: { orderId: "o-77" } })

		await waitFor(() => expect(rollback.spy.hits).toBe(1))
		await flushNetwork()
		expect(rollback.spy.hits).toBe(1)
		expect(rollback.spy.bodies[0]).toEqual({
			orderId: "o-77",
			reason: "Checkout cancelled",
		})
	})

	it("renders the cancelled outcome with a full-reload Start again pointing at this route", async () => {
		server.use(
			examregGet("event/info", () => eventLoad()).handler,
			examregPost("event/rollback", () => ({})).handler,
		)
		await renderPanel({ checkoutCancelled: { orderId: "o-77" } })

		expect(
			await screen.findByRole("heading", { name: "Registration not completed" }),
		).toBeInTheDocument()
		expect(
			screen.getByText(/nothing was charged and no place was held/i),
		).toBeInTheDocument()
		// A plain <a>, not a router Link — the fresh load after the rollback is
		// the only state worth starting from.
		expect(screen.getByRole("link", { name: "Start again" })).toHaveAttribute(
			"href",
			"/",
		)
	})

	it("does not attempt a rollback when the cancel leg carries no orderId", async () => {
		const rollback = examregPost<RollbackBody>("event/rollback", () => ({}))
		server.use(examregGet("event/info", () => eventLoad()).handler, rollback.handler)

		await renderPanel({ checkoutCancelled: { orderId: null } })

		expect(
			await screen.findByRole("heading", { name: "Registration not completed" }),
		).toBeInTheDocument()
		await flushNetwork()
		expect(rollback.spy.hits).toBe(0)
	})

	it("surfaces a failed rollback as a toast while keeping the outcome on screen", async () => {
		server.use(
			examregGet("event/info", () => eventLoad()).handler,
			http.post(ROLLBACK_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Order is locked."), {
					status: 500,
				}),
			),
		)
		await renderPanel({ checkoutCancelled: { orderId: "o-77" } })

		expect(
			await screen.findByRole("heading", { name: "Registration not completed" }),
		).toBeInTheDocument()
		await waitFor(() =>
			expect(vi.mocked(toast.error)).toHaveBeenCalledWith(
				"Unable to release the registration",
				expect.objectContaining({ description: "Order is locked." }),
			),
		)
		// Failure must not re-trigger the effect — one attempt, never a retry.
		await flushNetwork()
		expect(vi.mocked(toast.error)).toHaveBeenCalledTimes(1)
	})
})

describe("EventRegistrationPanel — payment success return", () => {
	it("renders the paid outcome before the load answers, and NEVER fires the rollback", async () => {
		const rollback = examregPost<RollbackBody>("event/rollback", () => ({}))
		server.use(
			// The load never resolves — the outcome must not wait for it.
			http.get(INFO_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope(eventLoad()))
			}),
			rollback.handler,
		)
		await renderPanel({ paymentReturn: { orderNumber: "1001" } })

		expect(
			screen.getByRole("heading", { name: "Payment received" }),
		).toBeInTheDocument()
		expect(screen.getByText("1001")).toBeInTheDocument()
		// No form behind a completed payment — nothing to submit twice.
		expect(
			screen.queryByRole("button", { name: /registration|payment/i }),
		).not.toBeInTheDocument()

		await flushNetwork()
		expect(rollback.spy.hits).toBe(0)
	})

	it("offers a guest only public-safe destinations on the paid outcome", async () => {
		server.use(examregGet("event/info", () => eventLoad()).handler)
		await renderPanel({ paymentReturn: { orderNumber: "1001" } })

		expect(screen.getByRole("link", { name: "Sign in" })).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Back to GARP.org" }),
		).toHaveAttribute("href", "https://www.garp.org")
		expect(
			screen.queryByRole("link", { name: "Go to dashboard" }),
		).not.toBeInTheDocument()
	})
})
