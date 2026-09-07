import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { ExamSetupView } from "@/api/exam-setup"
import { ExamSetupPanel } from "@/components/forms/exam-setup/exam-setup-panel"
import { accountOptionsView } from "@/testing/factories/account-options"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { examSetupIdInfo, examSetupView } from "@/testing/factories/exam-setup"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const FORM_PATH = "/services/apexrest/memberportal/examSetup"
const OPTIONS_PATH = "/services/apexrest/memberportal/options"

function org(view: ExamSetupView = examSetupView()) {
	server.use(
		http.get(FORM_PATH, () => HttpResponse.json(memberPortalEnvelope(view))),
		http.get(OPTIONS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope(
					accountOptionsView({
						picklists: {
							Currently_Working_Status__c: [{ label: "Working", value: "Working" }],
							Currently_in_School_Status__c: [{ label: "In School", value: "In School" }],
						},
					}),
				),
			),
		),
	)
}

const mount = (programType = "frm") =>
	renderWithRouterProviders(<ExamSetupPanel programType={programType} />)

const ready = () => screen.findByRole("button", { name: "Save exam setup" })

describe("ExamSetupPanel — the ID card", () => {
	it("asks an FRM candidate for a government ID, with the document as tiles", async () => {
		org()
		await mount()
		await ready()

		expect(screen.getByRole("radiogroup", { name: /ID type/ })).toBeInTheDocument()
		expect(screen.getByRole("radio", { name: "Passport" })).toBeInTheDocument()
		expect(screen.getByRole("radio", { name: "Driver's License" })).toBeInTheDocument()
		expect(screen.getByLabelText(/^ID number/)).toBeInTheDocument()
		expect(screen.getByLabelText(/^Confirm ID number/)).toBeInTheDocument()
		// The expiry is a calendar behind a button, not a bare text box.
		expect(screen.getByLabelText(/^ID expiration date/)).toHaveTextContent("January 1st, 2030")
	})

	// A non-FRM candidate is never asked; their sites do not demand photo ID.
	it("asks a non-FRM candidate for name and mobile only", async () => {
		org()
		await mount("scr")
		await ready()

		expect(screen.getByLabelText(/^Name as it appears on your ID/)).toBeInTheDocument()
		expect(screen.queryByLabelText(/^ID number/)).not.toBeInTheDocument()
		expect(screen.queryByRole("radio", { name: "Passport" })).not.toBeInTheDocument()
	})

	it("seeds both ID boxes so a stored number does not read as a mismatch", async () => {
		org()
		await mount()
		await ready()

		expect(screen.getByLabelText(/^ID number/)).toHaveValue("45678")
		expect(screen.getByLabelText(/^Confirm ID number/)).toHaveValue("45678")
	})

	it("selects the stored ID type even though Apex spells it differently", async () => {
		org(examSetupView({ idInfo: examSetupIdInfo({ idType: "Driver License" }) }))
		await mount()
		await ready()

		expect(screen.getByRole("radio", { name: "Driver's License" })).toBeChecked()
	})

	it("seeds the mobile pair from the record", async () => {
		org()
		await mount()
		await ready()

		expect(screen.getByRole("combobox", { name: "Mobile number country code" })).toHaveTextContent(
			"United States (+1)",
		)
		expect(screen.getByLabelText(/^Mobile number\s*\*?$/)).toHaveValue("5551234")
	})

	it("hides the OSTA card away from a mainland-China centre", async () => {
		org()
		await mount()
		await ready()
		expect(screen.queryByLabelText(/Full name in Chinese/)).not.toBeInTheDocument()
	})

	it("shows the OSTA card, with server-served statuses, at a China centre", async () => {
		org(examSetupView({ idInfo: examSetupIdInfo({ isOSTA: true }) }))
		await mount()
		await ready()

		expect(screen.getByText("Your exam centre needs a little more")).toBeInTheDocument()
		expect(screen.getByRole("checkbox", { name: /I agree to GARP sharing/ })).toBeInTheDocument()
		expect(screen.getByRole("radio", { name: "China" })).toBeInTheDocument()
		expect(screen.getByRole("radio", { name: "Non-China" })).toBeInTheDocument()
		expect(screen.getByLabelText(/^Date of birth/)).toBeInTheDocument()
		// Picklists come from `GET options`, not from a hardcoded list.
		expect(screen.getByLabelText(/^Current working status/)).toBeInTheDocument()
	})

	it("switches the ID number placeholder to the full number at a China centre", async () => {
		org(examSetupView({ idInfo: examSetupIdInfo({ isOSTA: true }) }))
		await mount()
		await ready()
		expect(screen.getByLabelText(/^ID number/)).toHaveAttribute("placeholder", "Enter ID Number")
	})
})
