import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { toast } from "sonner"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

// The app's real QueryClient: its MutationCache owns the toast policy.
import { queryClient as appQueryClient } from "@/api/client"
import type { ErrataFormView, ErrataSubmission } from "@/api/errata"
import { ErrataForm } from "@/components/organisms/errata-form"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const SUBMIT_PATH = "/services/apexrest/memberportal/submitErrata"
const ATTACH_PATH = "/services/apexrest/memberportal/attachErrataFile"

const VIEW: ErrataFormView = {
	statusMessage: null,
	statusCode: 200,
	errataPicklistOption: {
		"FRM Practice Exam": ["2026 Practice Exam"],
		"FRM Part I Books": ["Foundations of Risk", "Quantitative Analysis"],
	},
}

/** POST spies for the submit/attach pair; both count hits and record bodies. */
function errataWire(respondSubmit?: (hits: number) => Response) {
	const submit = { hits: 0, bodies: [] as ErrataSubmission[] }
	const attach = { hits: 0, bodies: [] as unknown[] }
	server.use(
		http.post(SUBMIT_PATH, async ({ request }) => {
			submit.hits += 1
			submit.bodies.push((await request.json()) as ErrataSubmission)
			return (
				respondSubmit?.(submit.hits) ??
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						errataId: "err-1",
					}),
				)
			)
		}),
		http.post(ATTACH_PATH, async ({ request }) => {
			attach.hits += 1
			attach.bodies.push(await request.json())
			return HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					fileId: "file-1",
				}),
			)
		}),
	)
	return { submit, attach }
}

function renderForm(programType = "frm") {
	const onSubmitted = vi.fn()
	renderWithProviders(
		<ErrataForm programType={programType} view={VIEW} onSubmitted={onSubmitted} />,
		{ queryClient: appQueryClient },
	)
	return { onSubmitted }
}

beforeEach(() => {
	vi.clearAllMocks()
})
afterEach(() => {
	appQueryClient.clear()
})

const materialSelect = () =>
	screen.getByRole("combobox", { name: /What study material/ })
const bookSelect = () => screen.getByRole("combobox", { name: /What book/ })
const submitButton = () => screen.getByRole("button", { name: "Submit report" })

async function choose(
	user: ReturnType<typeof userEvent.setup>,
	trigger: HTMLElement,
	option: string,
) {
	await user.click(trigger)
	await user.click(await screen.findByRole("option", { name: option }))
}

describe("the material → book cascade", () => {
	it("keeps the book locked, with a hint, until a material is chosen", async () => {
		const user = userEvent.setup()
		renderForm()

		expect(bookSelect()).toBeDisabled()
		expect(screen.getByText("Choose a study material first.")).toBeInTheDocument()

		await choose(user, materialSelect(), "FRM Part I Books")
		expect(bookSelect()).toBeEnabled()
		expect(
			screen.queryByText("Choose a study material first."),
		).not.toBeInTheDocument()

		// Only that material's books are offered.
		await user.click(bookSelect())
		expect(
			await screen.findByRole("option", { name: "Foundations of Risk" }),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("option", { name: "2026 Practice Exam" }),
		).not.toBeInTheDocument()
	})

	it("clears the chosen book when the material changes", async () => {
		const user = userEvent.setup()
		renderForm()

		await choose(user, materialSelect(), "FRM Part I Books")
		await choose(user, bookSelect(), "Foundations of Risk")
		expect(bookSelect()).toHaveTextContent("Foundations of Risk")

		await choose(user, materialSelect(), "FRM Practice Exam")
		expect(bookSelect()).toHaveTextContent("Select…")
		await user.click(bookSelect())
		expect(
			await screen.findByRole("option", { name: "2026 Practice Exam" }),
		).toBeInTheDocument()
	})

	it("asks for a question number on a practice exam, a page number otherwise", async () => {
		const user = userEvent.setup()
		renderForm()

		expect(
			screen.getByRole("textbox", { name: /What page was the error on/ }),
		).toBeInTheDocument()

		await choose(user, materialSelect(), "FRM Practice Exam")
		expect(
			screen.getByRole("textbox", { name: /What question number was the error on/ }),
		).toBeInTheDocument()
	})
})

