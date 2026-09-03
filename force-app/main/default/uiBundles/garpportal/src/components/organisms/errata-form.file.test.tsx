import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { toast } from "sonner"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

// The app's real QueryClient: its MutationCache owns the toast policy.
import { queryClient as appQueryClient } from "@/api/client"
import type { ErrataFormView, ErrataSubmission } from "@/api/errata"
import { ErrataForm } from "@/components/organisms/errata-form"
import { ERRATA_MAX_UPLOAD_BYTES } from "@/config/errata"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const SUBMIT_PATH = "/services/apexrest/memberportal/submitErrata"
const ATTACH_PATH = "/services/apexrest/memberportal/attachErrataFile"

const VIEW: ErrataFormView = {
	statusMessage: null,
	statusCode: 200,
	errataPicklistOption: {
		"FRM Part I Books": ["Foundations of Risk"],
	},
}

function errataWire(respondAttach?: (hits: number) => Response) {
	const submit = { hits: 0, bodies: [] as ErrataSubmission[] }
	const attach = { hits: 0, bodies: [] as unknown[] }
	server.use(
		http.post(SUBMIT_PATH, async ({ request }) => {
			submit.hits += 1
			submit.bodies.push((await request.json()) as ErrataSubmission)
			return HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					errataId: "err-9",
				}),
			)
		}),
		http.post(ATTACH_PATH, async ({ request }) => {
			attach.hits += 1
			attach.bodies.push(await request.json())
			return (
				respondAttach?.(attach.hits) ??
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						fileId: "file-1",
					}),
				)
			)
		}),
	)
	return { submit, attach }
}

function renderForm() {
	const onSubmitted = vi.fn()
	renderWithProviders(
		<ErrataForm programType="frm" view={VIEW} onSubmitted={onSubmitted} />,
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

/**
 * The real input is `sr-only` with no label of its own — the visible control
 * is the "Add a file" button, whose click it receives. `userEvent.upload`
 * needs the input element itself, so this is the one sanctioned traversal.
 */
const fileInput = () =>
	document.querySelector('input[type="file"]') as HTMLInputElement

const helloFile = () => new File(["hello"], "hello.txt", { type: "text/plain" })

async function fillRequired(user: ReturnType<typeof userEvent.setup>) {
	await user.click(screen.getByRole("combobox", { name: /What study material/ }))
	await user.click(await screen.findByRole("option", { name: "FRM Part I Books" }))
	await user.click(screen.getByRole("combobox", { name: /What book/ }))
	await user.click(
		await screen.findByRole("option", { name: "Foundations of Risk" }),
	)
	await user.type(screen.getByRole("textbox", { name: /What page/ }), "12")
	await user.type(
		screen.getByRole("textbox", { name: /Describe the problem/ }),
		"Broken formula",
	)
}

describe("choosing a file", () => {
	it("shows the accepted file and can remove it again", async () => {
		const user = userEvent.setup()
		renderForm()

		// The visible control forwards to the hidden input (no picker in jsdom).
		await user.click(screen.getByRole("button", { name: "Add a file" }))
		await user.upload(fileInput(), helloFile())
		expect(await screen.findByText("hello.txt")).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Add a file" }),
		).not.toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "Remove hello.txt" }))
		expect(screen.queryByText("hello.txt")).not.toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Add a file" })).toBeInTheDocument()
	})

	it("refuses a type GARP does not accept, naming the allowed ones", async () => {
		// applyAccept off: the real browser dialog can be bypassed the same way.
		const user = userEvent.setup({ applyAccept: false })
		renderForm()

		const zip = new File(["zip"], "archive.zip", { type: "application/zip" })
		await user.upload(fileInput(), zip)

		expect(
			await screen.findByRole("alert"),
		).toHaveTextContent(
			".jpg, .jpeg, .png, .pdf, .doc, .docx, .xls, .xlsx, .txt files only.",
		)
		expect(screen.queryByText("archive.zip")).not.toBeInTheDocument()
	})

	it("refuses a file over the 2 MB cap", async () => {
		const user = userEvent.setup()
		renderForm()

		const big = new File(
			[new Uint8Array(ERRATA_MAX_UPLOAD_BYTES + 1)],
			"big.png",
			{ type: "image/png" },
		)
		await user.upload(fileInput(), big)

		expect(await screen.findByRole("alert")).toHaveTextContent(
			"This file is larger than 2 MB. Please upload a smaller one.",
		)
	})

	it("refuses an empty file", async () => {
		const user = userEvent.setup()
		renderForm()

		await user.upload(fileInput(), new File([], "empty.txt", { type: "text/plain" }))
		expect(await screen.findByRole("alert")).toHaveTextContent(
			"This file is empty.",
		)
	})

	it("clears the refusal on the next valid pick", async () => {
		const user = userEvent.setup({ applyAccept: false })
		renderForm()

		const zip = new File(["zip"], "archive.zip", { type: "application/zip" })
		await user.upload(fileInput(), zip)
		await screen.findByRole("alert")

		await user.upload(fileInput(), helloFile())
		expect(await screen.findByText("hello.txt")).toBeInTheDocument()
		expect(screen.queryByRole("alert")).not.toBeInTheDocument()
	})
})

