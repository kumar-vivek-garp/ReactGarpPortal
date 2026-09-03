import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import { CvExperienceForm } from "@/components/organisms/cv-experience-form"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { experienceFormView } from "@/testing/factories/work-experience"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const CV_EXPERIENCE_PATH = "/services/apexrest/memberportal/cvExperience"

function serveOrg(view = experienceFormView()) {
	const saves: Array<Record<string, unknown>> = []
	server.use(
		http.get(CV_EXPERIENCE_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(view)),
		),
		http.post(CV_EXPERIENCE_PATH, async ({ request }) => {
			saves.push((await request.json()) as Record<string, unknown>)
			return HttpResponse.json(
				memberPortalEnvelope({ statusMessage: null, statusCode: 200 }),
			)
		}),
	)
	return { saves }
}

function renderForm() {
	const onSaved = vi.fn()
	const onCancel = vi.fn()
	const rendered = renderWithProviders(
		<CvExperienceForm
			programType="FRM"
			experience={null}
			onSaved={onSaved}
			onCancel={vi.fn()}
		/>,
	)
	return { ...rendered, onSaved, onCancel }
}

const submitButton = () => screen.getByRole("button", { name: "Add experience" })

/**
 * The month/year triggers have NO accessible name — `MonthYearField`'s label
 * is not associated with either select (a real a11y gap, noted, not fixed
 * here) — so role+name queries cannot reach them. Their DOM ids can.
 */
const monthYearTrigger = (suffix: string) =>
	document.querySelector(`[id$="${suffix}"]`) as HTMLElement

describe("hydration", () => {
	it("shows a form-shaped skeleton, then binds the fetched picklists", async () => {
		serveOrg()
		const user = userEvent.setup()
		renderForm()

		// Form-shaped placeholder while the options load.
		expect(document.querySelector("[aria-busy]")).toBeInTheDocument()

		await user.click(
			await screen.findByRole("combobox", { name: "Employment type" }),
		)
		expect(
			await screen.findByRole("option", { name: "Full Time" }),
		).toBeInTheDocument()
		expect(screen.getByRole("option", { name: "Part Time" })).toBeInTheDocument()
	})
})

describe("validation", () => {
	it("names every missing answer and posts nothing", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByLabelText(/Organisation/)
		await user.click(submitButton())

		expect(
			await screen.findByText("An organisation name is required."),
		).toBeInTheDocument()
		expect(screen.getByText("A job title is required.")).toBeInTheDocument()
		expect(screen.getByText("Start date month is required.")).toBeInTheDocument()
		expect(screen.getByText("End date month is required.")).toBeInTheDocument()
		expect(screen.getByText("Employment type is required.")).toBeInTheDocument()
		expect(screen.getByText("Job function is required.")).toBeInTheDocument()
		expect(screen.getByText("Risk specialty is required.")).toBeInTheDocument()
		expect(screen.getByText("A description is required.")).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
		expect(onSaved).not.toHaveBeenCalled()
	})

	it("holds the description to GARP's 400-character floor", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm()

		await user.type(await screen.findByLabelText(/What you did/), "Too short.")
		await user.click(submitButton())

		expect(
			await screen.findByText(/Please write at least 400 characters/),
		).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})

	it("counts the description live and says when it is enough", async () => {
		serveOrg()
		const user = userEvent.setup()
		renderForm()

		const description = await screen.findByLabelText(/What you did/)
		await user.type(description, "Risk work.")
		expect(screen.getByText("10 / 400 characters")).toBeInTheDocument()

		await user.clear(description)
		await user.click(description)
		await user.paste("r".repeat(400))
		expect(
			screen.getByText("400 / 400 characters — that's enough"),
		).toBeInTheDocument()
	})

	it("stops demanding an end date once the member still works there", async () => {
		serveOrg()
		const user = userEvent.setup()
		renderForm()

		await screen.findByLabelText(/Organisation/)
		await user.click(submitButton())
		expect(
			await screen.findByText("End date month is required."),
		).toBeInTheDocument()

		await user.click(screen.getByRole("checkbox", { name: "I still work here" }))

		// The demand disappears with the field, not on the next submit.
		expect(
			screen.queryByText("End date month is required."),
		).not.toBeInTheDocument()
		// Both end-date selects are out of reach.
		expect(monthYearTrigger("-end-month")).toBeDisabled()
		expect(monthYearTrigger("-end-year")).toBeDisabled()
	})
})
