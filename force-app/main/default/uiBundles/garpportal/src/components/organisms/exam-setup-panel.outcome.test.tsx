import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { ExamSetupIdSaveResult } from "@/api/exam-setup"
import { ExamSetupPanel } from "@/components/organisms/exam-setup-panel"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	examSetupSaveResult,
	examSetupView,
} from "@/testing/factories/exam-setup"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const FORM_PATH = "/services/apexrest/memberportal/examSetup"
const SAVE_PATH = "/services/apexrest/memberportal/examSetupId"

/** Render, then save straight away — the stored ID keeps the button enabled. */
async function renderAndSave(result: ExamSetupIdSaveResult) {
	server.use(
		http.get(FORM_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(examSetupView())),
		),
		http.post(SAVE_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(result)),
		),
	)
	const user = userEvent.setup()
	await renderWithRouterProviders(<ExamSetupPanel programType="scr" />)
	await screen.findByText("Choose your sitting")
	await user.click(screen.getByRole("button", { name: "Save and continue" }))
	return user
}

describe("ExamSetupPanel — save outcomes", () => {
	it("lands on the completion screen, and Start over returns to the form", async () => {
		const user = await renderAndSave(examSetupSaveResult())

		expect(
			await screen.findByText("Your exam setup is complete"),
		).toBeInTheDocument()
		expect(screen.queryByText("Choose your sitting")).not.toBeInTheDocument()

		await user.click(
			screen.getByRole("button", { name: "Make another change" }),
		)
		expect(
			await screen.findByText("Choose your sitting"),
		).toBeInTheDocument()
	})

	it("hands scheduling to MyGarp while the provider push is disabled", async () => {
		await renderAndSave(
			examSetupSaveResult({
				nextScreen: "Check Authorization",
				schedulingRequired: true,
			}),
		)

		// EXAM_SETUP_AUTHORIZE_ENABLED is off in config — the outcome must not
		// offer a provider call it cannot make.
		expect(
			await screen.findByText("One more step, in MyGarp"),
		).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Continue in MyGarp" }),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Check again" }),
		).not.toBeInTheDocument()
	})

	it("shows the pending fee gate when Apex answers Pay Fees despite the forecast", async () => {
		await renderAndSave(
			examSetupSaveResult({
				nextScreen: "Pay Fees",
				paymentRequired: true,
				examModificationId: "a1M-mod-1",
			}),
		)

		// By now a modification exists — the copy must say the change is
		// recorded and pending, and must NOT offer a costless way back.
		expect(
			await screen.findByText(/This change has a fee/),
		).toBeInTheDocument()
		expect(
			screen.getByText(/We've recorded your change/),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Keep my current date" }),
		).not.toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Continue in MyGarp" }),
		).toBeInTheDocument()
	})

	it("treats an unrecognised nextScreen as completion, not an error", async () => {
		await renderAndSave(
			examSetupSaveResult({ nextScreen: "Some Future Screen" }),
		)

		expect(
			await screen.findByText("Your exam setup is complete"),
		).toBeInTheDocument()
	})
})
