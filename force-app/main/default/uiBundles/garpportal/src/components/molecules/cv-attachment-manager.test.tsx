import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { CvAttachmentManager } from "@/components/molecules/cv-attachment-manager"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	cvAttachment,
	cvAttachmentResult,
} from "@/testing/factories/work-experience"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const LIST_PATH = "/services/apexrest/memberportal/cvAttachments"
const UPLOAD_PATH = "/services/apexrest/memberportal/cvAttachment"
const DELETE_PATH = "/services/apexrest/memberportal/cvAttachmentDelete"

const EXPERIENCE_ID = "a1Q-exp-1"

function listHandler() {
	return http.get(LIST_PATH, () =>
		HttpResponse.json(memberPortalEnvelope(cvAttachmentResult())),
	)
}

function pdfFile(name = "cv.pdf", content = "hello") {
	return new File([content], name, { type: "application/pdf" })
}

/** The picker input is visually hidden and label-less — no role to query by. */
function fileInput(container: HTMLElement): HTMLInputElement {
	const input = container.querySelector<HTMLInputElement>('input[type="file"]')
	if (!input) throw new Error("file input not rendered")
	return input
}

async function renderManager(props: Partial<Parameters<typeof CvAttachmentManager>[0]> = {}) {
	const view = renderWithProviders(
		<CvAttachmentManager experienceId={EXPERIENCE_ID} {...props} />,
	)
	if ((props.experienceId ?? EXPERIENCE_ID) !== null) {
		await screen.findByText("employment-letter.pdf")
	}
	return view
}

describe("CvAttachmentManager — unsaved experience", () => {
	it("offers no picker before the experience is saved, and fetches nothing", async () => {
		// No handlers registered: any request would fail the strict MSW server.
		renderWithProviders(
			<CvAttachmentManager
				experienceId={null}
				required
				documentMessage="Attach an employment letter."
				requiredDocuments={["Employment letter", "Payslip"]}
			/>,
		)

		expect(
			screen.getByText(
				"Save this experience first, then add any documents it needs.",
			),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Add a file" }),
		).not.toBeInTheDocument()
		// Apex's own asks still show so the member knows what is coming.
		expect(
			screen.getByText("Attach an employment letter."),
		).toBeInTheDocument()
		expect(screen.getByText("Employment letter")).toBeInTheDocument()
		expect(screen.getByText("Payslip")).toBeInTheDocument()
	})
})

describe("CvAttachmentManager — validation wiring", () => {
	it("shows the rejection inline for a disallowed type and never uploads", async () => {
		server.use(listHandler())
		const user = userEvent.setup({ applyAccept: false })
		const { container } = await renderManager()

		const rogue = new File(["MZ"], "virus.exe", {
			type: "application/octet-stream",
		})
		await user.upload(fileInput(container), rogue)

		// `validateCvUpload`'s own sentence, verbatim — the wiring under test.
		expect(await screen.findByRole("alert")).toHaveTextContent(
			".pdf, .doc, .docx, .txt, .jpg, .jpeg, .png files only.",
		)
		// No POST handler is registered — reaching the network would error.
	})

	it("shows the size rejection for an oversized file", async () => {
		server.use(listHandler())
		const user = userEvent.setup({ applyAccept: false })
		const { container } = await renderManager()

		const huge = pdfFile("thesis.pdf")
		Object.defineProperty(huge, "size", { value: 5 * 1024 * 1024 })
		await user.upload(fileInput(container), huge)

		expect(await screen.findByRole("alert")).toHaveTextContent(
			"This file is larger than 4 MB. Please upload a smaller one.",
		)
	})

	it("clears the previous error on the next pick", async () => {
		const bodies: unknown[] = []
		server.use(
			listHandler(),
			http.post(UPLOAD_PATH, async ({ request }) => {
				bodies.push(await request.json())
				return HttpResponse.json(memberPortalEnvelope(cvAttachmentResult()))
			}),
		)
		const user = userEvent.setup({ applyAccept: false })
		const { container } = await renderManager()

		await user.upload(
			fileInput(container),
			new File(["x"], "notes.xyz", { type: "text/xyz" }),
		)
		expect(await screen.findByRole("alert")).toBeInTheDocument()

		await user.upload(fileInput(container), pdfFile())
		await waitFor(() => {
			expect(bodies).toHaveLength(1)
		})
		expect(screen.queryByRole("alert")).not.toBeInTheDocument()
	})
})

describe("CvAttachmentManager — upload and delete", () => {
	it("shows the optimistic row while uploading, posts raw base64, then clears it", async () => {
		let release!: () => void
		const gate = new Promise<void>((resolve) => {
			release = resolve
		})
		const bodies: unknown[] = []
		server.use(
			listHandler(),
			http.post(UPLOAD_PATH, async ({ request }) => {
				bodies.push(await request.json())
				await gate
				return HttpResponse.json(memberPortalEnvelope(cvAttachmentResult()))
			}),
		)
		const user = userEvent.setup({ applyAccept: false })
		const { container } = await renderManager()

		await user.upload(fileInput(container), pdfFile())

		// In-flight: the pending row is up and the picker is busy.
		expect(await screen.findByText("Uploading cv.pdf…")).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Uploading…" })).toBeDisabled()

		release()
		await waitFor(() => {
			expect(screen.queryByText("Uploading cv.pdf…")).not.toBeInTheDocument()
		})
		// Raw base64 of "hello", no data: prefix — Apex decodes it directly.
		expect(bodies[0]).toEqual({
			experienceId: EXPERIENCE_ID,
			fileName: "cv.pdf",
			fileText: "aGVsbG8=",
		})
		// The same file can be re-picked after a fix.
		expect(fileInput(container).value).toBe("")
	})

	it("lists what the server holds, with sizes, and deletes by attachment id", async () => {
		const bodies: unknown[] = []
		server.use(
			listHandler(),
			http.post(DELETE_PATH, async ({ request }) => {
				bodies.push(await request.json())
				return HttpResponse.json(
					memberPortalEnvelope(cvAttachmentResult({ attachments: [] })),
				)
			}),
		)
		const user = userEvent.setup({ applyAccept: false })
		await renderManager()

		expect(screen.getByText("2 KB")).toBeInTheDocument()

		await user.click(
			screen.getByRole("button", { name: "Remove employment-letter.pdf" }),
		)
		await waitFor(() => {
			expect(bodies).toEqual([{ attachmentId: "00P-att-1" }])
		})
	})

	it("keeps a size-less row without inventing a size", async () => {
		server.use(
			http.get(LIST_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						cvAttachmentResult({
							attachments: [cvAttachment({ size: null })],
						}),
					),
				),
			),
		)
		await renderManager()

		// The row renders, but with no size column ("Up to 4 MB" is the picker
		// hint, not a row size — hence the anchored pattern).
		expect(screen.queryByText(/^\d+(\.\d+)? (KB|MB|bytes?)$/)).not.toBeInTheDocument()
	})
})
