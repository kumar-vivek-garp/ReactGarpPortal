import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { toast } from "sonner"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

// The app's real QueryClient, not the bare test one: its MutationCache is
// where the toast policy lives, and these tests assert the toasts.
import { queryClient as appQueryClient } from "@/api/client"
import type { CaseSummary } from "@/api/help-center"
import { SupportCaseForm } from "@/components/forms/support-case/support-case-form"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const SUBMIT_CASE_PATH = "/services/apexrest/memberportal/submitCase"

const SUCCESS_TOAST =
	"Thank you for your submission. A representative from Member Services will be in touch with you shortly."

function caseSummary(): CaseSummary {
	return {
		id: "500-case",
		caseNumber: "00001234",
		subject: "Billing question",
		status: "New",
		createdDate: "2026-09-01T00:00:00.000Z",
	}
}

/** POST spy answering the memberportal envelope; `respond` per hit. */
function submitCaseHandler(respond: (hits: number) => Response) {
	const spy = { hits: 0, bodies: [] as unknown[] }
	const handler = http.post(SUBMIT_CASE_PATH, async ({ request }) => {
		spy.hits += 1
		spy.bodies.push(await request.json())
		return respond(spy.hits)
	})
	return { spy, handler }
}

function renderForm() {
	const onSubmitted = vi.fn()
	const rendered = renderWithProviders(
		<SupportCaseForm onSubmitted={onSubmitted} />,
		{ queryClient: appQueryClient },
	)
	return { ...rendered, onSubmitted }
}

function subjectBox() {
	return screen.getByRole("textbox", { name: "Subject" })
}
function descriptionBox() {
	return screen.getByRole("textbox", { name: "Description" })
}
function submitButton() {
	return screen.getByRole("button", { name: "Submit" })
}

beforeEach(() => {
	vi.clearAllMocks()
})
afterEach(() => {
	appQueryClient.clear()
})

describe("validation", () => {
	it("requires both fields and sends nothing while they are missing", async () => {
		const wire = submitCaseHandler(() =>
			HttpResponse.json(memberPortalEnvelope(caseSummary())),
		)
		server.use(wire.handler)
		const user = userEvent.setup()
		const { onSubmitted } = renderForm()

		await user.click(submitButton())

		expect(await screen.findByText("Subject is required")).toBeInTheDocument()
		expect(screen.getByText("Description is required")).toBeInTheDocument()
		expect(wire.spy.hits).toBe(0)
		expect(onSubmitted).not.toHaveBeenCalled()
	})

	it("refuses whitespace-only input before the wire, as an error toast", async () => {
		const wire = submitCaseHandler(() =>
			HttpResponse.json(memberPortalEnvelope(caseSummary())),
		)
		server.use(wire.handler)
		const user = userEvent.setup()
		const { onSubmitted } = renderForm()

		// react-hook-form's `required` passes "   ", so the api guard catches it.
		await user.type(subjectBox(), "   ")
		await user.type(descriptionBox(), "   ")
		await user.click(submitButton())

		await vi.waitFor(() => {
			expect(vi.mocked(toast.error)).toHaveBeenCalledWith(
				"Unable to submit support case",
				{ description: "A subject is required." },
			)
		})
		expect(wire.spy.hits).toBe(0)
		expect(onSubmitted).not.toHaveBeenCalled()
	})
})

describe("submitting", () => {
	it("posts trimmed fields, toasts success, resets, and reports back", async () => {
		const wire = submitCaseHandler(() =>
			HttpResponse.json(memberPortalEnvelope(caseSummary())),
		)
		server.use(wire.handler)
		const user = userEvent.setup()
		const { onSubmitted } = renderForm()

		await user.type(subjectBox(), "  Billing question ")
		await user.type(descriptionBox(), " My invoice is wrong. ")
		await user.click(submitButton())

		await vi.waitFor(() => {
			expect(onSubmitted).toHaveBeenCalledTimes(1)
		})
		expect(wire.spy.hits).toBe(1)
		expect(wire.spy.bodies[0]).toEqual({
			subject: "Billing question",
			description: "My invoice is wrong.",
		})
		expect(vi.mocked(toast.success)).toHaveBeenCalledWith(
			SUCCESS_TOAST,
			undefined,
		)
		// Reset for the next case.
		expect(subjectBox()).toHaveValue("")
		expect(descriptionBox()).toHaveValue("")
	})

	it("disables the controls and relabels the button while pending", async () => {
		let release!: () => void
		const gate = new Promise<void>((resolve) => {
			release = resolve
		})
		server.use(
			http.post(SUBMIT_CASE_PATH, async () => {
				await gate
				return HttpResponse.json(memberPortalEnvelope(caseSummary()))
			}),
		)
		const user = userEvent.setup()
		const { onSubmitted } = renderForm()

		await user.type(subjectBox(), "Hello")
		await user.type(descriptionBox(), "World")
		await user.click(submitButton())

		const busy = await screen.findByRole("button", { name: "Submitting…" })
		expect(busy).toBeDisabled()
		expect(subjectBox()).toBeDisabled()
		expect(descriptionBox()).toBeDisabled()

		release()
		await vi.waitFor(() => {
			expect(onSubmitted).toHaveBeenCalledTimes(1)
		})
		expect(submitButton()).toBeEnabled()
	})

	it("toasts the server failure under the mutation's title and keeps the draft", async () => {
		const wire = submitCaseHandler(() =>
			HttpResponse.json(memberPortalError(500, "Case creation failed."), {
				status: 500,
			}),
		)
		server.use(wire.handler)
		const user = userEvent.setup()
		const { onSubmitted } = renderForm()

		await user.type(subjectBox(), "Billing question")
		await user.type(descriptionBox(), "My invoice is wrong.")
		await user.click(submitButton())

		await vi.waitFor(() => {
			expect(vi.mocked(toast.error)).toHaveBeenCalledWith(
				"Unable to submit support case",
				{ description: "Case creation failed." },
			)
		})
		expect(onSubmitted).not.toHaveBeenCalled()
		expect(vi.mocked(toast.success)).not.toHaveBeenCalled()
		// The draft survives the failure for another attempt.
		expect(subjectBox()).toHaveValue("Billing question")
		expect(descriptionBox()).toHaveValue("My invoice is wrong.")
		expect(submitButton()).toBeEnabled()
	})
})
