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
	Currently_Working_Status__c: pick(["Employed"]),
	Area_of_Concentration__c: pick(["Banking"]),
	Corporate_Title__c: pick(["Analyst"]),
	Job_Function__c: pick(["Risk Management", "Trading"]),
	Risk_Specialty__c: pick(["Credit Risk"]),
	Highest_Degree__c: pick(["Masters"]),
	Expected_Graduation_Month__c: pick(["May"]),
}

function serveOrg(
	saveRespond: () => Response = () =>
		HttpResponse.json(
			memberPortalEnvelope({ applied: [], rejected: [], completeness: null }),
		),
) {
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
			return saveRespond()
		}),
	)
	return { saves }
}

/** Complete enough that Save passes validation without further clicks. */
function completeAccount(): AccountView {
	const account = accountView()
	account.career = {
		...account.career,
		currentlyWorkingStatus: "Employed",
		areaOfConcentration: "Banking",
		company: "Abrdn plc",
		corporateTitle: "Analyst",
		jobFunction: "Risk Management",
	}
	account.expertise = { ...account.expertise, riskSpecialty: "Credit Risk" }
	account.academic = { ...account.academic, highestDegree: "Masters" }
	return account
}

function renderForm(account: AccountView = completeAccount()) {
	const onSaved = vi.fn()
	const view = renderWithProviders(
		<CareerInformationEditForm account={account} onSaved={onSaved} />,
	)
	return { ...view, onSaved }
}

async function selectOption(
	user: ReturnType<typeof userEvent.setup>,
	comboboxName: string,
	option: string,
) {
	await user.click(screen.getByRole("combobox", { name: comboboxName }))
	await user.click(await screen.findByRole("option", { name: option }))
}

describe("the risk-specialty cascade", () => {
	it("asks for a specialty only while the job function is Risk Management", async () => {
		serveOrg()
		const user = userEvent.setup()
		renderForm()

		expect(
			await screen.findByRole("combobox", { name: "What is your risk specialty?" }),
		).toHaveTextContent("Credit Risk")

		await selectOption(user, "What is your job function?", "Trading")
		expect(
			screen.queryByRole("combobox", { name: "What is your risk specialty?" }),
		).not.toBeInTheDocument()
	})

	it("nulls the stale specialty on the wire after switching away", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByRole("combobox", { name: "What is your job function?" })
		await selectOption(user, "What is your job function?", "Trading")
		await user.click(screen.getByRole("button", { name: "Save" }))

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.saves[0]).toMatchObject({
			Job_Function__c: "Trading",
			Risk_Specialty__c: null,
		})
	})
})

describe("designations", () => {
	it("asks for the other qualification only once Other is ticked, and requires it", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm()

		await screen.findByRole("checkbox", { name: "Other" })
		expect(screen.queryByLabelText("Other qualifications")).not.toBeInTheDocument()

		await user.click(screen.getByRole("checkbox", { name: "Other" }))
		await user.click(screen.getByRole("button", { name: "Save" }))
		expect(
			await screen.findByText("Enter your other qualification"),
		).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})

	it("posts every designation as a boolean plus the qualification text", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await user.click(await screen.findByRole("checkbox", { name: "CFA" }))
		await user.click(screen.getByRole("checkbox", { name: "Other" }))
		await user.type(
			screen.getByLabelText("Other qualifications"),
			"Chartered Actuary",
		)
		await user.click(screen.getByRole("button", { name: "Save" }))

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.saves[0]).toMatchObject({
			Professional_Designation_CFA__c: true,
			Professional_Designation_CPA__c: false,
			Professional_Designation_Other__c: true,
			Other_Qualifications__c: "Chartered Actuary",
			Currently_Working_Status__c: "Employed",
			Company__c: "Abrdn plc",
			Risk_Specialty__c: "Credit Risk",
			Highest_Degree__c: "Masters",
			// Never answered — posted as null, not "".
			Industry_Working_Year__c: null,
			School_Name__c: null,
		})
	})
})

describe("failure", () => {
	it("keeps the form open when the profile service refuses", async () => {
		const org = serveOrg(() =>
			HttpResponse.json(memberPortalError(500, "Profile locked"), {
				status: 500,
			}),
		)
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await user.click(await screen.findByRole("button", { name: "Save" }))

		await vi.waitFor(() => {
			expect(org.saves).toHaveLength(1)
		})
		expect(onSaved).not.toHaveBeenCalled()
		await vi.waitFor(() => {
			expect(screen.getByRole("button", { name: "Save" })).toBeEnabled()
		})
	})
})