describe("submitting with a file", () => {
	it("files the report, then attaches the raw base64 under the returned id", async () => {
		const wire = errataWire()
		const user = userEvent.setup()
		const { onSubmitted } = renderForm()

		await fillRequired(user)
		await user.upload(fileInput(), helloFile())
		await user.click(screen.getByRole("button", { name: "Submit report" }))

		await waitFor(() => expect(onSubmitted).toHaveBeenCalledTimes(1))
		expect(wire.submit.hits).toBe(1)
		expect(wire.attach.hits).toBe(1)
		expect(wire.attach.bodies[0]).toEqual({
			errataId: "err-9",
			fileName: "hello.txt",
			fileText: "aGVsbG8=",
		})
		expect(onSubmitted).toHaveBeenCalledWith({
			errataId: "err-9",
			attachmentError: null,
		})
	})

	it("reports a failed attachment as a warning on a SUCCESSFUL submission", async () => {
		const wire = errataWire(() =>
			HttpResponse.json(memberPortalError(500, "Attachment refused."), {
				status: 500,
			}),
		)
		const user = userEvent.setup()
		const { onSubmitted } = renderForm()

		await fillRequired(user)
		await user.upload(fileInput(), helloFile())
		await user.click(screen.getByRole("button", { name: "Submit report" }))

		// The report is already filed — the outcome resolves rather than erroring,
		// so nothing invites a duplicate resubmission.
		await waitFor(() => expect(onSubmitted).toHaveBeenCalledTimes(1))
		expect(onSubmitted).toHaveBeenCalledWith({
			errataId: "err-9",
			attachmentError: "Attachment refused.",
		})
		expect(wire.submit.hits).toBe(1)
		expect(vi.mocked(toast.error)).not.toHaveBeenCalled()
	})

	it("relabels Submit while the pair of calls is in flight", async () => {
		let release!: () => void
		const gate = new Promise<void>((resolve) => {
			release = resolve
		})
		server.use(
			http.post(SUBMIT_PATH, async () => {
				await gate
				return HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						errataId: "err-9",
					}),
				)
			}),
		)
		const user = userEvent.setup()
		const { onSubmitted } = renderForm()

		await fillRequired(user)
		await user.click(screen.getByRole("button", { name: "Submit report" }))

		const busy = await screen.findByRole("button", { name: "Submitting…" })
		expect(busy).toBeDisabled()

		release()
		await waitFor(() => expect(onSubmitted).toHaveBeenCalledTimes(1))
		expect(screen.getByRole("button", { name: "Submit report" })).toBeEnabled()
	})
})
