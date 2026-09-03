import { screen } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { Route } from "./index"

/*
 * vi.mock (not MSW): the event panel is deep-tested by its own suite — this
 * page's contract is only URL → props, so the stub echoes what arrives.
 */
vi.mock(
	"@/components/forms/event-registration/event-registration-panel",
	() => ({
		EventRegistrationPanel: (props: {
			variant: string
			eventId: string
			paymentReturn?: { orderNumber?: string } | null
			checkoutCancelled?: { orderId?: string } | null
		}) => (
			<p>
				panel {props.variant} {props.eventId} paid=
				{props.paymentReturn
					? (props.paymentReturn.orderNumber ?? "return")
					: "none"}{" "}
				cancelled=
				{props.checkoutCancelled
					? (props.checkoutCancelled.orderId ?? "return")
					: "none"}
			</p>
		),
	}),
)

/* Guest throughout: the member-redirect matrix is the guard's own test. */
const mount = (entry: string) =>
	renderFileRoute(Route, {
		id: "/_publicFormLayout/registration/event/$eventId/",
		path: "/registration/event/$eventId/",
		initialEntries: [entry],
		user: null,
	})

describe("/registration/event/$eventId page", () => {
	it("serves the guest form with variant and event id", async () => {
		const { router } = await mount("/registration/event/a0X1")

		expect(
			screen.getByText("panel event a0X1 paid=none cancelled=none"),
		).toBeInTheDocument()
		expect(router.state.location.pathname).toBe("/registration/event/a0X1")
	})

	it("maps the payment-return and cancel legs from the search", async () => {
		await mount(
			"/registration/event/a0X1?stripe_return=1&on=42&checkout_cancelled=1&oid=7",
		)

		expect(
			screen.getByText("panel event a0X1 paid=42 cancelled=7"),
		).toBeInTheDocument()
	})
})
