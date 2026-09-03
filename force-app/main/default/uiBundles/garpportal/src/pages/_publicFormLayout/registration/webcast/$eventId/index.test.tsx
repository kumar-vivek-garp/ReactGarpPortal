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
		id: "/_publicFormLayout/registration/webcast/$eventId/",
		path: "/registration/webcast/$eventId/",
		initialEntries: [entry],
		user: null,
	})

describe("/registration/webcast/$eventId page", () => {
	it("serves the guest form with variant and event id", async () => {
		await mount("/registration/webcast/a0X3")

		expect(
			screen.getByText("panel webcast a0X3 paid=none cancelled=none"),
		).toBeInTheDocument()
	})

	it("maps the payment-return and cancel legs from the search", async () => {
		await mount(
			"/registration/webcast/a0X3?stripe_return=1&on=42&checkout_cancelled=1&oid=7",
		)

		expect(
			screen.getByText("panel webcast a0X3 paid=42 cancelled=7"),
		).toBeInTheDocument()
	})
})
