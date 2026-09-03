import { fireEvent, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { programsQueryKeys } from "@/api/programs"
import type { ProgramsView } from "@/api/programs/types"
import { TooltipProvider } from "@/components/atoms/tooltip"
import { AppSidebar } from "@/components/organisms/app-sidebar"
import { useSidebarStore } from "@/store/sidebar-store"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

/*
 * vi.mock (not MSW): the pending-selection contract is the `value` handed to
 * `useSlidingIndicator` — its only DOM output is spring-driven geometry, and
 * jsdom measures every row at offset 0, so a claimed row and the resting row
 * are pixel-identical there. The stub records each `value` so the optimistic
 * claim is asserted at the seam the component actually drives.
 */
const rail = vi.hoisted(() => ({
	values: [] as Array<string | null | undefined>,
}))
vi.mock("@/hooks/use-sliding-indicator", () => ({
	useSlidingIndicator: (options: { value: string | null | undefined }) => {
		rail.values.push(options.value)
		return {
			containerRef: { current: null },
			registerRef: () => undefined,
			indicatorStyle: {},
		}
	},
}))

/*
 * Deliberately NO skipSpringAnimations() here. `useSidebarCollapse` hands the
 * rail fresh `to(t, …)` interpolations on every render, and under
 * `skipAnimation` each update settles synchronously and re-notifies — the same
 * runaway loop `testing/springs.ts` warns about for `useSubpageTransition`
 * (verified: with the skip enabled this file spins until the worker dies).
 * Nothing here waits on spring completion, so real springs are harmless.
 */

function member(): CurrentUser {
	return {
		id: "005XX0000000001",
		name: "Ada Lovelace",
		garpId: "654321",
		contactId: "003XX0000000001",
		photoUrl: null,
	}
}

function programsView(hasCPDProgram: boolean): ProgramsView {
	return {
		statusMessage: null,
		statusCode: 200,
		enrolledPrograms: [],
		completedPrograms: [],
		otherPrograms: [],
		hasCPDProgram,
		hasExamResults: false,
		microCourseConfig: null,
	}
}

async function renderSidebar({
	path = "/dashboard",
	user = member() as CurrentUser | null,
	hasCpd = false,
	forceSkeleton = false,
}: {
	path?: string
	user?: CurrentUser | null
	hasCpd?: boolean
	forceSkeleton?: boolean
} = {}) {
	// Seed programs fresh (staleTime 60s) so `useHasCpdProgram` never fetches.
	const queryClient = createTestQueryClient(user)
	queryClient.setQueryData(programsQueryKeys.view, programsView(hasCpd))
	return renderWithRouterProviders(
		<TooltipProvider>
			<AppSidebar forceSkeleton={forceSkeleton} />
		</TooltipProvider>,
		{ path, queryClient },
	)
}

/** The value the indicator was last asked to land on. */
function railValue() {
	return rail.values[rail.values.length - 1]
}

beforeEach(() => {
	rail.values.length = 0
	localStorage.clear()
	useSidebarStore.setState({ isCollapsed: true })
})

describe("AppSidebar — where the rail lands", () => {
	it("lands on the nav row for the current route", async () => {
		await renderSidebar({ path: "/programs" })

		expect(railValue()).toBe("/programs")
	})

	it("lands on the profile row while on /my-account", async () => {
		await renderSidebar({ path: "/my-account" })

		expect(railValue()).toBe("/my-account")
	})

	it("hides the rail while the profile row is a skeleton with nowhere to land", async () => {
		await renderSidebar({ path: "/my-account", forceSkeleton: true })

		expect(railValue()).toBeNull()
		expect(screen.queryByText("Ada Lovelace")).not.toBeInTheDocument()
	})
})

describe("AppSidebar — optimistic pending selection", () => {
	it("claims the pressed row on pointer-down, before the route has changed", async () => {
		const { router } = await renderSidebar({ path: "/dashboard" })
		expect(railValue()).toBe("/dashboard")

		fireEvent.pointerDown(screen.getByRole("link", { name: "Programs" }))

		// The rail is already asked to travel while the URL is still the old one.
		expect(railValue()).toBe("/programs")
		expect(router.state.location.pathname).toBe("/dashboard")
	})

	it("a press on the profile row claims it the same way", async () => {
		await renderSidebar({ path: "/events" })
		expect(railValue()).toBe("/events")

		fireEvent.pointerDown(screen.getByRole("link", { name: /ada lovelace/i }))

		expect(railValue()).toBe("/my-account")
	})
})

describe("AppSidebar — conditional rows and identity", () => {
	it("shows CPD only for members with a CPD programme", async () => {
		const { unmount } = await renderSidebar({ hasCpd: true })
		expect(
			screen.getByRole("link", { name: "CPD Credits" }),
		).toBeInTheDocument()
		unmount()

		await renderSidebar({ hasCpd: false })
		expect(
			screen.queryByRole("link", { name: "CPD Credits" }),
		).not.toBeInTheDocument()
	})

	it("keeps the CPD row while standing on /cpd even without the flag", async () => {
		await renderSidebar({ path: "/cpd", hasCpd: false })

		expect(
			screen.getByRole("link", { name: "CPD Credits" }),
		).toBeInTheDocument()
		expect(railValue()).toBe("/cpd")
	})

	it("renders the member's name and GARP ID, with fallbacks for a bare session", async () => {
		const { unmount } = await renderSidebar()
		expect(screen.getByText("Ada Lovelace")).toBeInTheDocument()
		expect(screen.getByText("(GARP ID 654321)")).toBeInTheDocument()
		unmount()

		await renderSidebar({ user: null })
		expect(screen.getByText("GARP Member")).toBeInTheDocument()
		expect(screen.getByText("(GARP ID —)")).toBeInTheDocument()
	})
})

describe("AppSidebar — collapse toggle", () => {
	it("flips the sidebar store and its own expanded state", async () => {
		const user = userEvent.setup()
		await renderSidebar()

		const toggle = screen.getByRole("button", { name: /expand sidebar/i })
		expect(toggle).toHaveAttribute("aria-expanded", "false")

		await user.click(toggle)

		expect(useSidebarStore.getState().isCollapsed).toBe(false)
		expect(
			screen.getByRole("button", { name: /collapse sidebar/i }),
		).toHaveAttribute("aria-expanded", "true")
	})
})
