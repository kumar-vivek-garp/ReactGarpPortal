import { useState } from "react"
import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { toast } from "sonner"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

// The app's real QueryClient: its MutationCache owns the toast policy.
import { queryClient as appQueryClient } from "@/api/client"
import type { DirectoryMember, DirectoryMessageInput } from "@/api/directory"
import { DirectoryMemberDialog } from "@/components/molecules/directory-member-dialog"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { directoryMember } from "@/testing/factories/directory"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const MESSAGE_PATH = "/services/apexrest/memberportal/directoryMessage"

/** POST spy answering the memberportal envelope; `respond` per hit. */
function messageWire(respond: () => Response) {
	const spy = { hits: 0, bodies: [] as DirectoryMessageInput[] }
	server.use(
		http.post(MESSAGE_PATH, async ({ request }) => {
			spy.hits += 1
			spy.bodies.push((await request.json()) as DirectoryMessageInput)
			return respond()
		}),
	)
	return spy
}

const sent = () =>
	HttpResponse.json(
		memberPortalEnvelope({ statusMessage: null, statusCode: 200 }),
	)

/** Owns `member` the way the directory panel does, so close = null. */
function Harness({ initial }: { initial: DirectoryMember }) {
	const [member, setMember] = useState<DirectoryMember | null>(initial)
	return (
		<>
			<button type="button" onClick={() => setMember(initial)}>
				Reopen
			</button>
			<DirectoryMemberDialog
				member={member}
				onOpenChange={(open) => {
					if (!open) setMember(null)
				}}
			/>
		</>
	)
}

function renderDialog(overrides: Partial<DirectoryMember> = {}) {
	renderWithProviders(<Harness initial={directoryMember(overrides)} />, {
		queryClient: appQueryClient,
	})
}

beforeEach(() => {
	vi.clearAllMocks()
})
afterEach(() => {
	appQueryClient.clear()
})

const sendMessage = () =>
	screen.queryByRole("button", { name: "Send Message" })
const invite = () =>
	screen.queryByRole("button", { name: "Invite to Connect" })

describe("what the subject's own privacy switches allow", () => {
	it("offers exactly the actions the row grants", () => {
		renderDialog({ canSendMessage: true, canInvite: false })
		expect(sendMessage()).toBeInTheDocument()
		expect(invite()).not.toBeInTheDocument()
	})

	it("explains itself when neither action is allowed", () => {
		renderDialog({ canSendMessage: false, canInvite: false })
		expect(sendMessage()).not.toBeInTheDocument()
		expect(invite()).not.toBeInTheDocument()
		expect(
			screen.getByText("This member has not enabled messaging."),
		).toBeInTheDocument()
	})
})

describe("composing", () => {
	it("labels the note by mode and disables Send until something is typed", async () => {
		const user = userEvent.setup()
		renderDialog({ canSendMessage: true, canInvite: true })

		await user.click(invite()!)
		expect(
			screen.getByLabelText("Add a note to your invitation"),
		).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Send" })).toBeDisabled()

		// Whitespace is not a message.
		await user.type(screen.getByLabelText("Add a note to your invitation"), "   ")
		expect(screen.getByRole("button", { name: "Send" })).toBeDisabled()

		await user.click(screen.getByRole("button", { name: "Back" }))
		await user.click(sendMessage()!)
		expect(screen.getByLabelText("Your message")).toBeInTheDocument()
	})

	it("sends the composed text with the mode's own message type, then closes", async () => {
		const wire = messageWire(sent)
		const user = userEvent.setup()
		renderDialog({ canSendMessage: true })

		await user.click(sendMessage()!)
		await user.type(screen.getByLabelText("Your message"), "Hello Ada")
		await user.click(screen.getByRole("button", { name: "Send" }))

		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})
		expect(wire.bodies).toEqual([
			{
				recipientContactId: "003-1",
				messageType: "Directory_Connect",
				message: "Hello Ada",
			},
		])
	})

	it("keeps the dialog open with the draft intact when the server refuses", async () => {
		messageWire(() =>
			HttpResponse.json(memberPortalError(500, "Messaging is unavailable."), {
				status: 500,
			}),
		)
		const user = userEvent.setup()
		renderDialog({ canSendMessage: true })

		await user.click(sendMessage()!)
		await user.type(screen.getByLabelText("Your message"), "Hello Ada")
		await user.click(screen.getByRole("button", { name: "Send" }))

		await waitFor(() => {
			expect(vi.mocked(toast.error)).toHaveBeenCalledWith(
				"Unable to send your message",
				{ description: "Messaging is unavailable." },
			)
		})
		expect(screen.getByRole("dialog")).toBeInTheDocument()
		expect(screen.getByLabelText("Your message")).toHaveValue("Hello Ada")
	})

	it("forgets the draft and the mode when the dialog closes", async () => {
		const user = userEvent.setup()
		renderDialog({ canSendMessage: true })

		await user.click(sendMessage()!)
		await user.type(screen.getByLabelText("Your message"), "Half a thought")
		await user.keyboard("{Escape}")
		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})

		await user.click(screen.getByRole("button", { name: "Reopen" }))
		await screen.findByRole("dialog")
		// Back at the gated actions, not mid-composition.
		expect(sendMessage()).toBeInTheDocument()
		expect(screen.queryByLabelText("Your message")).not.toBeInTheDocument()
	})
})

describe("the member's details", () => {
	it("shows a detail row only when it has a value", () => {
		renderDialog({
			canSendMessage: true,
			mailingCity: "London",
			jobFunction: null,
			riskSpecialty: "  ",
		})
		expect(screen.getByText("Location")).toBeInTheDocument()
		expect(screen.getByText("London")).toBeInTheDocument()
		expect(screen.queryByText("Job function")).not.toBeInTheDocument()
		expect(screen.queryByText("Risk specialty")).not.toBeInTheDocument()
	})
})
