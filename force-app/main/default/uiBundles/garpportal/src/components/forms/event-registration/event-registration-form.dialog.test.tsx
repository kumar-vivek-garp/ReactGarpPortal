import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { EventRegistrationForm } from "@/components/forms/event-registration/event-registration-form"
import {
	eventContact,
	eventLoad,
	eventRates,
	eventView,
} from "@/testing/factories/event"
import { renderWithRouterProviders } from "@/testing/router"

/** A $150 event for a member whose identity is already seeded — only the
 * attestation stands between them and a valid form. */
function paidProps() {
	const load = eventLoad({
		event_x: eventView({ title: "Risk Convention", isPayFor: true }),
		contact: eventContact(),
		rates: eventRates({ amountDue: 150 }),
	})
	return {
		variant: "event" as const,
		load,
		event: load.event_x!,
		profile: null,
		isClientAuthenticated: true,
		submitting: false,
		submitError: null,
		onSubmit: vi.fn(),
	}
}

async function makeValid() {
	await userEvent.click(
		screen.getByRole("checkbox", { name: /GARP Privacy Notice/ }),
	)
}

describe("EventRegistrationForm — paid staging dialog", () => {
	it("prices the bar and labels the submit for payment", async () => {
		await renderWithRouterProviders(<EventRegistrationForm {...paidProps()} />)

		// "Total" and the figure appear in the sticky bar AND the summary rail.
		expect(screen.getAllByText("Total").length).toBeGreaterThan(0)
		expect(screen.getAllByText(/150/).length).toBeGreaterThan(0)
		expect(
			screen.getByRole("button", { name: "Continue to Payment" }),
		).toBeInTheDocument()
	})

	it("stages a paid submit behind the confirm dialog instead of firing it", async () => {
		const props = paidProps()
		await renderWithRouterProviders(<EventRegistrationForm {...props} />)

		await makeValid()
		const submit = screen.getByRole("button", { name: "Continue to Payment" })
		await waitFor(() => expect(submit).toBeEnabled())
		await userEvent.click(submit)

		const dialog = await screen.findByRole("dialog", {
			name: "Confirm your registration",
		})
		// One more look at the money — the event by name, the figure beside it.
		expect(within(dialog).getByText("Risk Convention")).toBeInTheDocument()
		expect(within(dialog).getByText(/150/)).toBeInTheDocument()
		expect(props.onSubmit).not.toHaveBeenCalled()
	})

	it("Back closes the dialog with nothing sent, and the staging can run again", async () => {
		const props = paidProps()
		await renderWithRouterProviders(<EventRegistrationForm {...props} />)

		await makeValid()
		const submit = screen.getByRole("button", { name: "Continue to Payment" })
		await waitFor(() => expect(submit).toBeEnabled())
		await userEvent.click(submit)
		await screen.findByRole("dialog", { name: "Confirm your registration" })

		await userEvent.click(screen.getByRole("button", { name: "Back" }))
		await waitFor(() =>
			expect(
				screen.queryByRole("dialog", { name: "Confirm your registration" }),
			).not.toBeInTheDocument(),
		)
		expect(props.onSubmit).not.toHaveBeenCalled()

		// Nothing was consumed by cancelling — the same submit stages again.
		await userEvent.click(submit)
		expect(
			await screen.findByRole("dialog", { name: "Confirm your registration" }),
		).toBeInTheDocument()
	})

	it("Confirm fires the staged submit exactly once and closes as it fires", async () => {
		const props = paidProps()
		await renderWithRouterProviders(<EventRegistrationForm {...props} />)

		await makeValid()
		const submit = screen.getByRole("button", { name: "Continue to Payment" })
		await waitFor(() => expect(submit).toBeEnabled())
		await userEvent.click(submit)
		await screen.findByRole("dialog", { name: "Confirm your registration" })

		await userEvent.click(
			screen.getByRole("button", { name: "Confirm and Pay" }),
		)

		await waitFor(() => expect(props.onSubmit).toHaveBeenCalledTimes(1))
		const [values] = props.onSubmit.mock.calls[0]
		expect(values).toMatchObject({
			email: "ada@example.test",
			privacyPolicyAttestation: true,
		})
		// Closed on confirm — a failure must render against the form, not
		// behind a modal.
		await waitFor(() =>
			expect(
				screen.queryByRole("dialog", { name: "Confirm your registration" }),
			).not.toBeInTheDocument(),
		)
	})
})
