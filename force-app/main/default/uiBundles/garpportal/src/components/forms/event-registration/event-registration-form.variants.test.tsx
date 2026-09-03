import { screen, waitFor } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"

import type {
	EventRegistrationLoad,
	EventVariant,
} from "@/api/registration/event-types"
import { EventRegistrationForm } from "@/components/forms/event-registration/event-registration-form"
import { eventCountry, eventLoad, eventView } from "@/testing/factories/event"
import { examregGet } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

function renderForm(variant: EventVariant, load: EventRegistrationLoad) {
	if (!load.event_x) throw new Error("variant tests need an event")
	return renderWithRouterProviders(
		<EventRegistrationForm
			variant={variant}
			load={load}
			event={load.event_x}
			profile={null}
			isClientAuthenticated={false}
			submitting={false}
			submitError={null}
			onSubmit={vi.fn()}
		/>,
	)
}

describe("EventRegistrationForm — section rules per variant", () => {
	it("asks how a hybrid event will be attended, and only a hybrid one", async () => {
		const hybrid = await renderForm(
			"event",
			eventLoad({ event_x: eventView({ isHybrid: true }) }),
		)
		expect(screen.getByText("How will you attend?")).toBeInTheDocument()
		hybrid.unmount()

		await renderForm("event", eventLoad())
		expect(screen.queryByText("How will you attend?")).not.toBeInTheDocument()
	})

	it("shows the activity card only for plain events that have one", async () => {
		const withActivity = eventView({ rsvpActivityName: "Networking Dinner" })
		const plain = await renderForm("event", eventLoad({ event_x: withActivity }))
		expect(screen.getByText("Networking Dinner")).toBeInTheDocument()
		plain.unmount()

		// The same event data under a different variant — the card stays off.
		await renderForm(
			"chaptermeeting",
			eventLoad({ event_x: withActivity }),
		)
		expect(screen.queryByText("Networking Dinner")).not.toBeInTheDocument()
	})

	it("shows the organiser's question card only on the event variant", async () => {
		const withQuestion = eventView({
			eventQuestionTitle: "Anything you want covered?",
		})
		const plain = await renderForm("event", eventLoad({ event_x: withQuestion }))
		expect(screen.getByText("Anything you want covered?")).toBeInTheDocument()
		plain.unmount()

		await renderForm("chaptermeeting", eventLoad({ event_x: withQuestion }))
		expect(
			screen.queryByText("Anything you want covered?"),
		).not.toBeInTheDocument()
	})

	it("folds job title and company away for a chapter meeting unless the chapter requires them", async () => {
		const optional = await renderForm("chaptermeeting", eventLoad())
		expect(screen.queryByLabelText(/Job title/)).not.toBeInTheDocument()
		expect(screen.queryByLabelText(/Company/)).not.toBeInTheDocument()
		optional.unmount()

		await renderForm(
			"chaptermeeting",
			eventLoad({ event_x: eventView({ professionalDetailsRequired: true }) }),
		)
		expect(screen.getByLabelText(/Job title/)).toBeInTheDocument()
		expect(screen.getByLabelText(/Company/)).toBeInTheDocument()
	})

	it("offers the sponsor's consent OR GARP's — never both", async () => {
		const sponsored = await renderForm(
			"event",
			eventLoad({
				event_x: eventView({
					isSponsored: true,
					sponsorName: "Acme Analytics",
					sponsorPolicyUrl: "https://sponsor.example/privacy",
				}),
			}),
		)
		expect(screen.getByText("Sponsor communications")).toBeInTheDocument()
		expect(
			screen.getByRole("checkbox", { name: /Acme Analytics/ }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Sponsor Privacy Statement" }),
		).toHaveAttribute("href", "https://sponsor.example/privacy")
		expect(screen.queryByText("Valuable content")).not.toBeInTheDocument()
		sponsored.unmount()

		await renderForm("event", eventLoad())
		expect(screen.getByText("Valuable content")).toBeInTheDocument()
		expect(screen.queryByText("Sponsor communications")).not.toBeInTheDocument()
	})

	it("asks a webcast for its location, fetching countries for the card — and no other variant does", async () => {
		const options = examregGet("event/options", () => ({
			countries: [eventCountry()],
			professionalLevels: [],
			jobFunctions: [],
			riskSpecialties: [],
		}))
		server.use(options.handler)

		const webcast = await renderForm("webcast", eventLoad({ variant: "webcast" }))
		expect(screen.getByText("Your location")).toBeInTheDocument()
		await waitFor(() => expect(options.spy.hits).toBeGreaterThan(0))
		webcast.unmount()

		const hitsAfterWebcast = options.spy.hits
		await renderForm("event", eventLoad())
		expect(screen.queryByText("Your location")).not.toBeInTheDocument()
		// The disabled-query trap: a non-webcast form never asks for countries.
		expect(options.spy.hits).toBe(hitsAfterWebcast)
	})
})
