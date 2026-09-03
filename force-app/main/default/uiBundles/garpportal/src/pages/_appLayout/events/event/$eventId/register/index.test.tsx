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
		id: "/_appLayout/events/event/$eventId/register/",
		path: "/events/event/$eventId/register/",
		initialEntries: [entry],
	})

describe("/events/event/$eventId/register page", () => {
	it("hands variant and event id through with no return legs", async () => {
		await mount("/events/event/a0X1/register")

		expect(
			screen.getByText("panel event a0X1 paid=none cancelled=none"),
		).toBeInTheDocument()
	})

	it("maps a stripe return onto paymentReturn, coercing a numeric order number", async () => {
		await mount("/events/event/a0X1/register?stripe_return=1&on=8013")

		expect(
			screen.getByText("panel event a0X1 paid=8013 cancelled=none"),
		).toBeInTheDocument()
	})

	it("maps a cancelled checkout onto checkoutCancelled with its order id", async () => {
		await mount("/events/event/a0X1/register?checkout_cancelled=1&oid=801")

		expect(
			screen.getByText("panel event a0X1 paid=none cancelled=801"),
		).toBeInTheDocument()
	})
})
