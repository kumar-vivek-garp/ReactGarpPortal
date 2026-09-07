import { screen } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"

import { ProgramRegistrationPanel } from "@/components/forms/program-registration/program-registration-panel"
import { renderWithRouterProviders } from "@/testing/router"

/*
 * vi.mock (not MSW): the exam panel is deep-tested by its own suite, and the
 * dispatcher's contract is only WHICH branch renders — mounting the real panel
 * would drag the entire exam load contract through MSW here just to prove a
 * slug resolved. The stub echoes the props the dispatcher must hand over.
 */
vi.mock("@/components/forms/exam-registration/exam-registration-panel", () => ({
	ExamRegistrationPanel: (props: {
		programType: string
		regCode?: string
		trackCta?: string
		paymentReturn?: { orderNumber?: string } | null
	}) => (
		<p>
			exam-panel {props.programType} code={props.regCode ?? "none"} paid=
			{props.paymentReturn?.orderNumber ?? "none"} cta={props.trackCta ?? "none"}
		</p>
	),
}))

describe("ProgramRegistrationPanel — the programme dispatcher", () => {
	it("routes a known programme slug to the exam panel with its canonical type", async () => {
		await renderWithRouterProviders(
			<ProgramRegistrationPanel programType="frm" />,
		)

		expect(
			screen.getByText(/exam-panel frm code=none paid=none/),
		).toBeInTheDocument()
		// No second header above a built form — it carries its own bar.
		expect(
			screen.queryByText(/registration form will be built here/i),
		).not.toBeInTheDocument()
		expect(screen.queryByRole("heading")).not.toBeInTheDocument()
	})

	it("resolves legacy slug aliases before dispatching — /rai reaches Risk AI", async () => {
		await renderWithRouterProviders(
			<ProgramRegistrationPanel programType="RAI" />,
		)

		expect(screen.getByText(/exam-panel riskai/)).toBeInTheDocument()
	})

	it("hands the reg code and payment return through untouched", async () => {
		await renderWithRouterProviders(
			<ProgramRegistrationPanel
				programType="scr"
				regCode="TEAM24"
				paymentReturn={{ orderNumber: "8013" }}
			/>,
		)

		expect(
			screen.getByText(/exam-panel scr code=TEAM24 paid=8013/),
		).toBeInTheDocument()
	})

	it("routes the membership programme to the exam panel with its wire type", async () => {
		// The address is `membership`; the module is asked for `mem`. The
		// alias goes the other way too, and neither gets the placeholder.
		await renderWithRouterProviders(
			<ProgramRegistrationPanel programType="membership" trackCta="PortalMyAccountPage" />,
		)
		expect(screen.getByText(/exam-panel mem code=none paid=none/)).toBeInTheDocument()
		expect(screen.getByText(/cta=PortalMyAccountPage/)).toBeInTheDocument()
		expect(screen.queryByRole("heading")).not.toBeInTheDocument()
	})

	it("gives an unbuilt programme a placeholder page instead of a dead end", async () => {
		// `micro` is a real programme kind with no registry entry (no form built).
		await renderWithRouterProviders(
			<ProgramRegistrationPanel programType="micro" />,
		)

		expect(
			screen.getByRole("heading", { level: 1, name: "MICRO Registration" }),
		).toBeInTheDocument()
		expect(
			screen.getByText("The MICRO registration form will be built here."),
		).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Programs" })).toBeInTheDocument()
		expect(screen.queryByText(/exam-panel/)).not.toBeInTheDocument()
	})
})
