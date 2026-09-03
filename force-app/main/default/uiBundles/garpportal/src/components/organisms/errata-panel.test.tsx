import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { ErrataPanel } from "@/components/organisms/errata-panel"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const FORM_PATH = "/services/apexrest/memberportal/errataForm"
const SUBMIT_PATH = "/services/apexrest/memberportal/submitErrata"
const ATTACH_PATH = "/services/apexrest/memberportal/attachErrataFile"

function serveForm() {
	server.use(
		http.get(FORM_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					errataPicklistOption: {
						"FRM Part I Books": ["Foundations of Risk"],
					},
				}),
			),
		),
	)
}

function serveSubmit(attachFails = false) {
	server.use(
		http.post(SUBMIT_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					errataId: "err-1",
				}),
			),
		),
		http.post(ATTACH_PATH, () =>
			attachFails
				? HttpResponse.json(memberPortalError(500, "Upload rejected."), {
						status: 500,
					})
				: HttpResponse.json(
						memberPortalEnvelope({
							statusMessage: null,
							statusCode: 200,
							fileId: "file-1",
						}),
					),
		),
	)
}

const renderPanel = () =>
	renderWithRouterProviders(<ErrataPanel programType="frm" />)

/**
 * The real input is `sr-only`, receiving the visible "Add a file" button's
 * click — `userEvent.upload` needs the input itself, the one sanctioned
 * traversal (same as errata-form.file.test.tsx).
 */
const fileInput = () =>
	document.querySelector('input[type="file"]') as HTMLInputElement

async function fillAndSubmit(user: ReturnType<typeof userEvent.setup>) {
	await user.click(
		await screen.findByRole("combobox", { name: /What study material/ }),
	)
	await user.click(
		await screen.findByRole("option", { name: "FRM Part I Books" }),
	)
	await user.click(screen.getByRole("combobox", { name: /What book/ }))
	await user.click(
		await screen.findByRole("option", { name: "Foundations of Risk" }),
	)
	await user.type(screen.getByRole("textbox", { name: /What page/ }), "12")
	await user.type(
		screen.getByRole("textbox", { name: /Describe the problem/ }),
		"Formula 3.1 is inverted.",
	)
	await user.click(screen.getByRole("button", { name: "Submit report" }))
}

describe("ErrataPanel — after a successful report", () => {
	it("replaces the form with the receipt, and Reset brings a blank form back", async () => {
		const user = userEvent.setup()
		serveForm()
		serveSubmit()
		await renderPanel()

		await fillAndSubmit(user)

		expect(
			await screen.findByText("Thanks — your report has been sent"),
		).toBeInTheDocument()
		// The form is gone; the way back out is offered.
		expect(
			screen.queryByRole("button", { name: "Submit report" }),
		).not.toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Back to FRM" })).toHaveAttribute(
			"href",
			"/programs/frm",
		)
		// No file was attached, so no attachment warning either.
		expect(screen.queryByText(/didn't upload/)).not.toBeInTheDocument()

		await user.click(
			screen.getByRole("button", { name: "Report another error" }),
		)

		expect(
			await screen.findByRole("button", { name: "Submit report" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("textbox", { name: /Describe the problem/ }),
		).toHaveValue("")
	})

	it("reports a failed attachment as a warning on the receipt, never an error", async () => {
		const user = userEvent.setup()
		serveForm()
		serveSubmit(true)
		await renderPanel()

		await screen.findByRole("combobox", { name: /What study material/ })
		await user.upload(
			fileInput(),
			new File(["hello"], "page.png", { type: "image/png" }),
		)
		await fillAndSubmit(user)

		expect(
			await screen.findByText("Thanks — your report has been sent"),
		).toBeInTheDocument()
		expect(
			screen.getByText(/Your report was filed, but the file didn't upload/),
		).toBeInTheDocument()
	})
})

describe("ErrataPanel — the published sheet card", () => {
	it("links the FRM sheet next to the form", async () => {
		serveForm()
		serveSubmit()
		await renderPanel()

		const sheet = await screen.findByRole("link", {
			name: /Download FRM errata/,
		})
		expect(sheet).toHaveAttribute("target", "_blank")
		expect(
			screen.getByText(/Most known issues are already listed/),
		).toBeInTheDocument()
	})

	it("says plainly when GARP publishes no sheet for the programme", async () => {
		serveForm()
		await renderWithRouterProviders(<ErrataPanel programType="raij" />)

		expect(
			await screen.findByText(/GARP does not publish a RAIJ errata sheet/),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: /errata$/ }),
		).not.toBeInTheDocument()
	})
})
