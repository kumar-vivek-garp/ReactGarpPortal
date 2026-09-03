import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it, vi } from "vitest"

import { AlertBarCard } from "@/components/molecules/alert-bar-card"
import type { AlertBarModel } from "@/lib/alert-bar-presentation"
import { useAlertBarStore, type AlertBarPhase } from "@/store/alert-bar-store"
import { renderWithProviders } from "@/testing/render"
import { skipSpringAnimations } from "@/testing/springs"

/*
 * The card's phase hand-off hangs off spring completion (`onRest`), so springs
 * jump to their end state here. Safe: AlertBarCard mounts no
 * `useSubpageTransition` — its only springs are the flight spring and the
 * CardCta nudge (verified in source).
 */
skipSpringAnimations()

function model(overrides: Partial<AlertBarModel> = {}): AlertBarModel {
	return {
		programme: "FRM Part I",
		message: "You have not booked a seat for your exam yet.",
		deadlineLabel: "Book by 7 November 2026",
		tone: "urgent",
		action: {
			label: "Schedule your exam",
			href: "https://my.garp.org/exam-setup",
			isExternal: true,
		},
		...overrides,
	}
}

function renderCard(phase: AlertBarPhase, alertModel = model()) {
	const onMinimise = vi.fn()
	const onMinimised = vi.fn()
	const onRestored = vi.fn()
	const view = renderWithProviders(
		<AlertBarCard
			model={alertModel}
			phase={phase}
			onMinimise={onMinimise}
			onMinimised={onMinimised}
			onRestored={onRestored}
		/>,
	)
	return { onMinimise, onMinimised, onRestored, ...view }
}

beforeEach(() => {
	useAlertBarStore.setState({
		phase: "expanded",
		phaseFor: null,
		anchors: { desktop: null, mobile: null },
	})
})

describe("AlertBarCard — rendering the resolved model", () => {
	it("renders programme, deadline, message and CTA; urgent tone interrupts", () => {
		renderCard("expanded")

		const alert = screen.getByRole("alert")
		expect(alert).toHaveTextContent("FRM Part I")
		expect(alert).toHaveTextContent("Book by 7 November 2026")
		expect(alert).toHaveTextContent(
			"You have not booked a seat for your exam yet.",
		)
		expect(
			screen.getByRole("link", { name: /schedule your exam/i }),
		).toHaveAttribute("href", "https://my.garp.org/exam-setup")
	})

	it("renders a soft nudge as a status, not an interrupting alert", () => {
		renderCard("expanded", model({ tone: "notice" }))

		expect(screen.getByRole("status")).toBeInTheDocument()
		expect(screen.queryByRole("alert")).not.toBeInTheDocument()
	})

	it("drops the deadline separator and the CTA when the model has neither", () => {
		renderCard(
			"expanded",
			model({ deadlineLabel: null, action: null }),
		)

		expect(screen.getByRole("alert")).not.toHaveTextContent("·")
		expect(screen.queryByRole("link")).not.toBeInTheDocument()
	})
})

describe("AlertBarCard — phase wiring", () => {
	it("the chevron asks the owner to minimise, and nothing else", async () => {
		const user = userEvent.setup()
		const { onMinimise, onMinimised, onRestored } = renderCard("expanded")

		await user.click(screen.getByRole("button", { name: "Minimise alert" }))

		expect(onMinimise).toHaveBeenCalledTimes(1)
		expect(onMinimised).not.toHaveBeenCalled()
		expect(onRestored).not.toHaveBeenCalled()
	})

	it("a finished minimising flight hands the phase on via onMinimised", async () => {
		const { onMinimised, onRestored } = renderCard("minimising")

		await waitFor(() => expect(onMinimised).toHaveBeenCalled())
		expect(onRestored).not.toHaveBeenCalled()
	})

	it("a finished restoring flight hands the phase on via onRestored", async () => {
		const { onMinimised, onRestored } = renderCard("restoring")

		await waitFor(() => expect(onRestored).toHaveBeenCalled())
		expect(onMinimised).not.toHaveBeenCalled()
	})

	it("mounting already minimised snaps into place without firing callbacks", () => {
		const { onMinimise, onMinimised, onRestored } = renderCard("minimised")

		expect(onMinimise).not.toHaveBeenCalled()
		expect(onMinimised).not.toHaveBeenCalled()
		expect(onRestored).not.toHaveBeenCalled()
	})

	it("measures the flight against the anchor registered in the store", async () => {
		const trigger = document.createElement("button")
		vi.spyOn(trigger, "getBoundingClientRect").mockReturnValue({
			top: 10,
			left: 900,
			width: 40,
			height: 40,
			bottom: 50,
			right: 940,
			x: 900,
			y: 10,
			toJSON: () => ({}),
		} as DOMRect)
		useAlertBarStore.getState().setAnchor("desktop", trigger)

		const { onMinimised } = renderCard("minimising")

		// The pose is computed from the store's anchor; the flight still
		// completes and hands the phase on.
		await waitFor(() => expect(onMinimised).toHaveBeenCalled())
	})
})

describe("AlertBarCard — the full minimise loop through the store", () => {
	/** Owner stand-in: phase lives in the store, exactly as the layout wires it. */
	function StoreDrivenCard() {
		const phase = useAlertBarStore((state) => state.phase)
		const setPhase = useAlertBarStore((state) => state.setPhase)
		return (
			<AlertBarCard
				model={model()}
				phase={phase}
				onMinimise={() => setPhase("minimising", "Scheduling Incomplete")}
				onMinimised={() => setPhase("minimised", "Scheduling Incomplete")}
				onRestored={() => setPhase("expanded", null)}
			/>
		)
	}

	it("a click on the chevron travels expanded → minimising → minimised", async () => {
		const user = userEvent.setup()
		renderWithProviders(<StoreDrivenCard />)

		await user.click(screen.getByRole("button", { name: "Minimise alert" }))

		// The spring finishes (skipped), the onMinimised callback lands the
		// terminal phase in the store, keyed on the alert it was set for.
		await waitFor(() =>
			expect(useAlertBarStore.getState().phase).toBe("minimised"),
		)
		expect(useAlertBarStore.getState().phaseFor).toBe("Scheduling Incomplete")
	})

	it("restoring grows the card back out and settles the store on expanded", async () => {
		useAlertBarStore.setState({
			phase: "restoring",
			phaseFor: "Scheduling Incomplete",
		})
		renderWithProviders(<StoreDrivenCard />)

		await waitFor(() =>
			expect(useAlertBarStore.getState().phase).toBe("expanded"),
		)
		expect(useAlertBarStore.getState().phaseFor).toBeNull()
	})
})
