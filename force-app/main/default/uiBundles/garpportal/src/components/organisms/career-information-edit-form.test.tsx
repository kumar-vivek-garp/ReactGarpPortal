import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { AccountView } from "@/api/account/types"
import { CareerInformationEditForm } from "@/components/organisms/career-information-edit-form"
import { accountView } from "@/testing/factories/account"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const OPTIONS_PATH = "/services/apexrest/memberportal/options"
const PROFILE_PATH = "/services/apexrest/memberportal/profile"

function pick(values: string[]) {
	return values.map((value) => ({ label: value, value }))
}

const PICKLISTS = {
	Currently_Working_Status__c: pick(["Employed", "Student"]),
	Area_of_Concentration__c: pick(["Banking", "Insurance"]),
	Corporate_Title__c: pick(["Analyst", "Director"]),
	Job_Function__c: pick(["Risk Management", "Trading"]),
	Risk_Specialty__c: pick(["Credit Risk", "Market Risk"]),
	Highest_Degree__c: pick(["Bachelors", "Masters"]),
	Expected_Graduation_Month__c: pick(["May", "December"]),
}

function serveOrg() {
	const saves: Array<Record<string, unknown>> = []
	server.use(
		http.get(OPTIONS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({ picklists: PICKLISTS, chapters: [] }),
			),
		),
		http.post(PROFILE_PATH, async ({ request }) => {
			const body = (await request.json()) as { values: Record<string, unknown> }
			saves.push(body.values)
			return HttpResponse.json(
				memberPortalEnvelope({ applied: [], rejected: [], completeness: null }),
			)
		}),
	)
	return { saves }
}

/** The factory only parameterises identity blocks; set career fields directly. */
function seededAccount(): AccountView {
	const account = accountView()
	account.career = {
		...account.career,
		currentlyWorkingStatus: "Employed",
		areaOfConcentration: "Banking",
		industryWorkingYear: "2015",
		company: "Abrdn plc",
		corporateTitle: "Analyst",
		jobFunction: "Trading",
	}
	account.academic = { ...account.academic, highestDegree: "Masters" }
	return account
}

function renderForm(
	account: AccountView = accountView(),
	focusField?: "jobFunction",
) {
	const onSaved = vi.fn()
	const view = renderWithProviders(
		<CareerInformationEditForm
			account={account}
			onSaved={onSaved}
			focusField={focusField}
		/>,
	)
	return { ...view, onSaved }
}

async function findSaveButton() {
	return await screen.findByRole("button", { name: "Save" })
}

describe("hydration", () => {
	it("seeds every control from the account record", async () => {
		serveOrg()
		renderForm(seededAccount())

		expect(
			await screen.findByRole("combobox", { name: "What is your work status?" }),
		).toHaveTextContent("Employed")
		expect(
			screen.getByRole("combobox", {
				name: "What industry do/did you specialize in?",
			}),
		).toHaveTextContent("Banking")
		expect(
			screen.getByLabelText("What year did you start working in the industry?"),
		).toHaveValue("2015")
		expect(
			screen.getByLabelText("What is your most recent company?"),
		).toHaveValue("Abrdn plc")
		expect(
			screen.getByRole("combobox", { name: "Degree program" }),
		).toHaveTextContent("Masters")
		// Trading is not the risk job function, so no specialty is asked for.
		expect(
			screen.queryByRole("combobox", { name: "What is your risk specialty?" }),
		).not.toBeInTheDocument()
	})

	it("admits a failed options load and keeps Save locked", async () => {
		server.use(
			http.get(OPTIONS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Options down"), {
					status: 500,
				}),
			),
		)
		renderForm()

		expect(
			await screen.findByText(/couldn't load the career information options/),
		).toBeInTheDocument()
		expect(await findSaveButton()).toBeDisabled()
	})

	it("lands focus on the field a completeness chip complained about", async () => {
		serveOrg()
		renderForm(accountView(), "jobFunction")

		const jobFunction = await screen.findByRole("combobox", {
			name: "What is your job function?",
		})
		await vi.waitFor(() => {
			expect(jobFunction).toHaveFocus()
		})
	})
})

describe("validation", () => {
	it("names every missing required answer and sends nothing", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await user.click(await findSaveButton())

		expect(
			await screen.findByText("Please select a work status"),
		).toBeInTheDocument()
		expect(screen.getByText("Please select an industry")).toBeInTheDocument()
		expect(
			screen.getByText("Please select a professional level"),
		).toBeInTheDocument()
		expect(screen.getByText("Please select a job function")).toBeInTheDocument()
		expect(
			screen.getByText("Please select a degree program"),
		).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
		expect(onSaved).not.toHaveBeenCalled()
	})

	it("rejects a year that is not four digits", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm(seededAccount())

		const yearBox = await screen.findByLabelText(
			"What year did you start working in risk management?",
		)
		await user.type(yearBox, "20x5")
		await user.click(await findSaveButton())

		expect(await screen.findByText("Enter a 4-digit year")).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})

	it("holds the company to length and character rules", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm(seededAccount())

		const company = await screen.findByLabelText(
			"What is your most recent company?",
		)
		await user.clear(company)
		await user.type(company, "A")
		await user.click(await findSaveButton())
		expect(
			await screen.findByText("Company must be at least 2 characters"),
		).toBeInTheDocument()

		await user.clear(company)
		await user.type(company, "Abrdn <plc>")
		await user.click(await findSaveButton())
		expect(
			await screen.findByText(
				"Company can only include letters, numbers, and basic punctuation",
			),
		).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})
})
