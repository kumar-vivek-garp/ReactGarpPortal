import { useForm } from "react-hook-form"
import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import type { EventView } from "@/api/registration/event-types"
import {
	toEventFormValues,
	type EventFormValues,
} from "@/components/forms/event-registration/event-form-values"
import { ActivitySection } from "@/components/forms/event-registration/sections/activity-section"
import { eventView } from "@/testing/factories/event"
import { renderWithProviders } from "@/testing/render"

/** Owns the react-hook-form instance the way the event form does. */
function Harness({ event }: { event: EventView }) {
	const form = useForm<EventFormValues>({
		defaultValues: toEventFormValues(null),
	})
	return (
		<ActivitySection
			register={form.register}
			control={form.control}
			event={event}
		/>
	)
}

function dinnerEvent(overrides: Partial<EventView> = {}) {
	return eventView({
		rsvpActivityName: "Networking Dinner",
		rsvpActivityDetails: "Drinks and canapés after the last session.",
		rsvpActivityLocation: "The Rooftop, 5th floor",
		rsvpActivityAskDiet: true,
		rsvpActivityQuestion: "Are you bringing a guest?",
		...overrides,
	})
}

const attendBox = () =>
	screen.getByRole("checkbox", { name: /Yes, I will attend Networking Dinner/ })
const dietaryBox = () =>
	screen.queryByRole("checkbox", { name: /I have dietary restrictions/ })

describe("the attendance cascade", () => {
	it("keeps dietary and the activity question hidden until the person is coming", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness event={dinnerEvent()} />)

		expect(dietaryBox()).not.toBeInTheDocument()
		expect(
			screen.queryByLabelText(/Are you bringing a guest/),
		).not.toBeInTheDocument()

		await user.click(attendBox())

		expect(dietaryBox()).toBeInTheDocument()
		expect(screen.getByLabelText(/Are you bringing a guest/)).toBeInTheDocument()
	})

	it("reveals the details textarea only once dietary restrictions are ticked", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness event={dinnerEvent()} />)

		await user.click(attendBox())
		expect(screen.queryByLabelText("Tell us more")).not.toBeInTheDocument()

		await user.click(dietaryBox()!)
		const details = screen.getByLabelText("Tell us more")
		await user.type(details, "Vegetarian")
		expect(details).toHaveValue("Vegetarian")

		// Unticking folds the textarea back away.
		await user.click(dietaryBox()!)
		expect(screen.queryByLabelText("Tell us more")).not.toBeInTheDocument()
	})
})

describe("what the event's own flags gate", () => {
	it("asks no dietary question when the event does not collect one", async () => {
		const user = userEvent.setup()
		renderWithProviders(
			<Harness event={dinnerEvent({ rsvpActivityAskDiet: false })} />,
		)

		await user.click(attendBox())
		expect(dietaryBox()).not.toBeInTheDocument()
		// The activity question is independent of dietary.
		expect(screen.getByLabelText(/Are you bringing a guest/)).toBeInTheDocument()
	})

	it("asks no activity question when the event has none", async () => {
		const user = userEvent.setup()
		renderWithProviders(
			<Harness event={dinnerEvent({ rsvpActivityQuestion: null })} />,
		)

		await user.click(attendBox())
		expect(
			screen.queryByLabelText(/Are you bringing a guest/),
		).not.toBeInTheDocument()
	})

	it("shows the activity's details and location only when present", () => {
		const { rerender } = renderWithProviders(<Harness event={dinnerEvent()} />)
		expect(
			screen.getByText("Drinks and canapés after the last session."),
		).toBeInTheDocument()
		expect(screen.getByText("The Rooftop, 5th floor")).toBeInTheDocument()

		rerender(
			<Harness
				event={dinnerEvent({
					rsvpActivityDetails: null,
					rsvpActivityLocation: null,
				})}
			/>,
		)
		expect(
			screen.queryByText("Drinks and canapés after the last session."),
		).not.toBeInTheDocument()
		expect(screen.queryByText("The Rooftop, 5th floor")).not.toBeInTheDocument()
	})
})