describe("validation", () => {
	it("names every missing required field and sends nothing", async () => {
		const wire = errataWire()
		const user = userEvent.setup()
		const { onSubmitted } = renderForm()

		await user.click(submitButton())

		expect(
			await screen.findByText("Please select a study material."),
		).toBeInTheDocument()
		expect(screen.getByText("Please select a book.")).toBeInTheDocument()
		expect(
			screen.getByText("Please say where the error appears."),
		).toBeInTheDocument()
		expect(screen.getByText("Please describe the problem.")).toBeInTheDocument()
		expect(screen.getAllByRole("alert")).toHaveLength(4)
		expect(wire.submit.hits).toBe(0)
		expect(onSubmitted).not.toHaveBeenCalled()
	})
})

describe("submitting", () => {
	it("posts the pinned inversion — map key as studyMaterial, dependent as book", async () => {
		const wire = errataWire()
		const user = userEvent.setup()
		const { onSubmitted } = renderForm("frm")

		await choose(user, materialSelect(), "FRM Part I Books")
		await choose(user, bookSelect(), "Quantitative Analysis")
		await user.type(
			screen.getByRole("textbox", { name: /What page/ }),
			"  12  ",
		)
		await user.type(
			screen.getByRole("textbox", { name: /Describe the problem/ }),
			"Formula 3.1 is inverted.",
		)
		await user.click(submitButton())

		await waitFor(() => expect(onSubmitted).toHaveBeenCalledTimes(1))
		expect(wire.submit.bodies[0]).toEqual({
			programType: "FRM",
			studyMaterial: "FRM Part I Books",
			book: "Quantitative Analysis",
			pageNumber: "12",
			errorDescription: "Formula 3.1 is inverted.",
			correction: null,
		})
		expect(onSubmitted).toHaveBeenCalledWith({
			errataId: "err-1",
			attachmentError: null,
		})
		// Nothing to attach without a file.
		expect(wire.attach.hits).toBe(0)
	})

	it("sends a trimmed correction when one is offered", async () => {
		const wire = errataWire()
		const user = userEvent.setup()
		const { onSubmitted } = renderForm()

		await choose(user, materialSelect(), "FRM Part I Books")
		await choose(user, bookSelect(), "Foundations of Risk")
		await user.type(screen.getByRole("textbox", { name: /What page/ }), "9")
		await user.type(
			screen.getByRole("textbox", { name: /Describe the problem/ }),
			"Wrong date.",
		)
		await user.type(
			screen.getByRole("textbox", { name: /What do you think the correction/ }),
			"  2025, not 2024. ",
		)
		await user.click(submitButton())

		await waitFor(() => expect(onSubmitted).toHaveBeenCalledTimes(1))
		expect(wire.submit.bodies[0].correction).toBe("2025, not 2024.")
	})

	it("toasts the refusal, keeps the draft, and unlocks Submit again", async () => {
		const wire = errataWire(() =>
			HttpResponse.json(memberPortalError(501, "Required information missing"), {
				status: 501,
			}),
		)
		const user = userEvent.setup()
		const { onSubmitted } = renderForm()

		await choose(user, materialSelect(), "FRM Part I Books")
		await choose(user, bookSelect(), "Foundations of Risk")
		await user.type(screen.getByRole("textbox", { name: /What page/ }), "9")
		await user.type(
			screen.getByRole("textbox", { name: /Describe the problem/ }),
			"Wrong date.",
		)
		await user.click(submitButton())

		await waitFor(() => {
			expect(vi.mocked(toast.error)).toHaveBeenCalledWith(
				"Unable to submit your report",
				{ description: "Required information missing" },
			)
		})
		expect(onSubmitted).not.toHaveBeenCalled()
		expect(wire.submit.hits).toBe(1)
		expect(submitButton()).toBeEnabled()
		expect(screen.getByRole("textbox", { name: /What page/ })).toHaveValue("9")
	})
})
