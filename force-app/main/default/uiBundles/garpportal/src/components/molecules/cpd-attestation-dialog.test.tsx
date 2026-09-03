import { useState } from "react"
import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { toast } from "sonner"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

// The app's real QueryClient: its MutationCache owns the toast policy.
import { queryClient as appQueryClient } from "@/api/client"
import { CpdAttestationDialog } from "@/components/molecules/cpd-attestation-dialog"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const CPD_ATTEST_PATH = "/services/apexrest/memberportal/cpdAttest"

/** POST spy answering the memberportal envelope; `respond` per hit. */
function attestHandler(respond: (hits: number) => Response) {
	const spy = { hits: 0, bodies: [] as unknown[] }
	const handler = http.post(CPD_ATTEST_PATH, async ({ request }) => {
		spy.hits += 1
		spy.bodies.push(await request.json())
		return respond(spy.hits)
	})
	return { spy, handler }
}

const attested = () =>
	memberPortalEnvelope({ status: "Success", msg: null, claimId: null })

/** Owns `open` the way the CPD page does, so reopening exercises the unmount. */
function Harness({
	attestationId = "a-1",
	creditsRequired = 40 as number | null,
	onAttested,
}: {
	attestationId?: string | null
	creditsRequired?: number | null
	onAttested: () => void
}) {
	const [open, setOpen] = useState(true)
	return (
		<>
			<button type="button" onClick={() => setOpen(true)}>
				Reopen
			</button>
			<CpdAttestationDialog
				open={open}
				onOpenChange={setOpen}
				attestationId={attestationId}
				creditsRequired={creditsRequired}
				onAttested={onAttested}
			/>
		</>
	)
}

function renderDialog(options: {
	attestationId?: string | null
	creditsRequired?: number | null
} = {}) {
	const onAttested = vi.fn()
	renderWithProviders(<Harness onAttested={onAttested} {...options} />, {
		queryClient: appQueryClient,
	})
	return { onAttested }
}

beforeEach(() => {
	vi.clearAllMocks()
})
afterEach(() => {
	appQueryClient.clear()
})

const attestBox = () =>
	screen.getByRole("checkbox", { name: /I attest that all I have submitted/ })
const conductBox = () =>
	screen.getByRole("checkbox", { name: /Code of Conduct/ })
const submitButton = () => screen.getByRole("button", { name: "Submit" })

async function closedDialog() {
	await waitFor(() => {
		expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
	})
}

describe("heading", () => {
	it("names the completed credit requirement", () => {
		renderDialog({ creditsRequired: 40 })
		expect(
			screen.getByRole("heading", {
				name: "You have completed your required 40 credits.",
			}),
		).toBeInTheDocument()
	})

	it("falls back to a plain confirmation when the requirement is unknown", () => {
		renderDialog({ creditsRequired: null })
		expect(
			screen.getByRole("heading", { name: "Confirm your CPD credits." }),
		).toBeInTheDocument()
	})
})

describe("the two required ticks", () => {
	it("enables Submit only while BOTH boxes are ticked", async () => {
		const user = userEvent.setup()
		renderDialog()

		expect(submitButton()).toBeDisabled()

		await user.click(attestBox())
		expect(submitButton()).toBeDisabled()

		await user.click(conductBox())
		expect(submitButton()).toBeEnabled()

		// Unticking either one locks it again.
		await user.click(attestBox())
		expect(submitButton()).toBeDisabled()

		await user.click(attestBox())
		expect(submitButton()).toBeEnabled()
		await user.click(conductBox())
		expect(submitButton()).toBeDisabled()
	})

	it("stays locked without an attestation id, even fully ticked", async () => {
		const user = userEvent.setup()
		renderDialog({ attestationId: null })

		await user.click(attestBox())
		await user.click(conductBox())
		expect(submitButton()).toBeDisabled()
	})

	it("resets both ticks by unmounting on close, not by carrying them over", async () => {
		const user = userEvent.setup()
		renderDialog()

		await user.click(attestBox())
		await user.click(conductBox())
		await user.click(screen.getByRole("button", { name: "Cancel" }))
		await closedDialog()

		await user.click(screen.getByRole("button", { name: "Reopen" }))
		await screen.findByRole("dialog")
		expect(attestBox()).not.toBeChecked()
		expect(conductBox()).not.toBeChecked()
		expect(submitButton()).toBeDisabled()
	})
})

describe("submitting", () => {
	it("posts the attestation id, then closes and hands off to the certificate", async () => {
		const wire = attestHandler(() => HttpResponse.json(attested()))
		server.use(wire.handler)
		const user = userEvent.setup()
		const { onAttested } = renderDialog()

		await user.click(attestBox())
		await user.click(conductBox())
		await user.click(submitButton())

		await waitFor(() => expect(onAttested).toHaveBeenCalledTimes(1))
		expect(wire.spy.hits).toBe(1)
		expect(wire.spy.bodies[0]).toEqual({ attestationId: "a-1" })
		await closedDialog()
	})

	it("keeps the dialog open and toasts when the server refuses", async () => {
		const wire = attestHandler(() =>
			HttpResponse.json(memberPortalError(500, "Attestation not found."), {
				status: 500,
			}),
		)
		server.use(wire.handler)
		const user = userEvent.setup()
		const { onAttested } = renderDialog()

		await user.click(attestBox())
		await user.click(conductBox())
		await user.click(submitButton())

		await waitFor(() => {
			expect(vi.mocked(toast.error)).toHaveBeenCalledWith(
				"Unable to record your attestation",
				{ description: "Attestation not found." },
			)
		})
		expect(onAttested).not.toHaveBeenCalled()
		expect(screen.getByRole("dialog")).toBeInTheDocument()
		expect(submitButton()).toBeEnabled()
	})

	it("relabels Submit and locks Cancel while the write is in flight", async () => {
		let release!: () => void
		const gate = new Promise<void>((resolve) => {
			release = resolve
		})
		server.use(
			http.post(CPD_ATTEST_PATH, async () => {
				await gate
				return HttpResponse.json(attested())
			}),
		)
		const user = userEvent.setup()
		const { onAttested } = renderDialog()

		await user.click(attestBox())
		await user.click(conductBox())
		await user.click(submitButton())

		const busy = await screen.findByRole("button", { name: "Submitting…" })
		expect(busy).toBeDisabled()
		expect(screen.getByRole("button", { name: "Cancel" })).toBeDisabled()

		release()
		await waitFor(() => expect(onAttested).toHaveBeenCalledTimes(1))
	})
})
