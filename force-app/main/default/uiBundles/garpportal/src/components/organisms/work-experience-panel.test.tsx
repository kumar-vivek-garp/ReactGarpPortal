import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { CvView } from "@/api/work-experience"
import { WorkExperiencePanel } from "@/components/organisms/work-experience-panel"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { cvView } from "@/testing/factories/work-experience"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const CV_PATH = "/services/apexrest/memberportal/cv"

function respondWithCv(view: CvView) {
	server.use(
		http.get(CV_PATH, () => HttpResponse.json(memberPortalEnvelope(view))),
	)
}

async function renderPanel(programType = "frm") {
	return renderWithRouterProviders(
		<WorkExperiencePanel programType={programType} />,
	)
}

const addressSection = () =>
	screen.getByRole("button", { name: /Where to post your certificate/ })
const reviewSection = () =>
	screen.getByRole("button", { name: /Review & submit/ })

describe("WorkExperiencePanel — view states", () => {
	it("shows the unavailable state for a programme with no CV, without fetching", async () => {
		// No cv handler registered: a request here would fail the strict MSW server.
		await renderPanel("scr")

		expect(
			screen.getByText("No work experience requirement"),
		).toBeInTheDocument()
	})

	it("resolves the Apex 401 refusal (no CV owed) to the unavailable state", async () => {
		server.use(
			http.get(CV_PATH, () =>
				HttpResponse.json(
					{
						status: "Error",
						statusCode: 401,
						errorMessage: "FRM CV Candidate Requirement not found",
						// Populated data marks this a business answer, not a failure.
						data: {
							statusMessage: "FRM CV Candidate Requirement not found",
							statusCode: 401,
						},
					},
					{ status: 401 },
				),
			),
		)

		await renderPanel()

		expect(
			await screen.findByText("No work experience requirement"),
		).toBeInTheDocument()
	})

	it("shows the error sentence when the load fails outright", async () => {
		server.use(
			http.get(CV_PATH, () =>
				HttpResponse.json(memberPortalError(500, "CV service down"), {
					status: 500,
				}),
			),
		)

		await renderPanel()

		expect(
			await screen.findByText(/couldn.t load your work experience/),
		).toBeInTheDocument()
	})

	it("renders the loaded page: status badge, summary, and both dialogsless sections", async () => {
		respondWithCv(cvView())

		await renderPanel()

		expect(await screen.findByText("In progress")).toBeInTheDocument()
		// Step 1 summary counts the rows and Apex's own months.
		expect(screen.getByText("1 added · 24 months")).toBeInTheDocument()
		// Requirement satisfied — the bar reports Apex's own numbers.
		const bar = screen.getByRole("progressbar", {
			name: "Work experience months logged",
		})
		expect(bar).toHaveAttribute("aria-valuenow", "24")
		expect(screen.getByText("Requirement met")).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Add experience" }),
		).toBeInTheDocument()
	})

	it("becomes a read-only receipt once the CV is with GARP", async () => {
		respondWithCv(cvView({ status: "Submitted" }))

		await renderPanel()

		expect(
			await screen.findByText("Submitted for review"),
		).toBeInTheDocument()
		// No workspace affordances on a record under review.
		expect(
			screen.queryByRole("button", { name: "Add experience" }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /^Edit / }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /^Delete / }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /address/i }),
		).not.toBeInTheDocument()
		// The review section is forced open to show the receipt.
		expect(reviewSection()).toHaveAttribute("aria-expanded", "true")
		expect(screen.getByText("Sent to GARP for review")).toBeInTheDocument()
	})
})

describe("WorkExperiencePanel — review gate", () => {
	it("keeps the review section closed while a blocker stands, and shows why once opened", async () => {
		respondWithCv(
			cvView({
				totalTimeAllotted: 12,
				isValidExperienceSubmission: false,
			}),
		)

		const user = userEvent.setup()
		await renderPanel()

		const review = await screen.findByRole("button", {
			name: /Review & submit/,
		})
		expect(review).toHaveAttribute("aria-expanded", "false")
		expect(
			screen.getByRole("progressbar", {
				name: "Work experience months logged",
			}),
		).toHaveAttribute("aria-valuenow", "12")
		expect(screen.getByText("12 to go")).toBeInTheDocument()

		await user.click(review)
		expect(review).toHaveAttribute("aria-expanded", "true")
		expect(
			screen.getByText(
				"You need 12 months more of qualifying experience.",
			),
		).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Submit for review" }),
		).toBeDisabled()
	})

	it("opens the review section by itself once nothing blocks submission", async () => {
		respondWithCv(cvView())

		await renderPanel()

		const review = await screen.findByRole("button", {
			name: /Review & submit/,
		})
		expect(review).toHaveAttribute("aria-expanded", "true")
		expect(
			screen.getByRole("button", { name: "Submit for review" }),
		).toBeEnabled()
	})
})

describe("WorkExperiencePanel — address section tri-state", () => {
	it("defaults open when no address is on file, and an explicit close wins over that", async () => {
		respondWithCv(cvView({ address: null, isValidExperienceSubmission: false }))

		const user = userEvent.setup()
		await renderPanel()

		const section = await screen.findByRole("button", {
			name: /Where to post your certificate/,
		})
		// null override + nothing on file → open by default.
		expect(section).toHaveAttribute("aria-expanded", "true")
		expect(screen.getByText("No delivery address on file yet.")).toBeVisible()

		await user.click(section)
		expect(section).toHaveAttribute("aria-expanded", "false")
	})

	it("defaults closed once the address is given, and an explicit open wins over that", async () => {
		respondWithCv(cvView())

		const user = userEvent.setup()
		await renderPanel()

		await screen.findByText("In progress")
		// null override + address on file → closed by default, summarised "Added".
		expect(addressSection()).toHaveAttribute("aria-expanded", "false")
		expect(screen.getByText("Added")).toBeInTheDocument()

		await user.click(addressSection())
		expect(addressSection()).toHaveAttribute("aria-expanded", "true")
		// Also shown in the review card's "Certificate posted to" line, so the
		// address appears twice once this section is open.
		expect(
			screen.getAllByText(
				"12 Example Road, London, EC1A 1BB, United Kingdom",
			).length,
		).toBeGreaterThan(0)
		expect(
			screen.getByRole("button", { name: "Change address" }),
		).toBeInTheDocument()
	})
})
