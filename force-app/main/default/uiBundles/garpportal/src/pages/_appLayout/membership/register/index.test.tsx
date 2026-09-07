import { screen } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { Route } from "./index"

/*
 * vi.mock (not MSW): the dispatcher panel is deep-tested by its own suite —
 * this page's contract is only URL → props, so the stub echoes what the page
 * hands over instead of dragging the membership load contract through MSW.
 */
vi.mock(
	"@/components/forms/program-registration/program-registration-panel",
	() => ({
		ProgramRegistrationPanel: (props: {
			programType: string
			regCode?: string
			trackCta?: string
			paymentReturn?: { statusId?: string; orderNumber?: string } | null
			checkoutCancelled?: { orderId?: string } | null
			resumeStagedId?: string
		}) => (
			<p>
				panel {props.programType} code={props.regCode ?? "none"} cta=
				{props.trackCta ?? "none"} paid=
				{props.paymentReturn
					? `${props.paymentReturn.statusId ?? "?"}/${props.paymentReturn.orderNumber ?? "-"}`
					: "none"}{" "}
				cancelled={props.checkoutCancelled?.orderId ?? "none"} resume=
				{props.resumeStagedId ?? "none"}
			</p>
		),
	}),
)

const mount = (entry: string) =>
	renderFileRoute(Route, {
		id: "/_appLayout/membership/register/",
		path: "/membership/register/",
		initialEntries: [entry],
		user: null,
	})

describe("/membership/register page", () => {
	it("serves the membership programme with a fixed slug and no code", async () => {
		await mount("/membership/register")

		expect(
			screen.getByText(
				"panel membership code=none cta=none paid=none cancelled=none resume=none",
			),
		).toBeInTheDocument()
	})

	it("hands the attribution tag and a reg code through", async () => {
		await mount("/membership/register?track_cta=PortalMyAccountPage&regCode=TEAM24")

		expect(
			screen.getByText(
				"panel membership code=TEAM24 cta=PortalMyAccountPage paid=none cancelled=none resume=none",
			),
		).toBeInTheDocument()
	})

	it("maps a stripe return onto paymentReturn, coercing all-numeric params", async () => {
		await mount("/membership/register?stripe_return=1&oid=801&on=8013")

		expect(
			screen.getByText(
				"panel membership code=none cta=none paid=801/8013 cancelled=none resume=none",
			),
		).toBeInTheDocument()
	})

	it("maps the cancel leg with the order to roll back", async () => {
		await mount("/membership/register?checkout_cancelled=1&oid=801")

		expect(
			screen.getByText(
				"panel membership code=none cta=none paid=none cancelled=801 resume=none",
			),
		).toBeInTheDocument()
	})
})
