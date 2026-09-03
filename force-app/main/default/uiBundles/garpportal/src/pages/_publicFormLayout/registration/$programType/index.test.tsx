import { screen } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { Route } from "./index"

/*
 * vi.mock (not MSW): the dispatcher panel is deep-tested by its own suite —
 * this page's contract is only URL → props, so the stub echoes what arrives.
 */
vi.mock(
	"@/components/forms/program-registration/program-registration-panel",
	() => ({
		ProgramRegistrationPanel: (props: {
			programType: string
			regCode?: string
			paymentReturn?: { orderNumber?: string } | null
		}) => (
			<p>
				panel {props.programType} code={props.regCode ?? "none"} paid=
				{props.paymentReturn
					? (props.paymentReturn.orderNumber ?? "return")
					: "none"}
			</p>
		),
	}),
)

/* Guest throughout: the member-redirect matrix is the guard's own test. */
const mount = (entry: string) =>
	renderFileRoute(Route, {
		id: "/_publicFormLayout/registration/$programType/",
		path: "/registration/$programType/",
		initialEntries: [entry],
		user: null,
	})

describe("/registration/$programType page", () => {
	it("serves the guest form with the slug and no code", async () => {
		const { router } = await mount("/registration/frm")

		expect(
			screen.getByText("panel frm code=none paid=none"),
		).toBeInTheDocument()
		expect(router.state.location.pathname).toBe("/registration/frm")
	})

	it("carries a marketing regCode through, coercing digits to a string", async () => {
		await mount("/registration/scr?regCode=2024")

		expect(
			screen.getByText("panel scr code=2024 paid=none"),
		).toBeInTheDocument()
	})

	it("maps a stripe return onto paymentReturn with its order number", async () => {
		await mount("/registration/frm?stripe_return=1&oid=801&on=8013")

		expect(
			screen.getByText("panel frm code=none paid=8013"),
		).toBeInTheDocument()
	})
})
