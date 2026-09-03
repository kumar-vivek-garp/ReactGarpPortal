import { screen } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { Route } from "./index"

/*
 * vi.mock (not MSW): the dispatcher panel is deep-tested by its own suite —
 * this page's contract is only URL → props, so the stub echoes what the page
 * hands over instead of dragging the exam load contract through MSW.
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

const mount = (entry: string) =>
	renderFileRoute(Route, {
		id: "/_appLayout/programs/$programType/register/",
		path: "/programs/$programType/register/",
		initialEntries: [entry],
		user: null,
	})

describe("/programs/$programType/register page", () => {
	it("hands the slug through with no code and no payment return", async () => {
		await mount("/programs/frm/register")

		expect(
			screen.getByText("panel frm code=none paid=none"),
		).toBeInTheDocument()
	})

	it("passes regCode through, preferring it over teamCode", async () => {
		await mount("/programs/frm/register?regCode=TEAM24&teamCode=OTHER")

		expect(
			screen.getByText("panel frm code=TEAM24 paid=none"),
		).toBeInTheDocument()
	})

	it("falls back to teamCode, coercing an all-digit value to a string", async () => {
		await mount("/programs/scr/register?teamCode=2024")

		expect(
			screen.getByText("panel scr code=2024 paid=none"),
		).toBeInTheDocument()
	})

	it("maps a stripe return onto paymentReturn with its order number", async () => {
		await mount("/programs/frm/register?stripe_return=1&oid=801&on=8013")

		expect(
			screen.getByText("panel frm code=none paid=8013"),
		).toBeInTheDocument()
	})
})
