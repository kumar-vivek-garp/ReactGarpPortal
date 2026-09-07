import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { RegistrationSurvey } from "@/components/forms/registration-survey/registration-survey"
import { accountView } from "@/testing/factories/account"
import { accountOptionsView } from "@/testing/factories/account-options"
import { demographicsOptions } from "@/testing/factories/exam-payment"
import { myAccountOrg } from "@/testing/msw/handlers/account"
import { currentUserWireHandlers } from "@/testing/msw/handlers/auth"
import { examregGet, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003-member",
	photoUrl: null,
}

function memberOrg() {
	const view = accountView()
	view.career.jobFunction = "Trading"
	view.career.company = "Old Co"
	view.designations.CFA = true
	const demographics = demographicsOptions()
	const org = myAccountOrg({
		view,
		options: accountOptionsView({
			picklists: demographics.picklists,
			workingYears: demographics.workingYears,
			graduationYears: demographics.graduationYears,
			organizations: ["Old Co", "New Co"],
			schools: ["MIT"],
		}),
	})
	// The registration module's own survey endpoints must NOT be touched by
	// a member — their record is the member portal's.
	const guestPicklists = examregGet("demographics", () => demographics)
	const guestSave = examregPost("demographics", () => ({ saved: true, rejected: [] }))
	// The session probe re-asks the wire on mount; without an answer it would
	// resolve to null and flip the survey into guest mode mid-render.
	server.use(
		...currentUserWireHandlers(MEMBER),
		...org.handlers,
		guestPicklists.handler,
		guestSave.handler,
	)
	return { ...org, guestPicklists, guestSave }
}

/** A signed-in member: seeded from their record, saved through their profile. */
describe("RegistrationSurvey — member", () => {
	it("seeds from the member's record and saves through the member-portal profile", async () => {
		const org = memberOrg()
		const onFinished = vi.fn()
		const user = userEvent.setup()

		renderWithProviders(
			<RegistrationSurvey surveyKey="801-order" onFinished={onFinished} />,
			{ user: MEMBER },
		)

		expect(
			await screen.findByRole("heading", { name: /Help us tailor your/ }),
		).toBeInTheDocument()
		// Confirms rather than re-asks — and the seed already counts as progress.
		expect(screen.getByLabelText(/most recent company/i)).toHaveValue("Old Co")
		expect(screen.getByRole("combobox", { name: /job function/i })).toHaveTextContent("Trading")
		expect(screen.getByText("3 of 12 answered")).toBeInTheDocument()

		await user.clear(screen.getByLabelText(/most recent company/i))
		await user.type(screen.getByLabelText(/most recent company/i), "New Co")
		await user.click(screen.getByRole("button", { name: "Next" }))
		expect(await screen.findByRole("checkbox", { name: "CFA" })).toBeChecked()
		await user.click(screen.getByRole("button", { name: "Next" }))
		await user.click(await screen.findByRole("button", { name: "Save my answers" }))

		await waitFor(() => {
			expect(onFinished).toHaveBeenCalledWith("saved")
		})
		expect(org.profileSpy.hits).toBe(1)
		expect(org.profileSpy.bodies[0]).toMatchObject({
			Company__c: "New Co",
			Job_Function__c: "Trading",
			Risk_Specialty__c: null,
			Professional_Designation_CFA__c: true,
		})
		// The registration key is a guest's concern — never used for a member.
		expect(org.guestSave.spy.hits).toBe(0)
		expect(org.guestPicklists.spy.hits).toBe(0)
	})
})
