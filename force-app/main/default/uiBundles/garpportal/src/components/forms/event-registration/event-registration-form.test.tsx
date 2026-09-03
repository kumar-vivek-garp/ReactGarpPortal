import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { EventRegistrationLoad } from "@/api/registration/event-types"
import { EventRegistrationForm } from "@/components/forms/event-registration/event-registration-form"
import { eventContact, eventLoad } from "@/testing/factories/event"
import { renderWithRouterProviders } from "@/testing/router"

function makeProps(overrides: { load?: EventRegistrationLoad } = {}) {
	const load = overrides.load ?? eventLoad()
	if (!load.event_x) throw new Error("form tests need an event")
	return {
		variant: "event" as const,
		load,
		event: load.event_x,
		profile: null,
		isClientAuthenticated: false,
		submitting: false,
		submitError: null,
		onSubmit: vi.fn(),
	}
}

async function tickAttestation() {
	await userEvent.click(
		screen.getByRole("checkbox", { name: /GARP Privacy Notice/ }),
	)
}

describe("EventRegistrationForm — audience chrome", () => {
	it("gives a guest the identity fields, the upfront sign-in offer, and no back link", async () => {
		await renderWithRouterProviders(<EventRegistrationForm {...makeProps()} />)

		expect(screen.getByText("Your details")).toBeInTheDocument()
		expect(screen.getByLabelText(/Email/)).toBeInTheDocument()
		expect(screen.getByLabelText(/First name/)).toBeInTheDocument()
		expect(
			screen.getByText(/Already have a GARP account\?/),
		).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Sign in" })).toBeInTheDocument()
		expect(screen.queryByRole("link", { name: "Events" })).not.toBeInTheDocument()
	})

	it("hides the prefilled identity for a member — the seeds still travel, the controls go", async () => {
		const props = makeProps({ load: eventLoad({ contact: eventContact() }) })
		await renderWithRouterProviders(
			<EventRegistrationForm {...props} isClientAuthenticated />,
		)

		expect(screen.getByText("Contact details")).toBeInTheDocument()
		expect(screen.queryByLabelText(/Email/)).not.toBeInTheDocument()
		expect(screen.queryByLabelText(/First name/)).not.toBeInTheDocument()
		// The phone stays for everyone — it is how exam-day changes arrive.
		expect(screen.getByLabelText(/Work phone/)).toBeInTheDocument()
		expect(
			screen.queryByText(/Already have a GARP account\?/),
		).not.toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Events" })).toBeInTheDocument()
	})

	it("keeps the identity controls for a signed-in session with NOTHING seeded — hiding them would post an empty identity", async () => {
		await renderWithRouterProviders(
			<EventRegistrationForm {...makeProps()} isClientAuthenticated />,
		)

		expect(screen.getByText("Your details")).toBeInTheDocument()
		expect(screen.getByLabelText(/Email/)).toBeInTheDocument()
	})
})

describe("EventRegistrationForm — submit lifecycle", () => {
	it("stays disabled until valid, enables, and disables AGAIN when the attestation is removed", async () => {
		const props = makeProps({ load: eventLoad({ contact: eventContact() }) })
		await renderWithRouterProviders(
			<EventRegistrationForm {...props} isClientAuthenticated />,
		)

		const submit = screen.getByRole("button", { name: "Complete Registration" })
		expect(submit).toBeDisabled()

		await tickAttestation()
		await waitFor(() => expect(submit).toBeEnabled())

		await tickAttestation()
		await waitFor(() => expect(submit).toBeDisabled())
	})

	it("submits a guest's typed details directly for a free event — no dialog, null country", async () => {
		const props = makeProps()
		await renderWithRouterProviders(<EventRegistrationForm {...props} />)

		await userEvent.type(screen.getByLabelText(/Email/), "ada@example.test")
		await userEvent.type(screen.getByLabelText(/First name/), "Ada")
		await userEvent.type(screen.getByLabelText(/Last name/), "Lovelace")
		await tickAttestation()

		const submit = screen.getByRole("button", { name: "Complete Registration" })
		await waitFor(() => expect(submit).toBeEnabled())
		await userEvent.click(submit)

		await waitFor(() => expect(props.onSubmit).toHaveBeenCalledTimes(1))
		const [values, country] = props.onSubmit.mock.calls[0]
		expect(values).toMatchObject({
			email: "ada@example.test",
			firstName: "Ada",
			lastName: "Lovelace",
			privacyPolicyAttestation: true,
		})
		expect(country).toBeNull()
		expect(
			screen.queryByRole("heading", { name: "Confirm your registration" }),
		).not.toBeInTheDocument()
	})

	it("rejects a malformed email with an inline error", async () => {
		await renderWithRouterProviders(<EventRegistrationForm {...makeProps()} />)

		const email = screen.getByLabelText(/Email/)
		await userEvent.type(email, "not-an-email")
		await userEvent.tab()

		expect(
			await screen.findByText("Please enter a valid email address."),
		).toBeInTheDocument()
		expect(email).toHaveAttribute("aria-invalid", "true")
	})

	it("shows the in-flight state and the submit error against the form", async () => {
		const props = makeProps({ load: eventLoad({ contact: eventContact() }) })
		const { unmount } = await renderWithRouterProviders(
			<EventRegistrationForm {...props} isClientAuthenticated submitting />,
		)

		expect(screen.getByRole("button", { name: "Submitting…" })).toBeDisabled()
		unmount()

		await renderWithRouterProviders(
			<EventRegistrationForm
				{...props}
				isClientAuthenticated
				submitError="Registration failed. Please try again."
			/>,
		)
		expect(screen.getByRole("alert")).toHaveTextContent(
			"Registration failed. Please try again.",
		)
	})
})
