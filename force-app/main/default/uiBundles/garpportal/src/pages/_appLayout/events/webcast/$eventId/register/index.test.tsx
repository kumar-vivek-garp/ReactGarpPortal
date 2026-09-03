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

const mount = (entry: string) =>
	renderFileRoute(Route, {
		id: "/_appLayout/events/webcast/$eventId/register/",
		path: "/events/webcast/$eventId/register/",
		initialEntries: [entry],
	})

describe("/events/webcast/$eventId/register page", () => {
	it("hands the webcast variant and event id through", async () => {
		await mount("/events/webcast/a0X3/register")

		expect(
			screen.getByText("panel webcast a0X3 paid=none cancelled=none"),
		).toBeInTheDocument()
	})

	it("maps the payment-return and cancel legs from the search", async () => {
		await mount(
			"/events/webcast/a0X3/register?stripe_return=1&on=42&checkout_cancelled=1&oid=7",
		)

		expect(
			screen.getByText("panel webcast a0X3 paid=42 cancelled=7"),
		).toBeInTheDocument()
	})
})
