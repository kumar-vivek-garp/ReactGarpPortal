import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { WorkExperience } from "@/api/work-experience"
import { CvExperienceForm } from "@/components/organisms/cv-experience-form"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	cvAttachmentResult,
	experienceFormView,
	workExperience,
} from "@/testing/factories/work-experience"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const CV_EXPERIENCE_PATH = "/services/apexrest/memberportal/cvExperience"
const CV_ATTACHMENTS_PATH = "/services/apexrest/memberportal/cvAttachments"

function serveOrg(view = experienceFormView()) {
	const saves: Array<Record<string, unknown>> = []
	server.use(
		http.get(CV_EXPERIENCE_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(view)),
		),
		http.get(CV_ATTACHMENTS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope(cvAttachmentResult({ attachments: [] })),
			),
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

function renderForm(experience: WorkExperience | null = null) {
	const onSaved = vi.fn()
	const rendered = renderWithProviders(
		<CvExperienceForm
			programType="FRM"
			experience={experience}
			onSaved={onSaved}
			onCancel={vi.fn()}
		/>,
	)
	return { ...rendered, onSaved }
}

type User = ReturnType<typeof userEvent.setup>

async function selectOption(user: User, trigger: HTMLElement, option: string) {
	await user.click(trigger)
	await user.click(await screen.findByRole("option", { name: option }))
}

/** See the base suite: the month/year triggers carry ids but no accname. */
const trigger = (suffix: string) =>
	document.querySelector(`[id$="${suffix}"]`) as HTMLElement

async function fillRequired(user: User) {
	await user.type(screen.getByLabelText(/Organisation/), "Abrdn plc")
	await user.type(screen.getByLabelText(/Job title/), "Risk Analyst")
	await selectOption(user, trigger("-start-month"), "January")
	await selectOption(user, trigger("-start-year"), "2020")
	await selectOption(user, trigger("-end-month"), "February")
	await selectOption(user, trigger("-end-year"), "2022")
	await selectOption(
		user,
		screen.getByRole("combobox", { name: "Employment type" }),
		"Full Time",
	)
	await selectOption(
		user,
		screen.getByRole("combobox", { name: "Job function" }),
		"Risk Management",
	)
	await selectOption(
		user,
		screen.getByRole("combobox", { name: "Risk specialty" }),
		"Credit Risk",
	)
	const description = screen.getByLabelText(/What you did/)
	await user.click(description)
	await user.paste("r".repeat(400))
}

describe("adding a role", () => {
	it("posts the whitelisted body — month/year integers, no stray keys", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByLabelText(/Organisation/)
		await fillRequired(user)
		await user.click(screen.getByRole("button", { name: "Add experience" }))

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.saves).toHaveLength(1)
		const body = org.saves[0] as {
			programType: string
			experience: Record<string, unknown>
		}
		expect(body.programType).toBe("FRM")
		expect(body.experience).toEqual({
			startDateMonth: 1,
			startDateYear: 2020,
			endDateMonth: 2,
			endDateYear: 2022,
			isCurrentPosition: false,
			company: "Abrdn plc",
			title: "Risk Analyst",
			description: "r".repeat(400),
			manager: null,
			jobFunction: "Risk Management",
			riskSpecialty: "Credit Risk",
			jobType: "Full Time",
			educationalRole: null,
		})
	})

	it("nulls a chosen end date once the member still works there", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByLabelText(/Organisation/)
		await fillRequired(user)
		await user.click(screen.getByRole("checkbox", { name: "I still work here" }))
		await user.click(screen.getByRole("button", { name: "Add experience" }))

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.saves[0]).toMatchObject({
			experience: {
				endDateMonth: null,
				endDateYear: null,
				isCurrentPosition: true,
			},
		})
	})
})

describe("the teaching cascade", () => {
	it("asks for an academic role only for Education/Training, and requires it", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm()

		await screen.findByLabelText(/Organisation/)
		expect(
			screen.queryByRole("combobox", { name: "Academic role" }),
		).not.toBeInTheDocument()

		await selectOption(
			user,
			screen.getByRole("combobox", { name: "Job function" }),
			"Education/Training",
		)
		expect(
			screen.getByRole("combobox", { name: "Academic role" }),
		).toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "Add experience" }))
		expect(
			await screen.findByText("Academic role is required."),
		).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})

	it("clears a stale academic role after switching to a non-teaching function", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByLabelText(/Organisation/)
		await selectOption(
			user,
			screen.getByRole("combobox", { name: "Job function" }),
			"Education/Training",
		)
		await selectOption(
			user,
			screen.getByRole("combobox", { name: "Academic role" }),
			"Professor",
		)
		await fillRequired(user)
		await user.click(screen.getByRole("button", { name: "Add experience" }))

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		// fillRequired re-picked Risk Management, so the role must not travel.
		expect(org.saves[0]).toMatchObject({
			experience: { jobFunction: "Risk Management", educationalRole: null },
		})
	})
})

describe("editing a role", () => {
	it("seeds from the freshly fetched row, not the list's stale copy", async () => {
		serveOrg(
			experienceFormView({
				workExperience: workExperience({ company: "Fresh Co" }),
			}),
		)
		renderForm(workExperience({ company: "Stale Co" }))

		expect(await screen.findByLabelText(/Organisation/)).toHaveValue("Fresh Co")
		expect(
			screen.getByRole("button", { name: "Save changes" }),
		).toBeInTheDocument()
	})

	it("carries the row's id on the wire", async () => {
		// The factory row alone would fail validation (no specialty, short
		// description) — a saved row that passes is what Edit re-submits.
		const saved = workExperience({
			riskSpecialty: "Credit Risk",
			description: "r".repeat(400),
		})
		const org = serveOrg(experienceFormView({ workExperience: saved }))
		const user = userEvent.setup()
		const { onSaved } = renderForm(saved)

		await screen.findByLabelText(/Organisation/)
		await user.click(screen.getByRole("button", { name: "Save changes" }))

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.saves[0]).toMatchObject({
			experience: {
				id: "a1Q-exp-1",
				startDateMonth: 1,
				startDateYear: 2020,
				endDateMonth: 1,
				endDateYear: 2022,
				company: "Abrdn plc",
			},
		})
	})
})
