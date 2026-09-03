import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it } from "vitest"

import { alertBarQueryKeys } from "@/api/alert-bar"
import type { AlertBarView } from "@/api/alert-bar/types"
import { ALERT_BAR_EXPAND_LABEL } from "@/config/alert-bar"
import { AlertBarTrigger } from "@/components/molecules/alert-bar-trigger"
import { useAlertBarStore } from "@/store/alert-bar-store"
import { renderWithProviders } from "@/testing/render"
import { createTestQueryClient } from "@/testing/query-client"

/** A live "Scheduling Incomplete" alert — urgent tone, in-app action. */
function alertView(overrides: Partial<AlertBarView> = {}): AlertBarView {
	return {
		statusMessage: null,
		statusCode: 200,
		examType: "FRM",
		examPart: "I",
		alertStatus: "Scheduling Incomplete",
		deadline: "2026-11-07",
		orderId: null,
		route: "Exam Scheduling",
		...overrides,
	}
}

/** Seeds the alert query so `useAlertBar` never hits the wire (staleTime 5m). */
function renderTrigger({
	view = alertView() as AlertBarView | null,
	placement = "desktop" as const,
	onActivate,
}: {
	view?: AlertBarView | null
	placement?: "desktop" | "mobile"
	onActivate?: () => void
} = {}) {
	const queryClient = createTestQueryClient()
	queryClient.setQueryData(alertBarQueryKeys.view, view)
	return renderWithProviders(
		<AlertBarTrigger placement={placement} onActivate={onActivate} />,
		{ queryClient },
	)
}

beforeEach(() => {
	useAlertBarStore.setState({
		phase: "expanded",
		phaseFor: null,
		anchors: { desktop: null, mobile: null },
	})
})

describe("AlertBarTrigger — when it exists at all", () => {
	it("renders nothing when there is no alert", () => {
		renderTrigger({ view: null })

		expect(screen.queryByRole("button", { hidden: true })).not.toBeInTheDocument()
	})

	it("holds the slot while the card is expanded: present but inert and hidden", () => {
		renderTrigger()

		const button = screen.getByRole("button", {
			name: ALERT_BAR_EXPAND_LABEL,
			hidden: true,
		})
		expect(button).toHaveAttribute("tabindex", "-1")
		// The wrapper is aria-hidden so the invisible control is not announced.
		expect(
			screen.queryByRole("button", { name: ALERT_BAR_EXPAND_LABEL }),
		).not.toBeInTheDocument()
	})

	it("becomes a real control once the phase is minimised for this alert", () => {
		useAlertBarStore.getState().setPhase("minimised", "Scheduling Incomplete")
		renderTrigger()

		const button = screen.getByRole("button", { name: ALERT_BAR_EXPAND_LABEL })
		expect(button).toHaveAttribute("tabindex", "0")
	})

	it("stays hidden when the minimised phase was keyed to a different alert", () => {
		useAlertBarStore.getState().setPhase("minimised", "Exam Unpaid")
		renderTrigger()

		// phaseFor mismatch reads as expanded, so the trigger is not offered.
		expect(
			screen.queryByRole("button", { name: ALERT_BAR_EXPAND_LABEL }),
		).not.toBeInTheDocument()
	})
})

describe("AlertBarTrigger — activating it", () => {
	it("runs onActivate first, then starts the restore flight keyed to the alert", async () => {
		const user = userEvent.setup()
		const seen: string[] = []
		useAlertBarStore.getState().setPhase("minimised", "Scheduling Incomplete")
		renderTrigger({
			onActivate: () => {
				seen.push(`activate:${useAlertBarStore.getState().phase}`)
			},
		})

		await user.click(screen.getByRole("button", { name: ALERT_BAR_EXPAND_LABEL }))

		// onActivate observed the phase BEFORE restore flipped it.
		expect(seen).toEqual(["activate:minimised"])
		expect(useAlertBarStore.getState().phase).toBe("restoring")
		expect(useAlertBarStore.getState().phaseFor).toBe("Scheduling Incomplete")
	})

	it("restores without an onActivate wired", async () => {
		const user = userEvent.setup()
		useAlertBarStore.getState().setPhase("minimised", "Scheduling Incomplete")
		renderTrigger()

		await user.click(screen.getByRole("button", { name: ALERT_BAR_EXPAND_LABEL }))

		expect(useAlertBarStore.getState().phase).toBe("restoring")
	})
})

describe("AlertBarTrigger — the flight anchor", () => {
	it("registers its element in the store under its own placement", () => {
		renderTrigger({ placement: "mobile" })

		const { anchors } = useAlertBarStore.getState()
		expect(anchors.mobile).toBeInstanceOf(HTMLElement)
		expect(anchors.desktop).toBeNull()
	})

	it("a notice-tone alert still renders the same labelled control", () => {
		useAlertBarStore.getState().setPhase("minimised", "Results Available")
		renderTrigger({
			view: alertView({ alertStatus: "Results Available", route: "Exam Detail" }),
		})

		expect(
			screen.getByRole("button", { name: ALERT_BAR_EXPAND_LABEL }),
		).toBeInTheDocument()
	})
})
