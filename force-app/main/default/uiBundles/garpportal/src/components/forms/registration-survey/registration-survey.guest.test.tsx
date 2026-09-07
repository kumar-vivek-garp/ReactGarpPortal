import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import { RegistrationSurvey } from "@/components/forms/registration-survey/registration-survey"
import { memberPortalError } from "@/testing/factories/envelope"
import { demographicsOptions } from "@/testing/factories/exam-payment"
import { chooseSelectOption } from "@/testing/exam-registration-ui"
import {
	EXAMREG_PATH,
	examregGet,
	examregPost,
} from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

function guestOrg() {
	const demographics = examregGet("demographics", () => demographicsOptions())
	const options = examregGet("options", () => ({
		companies: ["Acme Bank"],
		schools: ["MIT"],
	}))
	const save = examregPost<{ key: string; values: Record<string, unknown> }>(
		"demographics",
		() => ({ saved: true, rejected: [] }),
	)
	server.use(demographics.handler, options.handler, save.handler)
	return { demographics, options, save }
}

/**
 * A GUEST fresh out of registration. The only thing they hold is the id their
 * own registration handed back, and that is the save key — never a contact
 * id from the browser.
 */
describe("RegistrationSurvey — guest", () => {
	it("loads the registration module's own picklists and saves with the registration key", async () => {
		const org = guestOrg()
		const onFinished = vi.fn()
		const user = userEvent.setup()

		renderWithProviders(
			<RegistrationSurvey surveyKey="a0H-staged" onFinished={onFinished} />,
			{ user: null },
		)

		expect(
			await screen.findByRole("heading", { name: /Help us tailor your/ }),
		).toBeInTheDocument()
		// Step 1 — work.
		await chooseSelectOption(user, /work status/i, "Working")
		await chooseSelectOption(user, /job function/i, "Risk Management")
		// The specialty only appears under Risk Management.
		await chooseSelectOption(user, /risk specialty/i, "Credit Risk")
		await user.type(screen.getByLabelText(/most recent company/i), "Acme Bank")
		// The ring counts as they go.
		expect(screen.getByText("4 of 13 answered")).toBeInTheDocument()
		await user.click(screen.getByRole("button", { name: "Next" }))
		// Step 2 — experience (the step slides in, so find, not get). Step 1's
		// answers survive the step change.
		await user.click(await screen.findByRole("checkbox", { name: "CFA" }))
		await user.click(screen.getByRole("button", { name: "Next" }))
		// Step 3 — education, then save.
		expect(await screen.findByLabelText(/school attended/i)).toBeInTheDocument()
		await user.click(screen.getByRole("button", { name: "Save my answers" }))

		await waitFor(() => {
			expect(onFinished).toHaveBeenCalledWith("saved")
		})
		expect(org.save.spy.hits).toBe(1)
		expect(org.save.spy.bodies[0].key).toBe("a0H-staged")
		expect(org.save.spy.bodies[0].values).toMatchObject({
			Currently_Working_Status__c: "Working",
			Job_Function__c: "Risk Management",
			Risk_Specialty__c: "Credit Risk",
			Company__c: "Acme Bank",
			Professional_Designation_CFA__c: true,
			Professional_Designation_CA__c: false,
			// Untouched answers post as null, not "".
			Area_of_Concentration__c: null,
			Other_Qualifications__c: null,
		})
	})

	it("hides the specialty again, and drops it from the payload, when the job function moves away", async () => {
		const org = guestOrg()
		const user = userEvent.setup()

		renderWithProviders(
			<RegistrationSurvey surveyKey="a0H-staged" onFinished={vi.fn()} />,
			{ user: null },
		)
		await screen.findByRole("heading", { name: /Help us tailor your/ })

		expect(screen.queryByRole("combobox", { name: /risk specialty/i })).not.toBeInTheDocument()
		await chooseSelectOption(user, /job function/i, "Risk Management")
		await chooseSelectOption(user, /risk specialty/i, "Credit Risk")
		await chooseSelectOption(user, /job function/i, "Trading")
		expect(screen.queryByRole("combobox", { name: /risk specialty/i })).not.toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "Next" }))
		await user.click(await screen.findByRole("button", { name: "Next" }))
		await user.click(await screen.findByRole("button", { name: "Save my answers" }))
		await waitFor(() => {
			expect(org.save.spy.hits).toBe(1)
		})
		expect(org.save.spy.bodies[0].values.Risk_Specialty__c).toBeNull()
	})

	it("Skip saves nothing and ends the survey", async () => {
		const org = guestOrg()
		const onFinished = vi.fn()
		const user = userEvent.setup()

		renderWithProviders(
			<RegistrationSurvey surveyKey="a0H-staged" onFinished={onFinished} />,
			{ user: null },
		)
		await user.click(await screen.findByRole("button", { name: "Skip for now" }))

		expect(onFinished).toHaveBeenCalledWith("skipped")
		expect(org.save.spy.hits).toBe(0)
	})

	it("a partial save shows the rejected answers inline and stays", async () => {
		const demographics = examregGet("demographics", () => demographicsOptions())
		const options = examregGet("options", () => ({ companies: [], schools: [] }))
		const save = examregPost("demographics", () => ({
			saved: true,
			rejected: ["Company__c"],
		}))
		server.use(demographics.handler, options.handler, save.handler)
		const onFinished = vi.fn()
		const user = userEvent.setup()

		renderWithProviders(
			<RegistrationSurvey surveyKey="a0H-staged" onFinished={onFinished} />,
			{ user: null },
		)
		await user.click(await screen.findByRole("button", { name: "Next" }))
		await user.click(await screen.findByRole("button", { name: "Next" }))
		await user.click(await screen.findByRole("button", { name: "Save my answers" }))

		expect(await screen.findByRole("alert")).toHaveTextContent(/Company__c/)
		expect(onFinished).not.toHaveBeenCalled()
		expect(screen.getByRole("button", { name: "Save my answers" })).toBeEnabled()
	})

	it("with no key there is nothing to attach answers to — unavailable, with Continue", async () => {
		const org = guestOrg()
		const onFinished = vi.fn()
		const user = userEvent.setup()

		renderWithProviders(
			<RegistrationSurvey surveyKey={null} onFinished={onFinished} />,
			{ user: null },
		)

		expect(
			screen.getByText("Your registration is confirmed"),
		).toBeInTheDocument()
		await user.click(screen.getByRole("button", { name: "Continue" }))
		expect(onFinished).toHaveBeenCalledWith("unavailable")
		expect(org.demographics.spy.hits).toBe(0)
	})

	it("when the picklists cannot be read the survey is not offered", async () => {
		server.use(
			http.get(`${EXAMREG_PATH}/demographics`, () =>
				HttpResponse.json(memberPortalError(403, "Forbidden"), { status: 403 }),
			),
			examregGet("options", () => ({ companies: [], schools: [] })).handler,
		)

		renderWithProviders(
			<RegistrationSurvey surveyKey="a0H-staged" onFinished={vi.fn()} />,
			{ user: null },
		)

		expect(
			await screen.findByRole("button", { name: "Continue" }),
		).toBeInTheDocument()
		expect(screen.queryByRole("button", { name: "Next" })).not.toBeInTheDocument()
	})
})
