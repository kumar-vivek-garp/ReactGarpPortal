import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	cvAttachmentResult,
	experienceFormView,
	workExperience,
} from "@/testing/factories/work-experience"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

import { CvExperienceDialog } from "./cv-experience-dialog"

const CV_EXPERIENCE_PATH = "/services/apexrest/memberportal/cvExperience"
const CV_ATTACHMENTS_PATH = "/services/apexrest/memberportal/cvAttachments"

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003-member",
	photoUrl: null,
}

function serveOrg(view = experienceFormView()) {
	server.use(
		http.get(CV_EXPERIENCE_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(view)),
		),
		http.post(CV_EXPERIENCE_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({ statusMessage: null, statusCode: 200 }),
			),
		),
		http.get(CV_ATTACHMENTS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope(cvAttachmentResult({ attachments: [] })),
			),
		),
	)
}

describe("CvExperienceDialog", () => {
	it("titles itself Add for a new role and Edit for a saved one", () => {
		serveOrg()
		const { unmount } = renderWithProviders(
			<CvExperienceDialog
				open
				onOpenChange={vi.fn()}
				programType="FRM"
				experience={null}
			/>,
		)
		expect(
			screen.getByRole("heading", { name: "Add experience" }),
		).toBeInTheDocument()
		unmount()

		serveOrg()
		renderWithProviders(
			<CvExperienceDialog
				open
				onOpenChange={vi.fn()}
				programType="FRM"
				experience={workExperience()}
			/>,
		)
		expect(
			screen.getByRole("heading", { name: "Edit experience" }),
		).toBeInTheDocument()
	})

	it("closes when the wrapped form cancels", async () => {
		serveOrg()
		const user = userEvent.setup()
		const onOpenChange = vi.fn()
		renderWithProviders(
			<CvExperienceDialog
				open
				onOpenChange={onOpenChange}
				programType="FRM"
				experience={null}
			/>,
		)

		await user.click(await screen.findByRole("button", { name: "Cancel" }))

		expect(onOpenChange).toHaveBeenCalledWith(false)
	})

	it("closes once the wrapped form saves", async () => {
		// Edit mode: the saved row seeds every field, so it saves as-is. The
		// overrides keep the seeded row valid against the form's own rules.
		const saved = workExperience({
			riskSpecialty: "Credit Risk",
			description: "r".repeat(400),
		})
		serveOrg(experienceFormView({ workExperience: saved }))
		const user = userEvent.setup()
		const onOpenChange = vi.fn()
		renderWithProviders(
			<CvExperienceDialog
				open
				onOpenChange={onOpenChange}
				programType="FRM"
				experience={saved}
			/>,
			{ user: MEMBER },
		)

		await screen.findByLabelText(/Organisation/)
		await user.click(screen.getByRole("button", { name: "Save changes" }))

		await vi.waitFor(() => {
			expect(onOpenChange).toHaveBeenCalledWith(false)
		})
	})
})
