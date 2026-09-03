import { fireEvent, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it } from "vitest"

import { alertBarQueryKeys } from "@/api/alert-bar"
import type { AlertBarView } from "@/api/alert-bar/types"
import type { CurrentUser } from "@/api/auth/current-user"
import { programsQueryKeys } from "@/api/programs"
import type { ProgramsView } from "@/api/programs/types"
import { ALERT_BAR_EXPAND_LABEL } from "@/config/alert-bar"
import { MobileNavBar } from "@/components/organisms/mobile-nav-bar"
import { useAlertBarStore } from "@/store/alert-bar-store"
import { useNavigationStore } from "@/store/navigation-store"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

const member: CurrentUser = {
	id: "005XX0000000001",
	name: "Ada Lovelace",
	garpId: "654321",
	contactId: "003XX0000000001",
	photoUrl: null,
}

const programsView: ProgramsView = {
	statusMessage: null,
	statusCode: 200,
	enrolledPrograms: [],
	completedPrograms: [],
	otherPrograms: [],
	hasCPDProgram: false,
	hasExamResults: false,
	microCourseConfig: null,
}

/** A live alert, for the toolbar trigger; null keeps the slot empty. */
function alert(): AlertBarView {
	return {
		statusMessage: null,
		statusCode: 200,
		examType: "FRM",
		examPart: "I",
		alertStatus: "Scheduling Incomplete",
		deadline: null,
		orderId: null,
		route: "Exam Scheduling",
	}
}

async function renderBar({ alertView = null as AlertBarView | null } = {}) {
	const queryClient = createTestQueryClient(member)
	queryClient.setQueryData(programsQueryKeys.view, programsView)
	queryClient.setQueryData(alertBarQueryKeys.view, alertView)
	return renderWithRouterProviders(<MobileNavBar />, { queryClient })
}

const menuButton = (name: RegExp | string) => screen.getByRole("button", { name })

beforeEach(() => {
	useNavigationStore.setState({
		isMobileNavOpen: false,
		mobileSelectedNavItem: null,
		openDesktopNavTitle: null,
		desktopMoreDrillTitle: null,
	})
	useAlertBarStore.setState({
		phase: "expanded",
		phaseFor: null,
		anchors: { desktop: null, mobile: null },
	})
})

describe("MobileNavBar — opening and closing", () => {
	it("starts closed: an Open control and no panel content", async () => {
		await renderBar()

		expect(menuButton("Open menu")).toHaveAttribute("aria-expanded", "false")
		expect(
			screen.queryByRole("heading", { name: "Browse & Explore" }),
		).not.toBeInTheDocument()
	})

	it("opens onto the root panel and relabels the control Close", async () => {
		const user = userEvent.setup()
		await renderBar()

		await user.click(menuButton("Open menu"))

		expect(useNavigationStore.getState().isMobileNavOpen).toBe(true)
		expect(menuButton("Close menu")).toHaveAttribute("aria-expanded", "true")
		expect(
			await screen.findByRole("heading", { name: "Browse & Explore" }),
		).toBeInTheDocument()
	})

	it("the same control closes it again", async () => {
		const user = userEvent.setup()
		await renderBar()

		await user.click(menuButton("Open menu"))
		await user.click(menuButton("Close menu"))

		expect(useNavigationStore.getState().isMobileNavOpen).toBe(false)
		expect(menuButton("Open menu")).toBeInTheDocument()
	})

	it("Escape closes the menu from the root view", async () => {
		const user = userEvent.setup()
		await renderBar()
		await user.click(menuButton("Open menu"))

		fireEvent.keyDown(window, { key: "Escape" })

		expect(useNavigationStore.getState().isMobileNavOpen).toBe(false)
	})

	it("other keys are ignored while open", async () => {
		const user = userEvent.setup()
		await renderBar()
		await user.click(menuButton("Open menu"))

		fireEvent.keyDown(window, { key: "Enter" })

		expect(useNavigationStore.getState().isMobileNavOpen).toBe(true)
	})
})

describe("MobileNavBar — drilling into a garp.org section", () => {
	async function openAndDrill(user: ReturnType<typeof userEvent.setup>) {
		await user.click(menuButton("Open menu"))
		await user.click(await screen.findByRole("button", { name: /^FRM/ }))
	}

	it("pushes the section view with a Back control and the mega-menu links", async () => {
		const user = userEvent.setup()
		await renderBar()

		await openAndDrill(user)

		expect(useNavigationStore.getState().mobileSelectedNavItem?.title).toBe("FRM")
		expect(await screen.findByRole("button", { name: "Back" })).toBeInTheDocument()
		expect(
			await screen.findByRole("link", { name: "Overview" }),
		).toBeInTheDocument()
	})

	it("Back returns to the root view", async () => {
		const user = userEvent.setup()
		await renderBar()
		await openAndDrill(user)

		await user.click(screen.getByRole("button", { name: "Back" }))

		expect(useNavigationStore.getState().mobileSelectedNavItem).toBeNull()
		expect(
			await screen.findByRole("heading", { name: "Browse & Explore" }),
		).toBeInTheDocument()
	})

	it("Escape steps back to the root first, and only then closes", async () => {
		const user = userEvent.setup()
		await renderBar()
		await openAndDrill(user)

		fireEvent.keyDown(window, { key: "Escape" })
		expect(useNavigationStore.getState().isMobileNavOpen).toBe(true)
		expect(useNavigationStore.getState().mobileSelectedNavItem).toBeNull()

		fireEvent.keyDown(window, { key: "Escape" })
		expect(useNavigationStore.getState().isMobileNavOpen).toBe(false)
	})
})

describe("MobileNavBar — the alert trigger in the bar", () => {
	it("restoring the alert from inside the open menu closes the menu first", async () => {
		const user = userEvent.setup()
		useAlertBarStore.getState().setPhase("minimised", "Scheduling Incomplete")
		await renderBar({ alertView: alert() })

		await user.click(menuButton("Open menu"))
		await user.click(
			screen.getByRole("button", { name: ALERT_BAR_EXPAND_LABEL }),
		)

		await waitFor(() => {
			expect(useNavigationStore.getState().isMobileNavOpen).toBe(false)
		})
		expect(useAlertBarStore.getState().phase).toBe("restoring")
	})
})
