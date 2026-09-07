import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { ExamSetupView } from "@/api/exam-setup"
import { ExamSetupPanel } from "@/components/forms/exam-setup/exam-setup-panel"
import { accountOptionsView } from "@/testing/factories/account-options"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { examAdmin, examSetupView, examSite } from "@/testing/factories/exam-setup"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const FORM_PATH = "/services/apexrest/memberportal/examSetup"
const OPTIONS_PATH = "/services/apexrest/memberportal/options"
const SAVE_PATH = "/services/apexrest/memberportal/examSetupId"

function org(view: ExamSetupView = examSetupView()) {
	let saves = 0
	server.use(
		http.get(FORM_PATH, () => HttpResponse.json(memberPortalEnvelope(view))),
		http.get(OPTIONS_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(accountOptionsView())),
		),
		http.post(SAVE_PATH, () => {
			saves += 1
			return HttpResponse.json(memberPortalEnvelope({ statusCode: 200 }))
		}),
	)
	return { get saves() { return saves } }
}

const mount = () => renderWithRouterProviders(<ExamSetupPanel programType="frm" />)

const admins = (name = /When do you plan to sit for the exam\?/) =>
	screen.findByRole("radiogroup", { name })
const site = () => screen.getByRole("combobox", { name: /Where do you plan to sit the exam\?/ })

describe("ExamSetupPanel — choosing the sitting", () => {
	it("offers the administrations as tiles, the current one marked and checked", async () => {
		org()
		await mount()
		await admins()

		expect(screen.getByRole("radio", { name: /May 2026/ })).toBeChecked()
		expect(screen.getByRole("radio", { name: /November 2026/ })).not.toBeChecked()
		expect(screen.getByText("Current")).toBeInTheDocument()
		expect(site()).toHaveTextContent("London")
	})

	it("offers no Part II for a single-part programme", async () => {
		org()
		await mount()
		await admins()
		expect(screen.queryByText("Part II")).not.toBeInTheDocument()
	})

	it("labels both parts distinctly for a two-part programme", async () => {
		org(
			examSetupView({
				examPart2SelectionInfo: [examAdmin({ id: "admin-p2", name: "December 2026" })],
			}),
		)
		await mount()

		expect(
			await screen.findByRole("radiogroup", { name: /When do you plan to sit for Part I of the exam\?/ }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("radiogroup", { name: /When do you plan to sit for Part II of the exam\?/ }),
		).toBeInTheDocument()
	})

	// The sites hang off the administration, so a site carried across would name
	// a venue that is not on offer under the new date.
	it("clears the site when the administration changes", async () => {
		const user = userEvent.setup()
		org()
		await mount()
		await admins()
		expect(site()).toHaveTextContent("London")

		await user.click(screen.getByRole("radio", { name: /November 2026/ }))

		await waitFor(() => expect(site()).toHaveTextContent("Select a location"))
	})

	it("hides the site select entirely when the administration has none", async () => {
		org(examSetupView({ examPart1SelectionInfo: [examAdmin({ isSelected: true, examSites: [] })] }))
		await mount()
		await admins()

		expect(
			screen.queryByRole("combobox", { name: /Where do you plan to sit/ }),
		).not.toBeInTheDocument()
		expect(
			screen.getByText("You'll choose your exam location once scheduling opens for this administration."),
		).toBeInTheDocument()
	})

	it("reflects a change in the bar and the rail, and Reset puts it back", async () => {
		const user = userEvent.setup()
		org()
		await mount()
		await admins()
		expect(screen.queryByRole("button", { name: "Reset" })).not.toBeInTheDocument()

		await user.click(screen.getByRole("radio", { name: /November 2026/ }))

		expect(await screen.findByText("New sitting")).toBeInTheDocument()
		expect(screen.getAllByText("Changed").length).toBeGreaterThan(0)
		expect(screen.getByText("was May 2026")).toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "Reset" }))

		await waitFor(() => expect(screen.getByRole("radio", { name: /May 2026/ })).toBeChecked())
		expect(screen.getByText("Sitting")).toBeInTheDocument()
		expect(screen.queryByText("Changed")).not.toBeInTheDocument()
	})

	it("refuses to save until an administration is chosen, saying so under the tiles", async () => {
		const user = userEvent.setup()
		const spy = org(
			examSetupView({ examPart1SelectionInfo: [examAdmin({ examSites: [examSite()] })] }),
		)
		await mount()
		await admins()

		await user.click(screen.getByRole("button", { name: "Save exam setup" }))

		expect(
			await screen.findByText("Choose when you plan to sit the exam."),
		).toBeInTheDocument()
		expect(spy.saves).toBe(0)
	})

	it("puts the Part II message under Part II", async () => {
		const user = userEvent.setup()
		org(
			examSetupView({
				examPart2SelectionInfo: [examAdmin({ id: "admin-p2", name: "December 2026" })],
			}),
		)
		await mount()
		await admins(/Part I of the exam/)

		await user.click(screen.getByRole("button", { name: "Save exam setup" }))

		const message = await screen.findByText("Choose when you plan to sit Part II.")
		expect(
			screen.getByRole("radiogroup", { name: /Part II of the exam/ }).parentElement,
		).toContainElement(message)
	})
})
