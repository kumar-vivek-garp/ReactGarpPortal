import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { cvView } from "@/testing/factories/work-experience"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

import { CvSubmitPanel } from "./cv-submit-panel"

const CV_SUBMIT_PATH = "/services/apexrest/memberportal/cvSubmit"

describe("CvSubmitPanel", () => {
	it("submits the CV for review when nothing blocks it", async () => {
		const hits: number[] = []
		server.use(
			http.post(CV_SUBMIT_PATH, () => {
				hits.push(1)
				return HttpResponse.json(
					memberPortalEnvelope({ statusMessage: null, statusCode: 200 }),
				)
			}),
		)
		const user = userEvent.setup()
		renderWithProviders(<CvSubmitPanel view={cvView()} programType="FRM" />)

		const submit = screen.getByRole("button", { name: "Submit for review" })
		expect(submit).toBeEnabled()
		await user.click(submit)

		await waitFor(() => expect(hits).toHaveLength(1))
	})

	it("names the blocker and disables submit instead of a dead button", () => {
		renderWithProviders(
			<CvSubmitPanel
				view={cvView({
					address: {
						street: null,
						city: null,
						state: null,
						postalCode: null,
						country: null,
						isEmpty: true,
					},
				})}
				programType="FRM"
			/>,
		)

		expect(
			screen.getByText("Add the address your certificate should be posted to."),
		).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Submit for review" }),
		).toBeDisabled()
	})

	it("shows the submitted receipt once the CV is under review", () => {
		renderWithProviders(
			<CvSubmitPanel
				view={cvView({ status: "Submitted" })}
				programType="FRM"
			/>,
		)

		expect(screen.getByText("Sent to GARP for review")).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Submit for review" }),
		).not.toBeInTheDocument()
	})
})
