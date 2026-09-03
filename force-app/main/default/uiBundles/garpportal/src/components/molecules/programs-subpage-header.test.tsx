import { fireEvent, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { renderWithRouterProviders } from "@/testing/router"

describe("where back goes", () => {
	it("defaults to the programs listing", async () => {
		await renderWithRouterProviders(<ProgramsSubpageHeader />)
		expect(screen.getByRole("link", { name: "Programs" })).toHaveAttribute(
			"href",
			"/programs",
		)
	})

	it("returns a program-scoped subpage to its own detail, uppercasing the type", async () => {
		await renderWithRouterProviders(
			<ProgramsSubpageHeader back={{ kind: "program", programType: "frm" }} />,
		)
		expect(screen.getByRole("link", { name: "FRM" })).toHaveAttribute(
			"href",
			"/programs/frm",
		)
	})

	it("prefers the explicit label over the derived one", async () => {
		await renderWithRouterProviders(
			<ProgramsSubpageHeader
				back={{ kind: "program", programType: "frm", label: "Back to FRM" }}
			/>,
		)
		expect(screen.getByRole("link", { name: "Back to FRM" })).toBeInTheDocument()
	})

	it("sends study-material subpages back to the listing's default tab", async () => {
		await renderWithRouterProviders(
			<ProgramsSubpageHeader back={{ kind: "studyMaterials" }} />,
		)
		const link = screen.getByRole("link", { name: "Study Materials" })
		expect(link.getAttribute("href")).toContain("/study-materials")
		expect(link.getAttribute("href")).toContain("tab=")
	})

	it("sends event subpages back to /events", async () => {
		await renderWithRouterProviders(
			<ProgramsSubpageHeader back={{ kind: "events" }} />,
		)
		expect(screen.getByRole("link", { name: "Events" })).toHaveAttribute(
			"href",
			"/events",
		)
	})
})

describe("the exit-animation intercept", () => {
	it("holds the navigation until the page hands it back", async () => {
		const user = userEvent.setup()
		const onNavigateBack = vi.fn<(run: () => void) => void>()
		const { router } = await renderWithRouterProviders(
			<ProgramsSubpageHeader onNavigateBack={onNavigateBack} />,
			{ path: "/programs/frm/results", initialEntries: ["/programs/frm/results"] },
		)

		await user.click(screen.getByRole("link", { name: "Programs" }))
		expect(onNavigateBack).toHaveBeenCalledTimes(1)
		// Not yet — the exit animation is still playing.
		expect(router.state.location.pathname).toBe("/programs/frm/results")

		onNavigateBack.mock.calls[0][0]()
		await waitFor(() => {
			expect(router.state.location.pathname).toBe("/programs")
		})
	})

	it("leaves a modified click to the browser — open-in-new-tab must work", async () => {
		const onNavigateBack = vi.fn()
		await renderWithRouterProviders(
			<ProgramsSubpageHeader onNavigateBack={onNavigateBack} />,
		)

		fireEvent.click(screen.getByRole("link", { name: "Programs" }), {
			ctrlKey: true,
		})
		expect(onNavigateBack).not.toHaveBeenCalled()
	})

	it("intercepts every back kind, not just the listing", async () => {
		const user = userEvent.setup()
		for (const [back, target] of [
			[{ kind: "program", programType: "frm" }, "/programs/frm"],
			[{ kind: "studyMaterials" }, "/study-materials"],
			[{ kind: "events" }, "/events"],
		] as const) {
			const onNavigateBack = vi.fn<(run: () => void) => void>()
			const { router, unmount } = await renderWithRouterProviders(
				<ProgramsSubpageHeader back={back} onNavigateBack={onNavigateBack} />,
				{ path: "/somewhere", initialEntries: ["/somewhere"] },
			)

			await user.click(screen.getByRole("link"))
			expect(onNavigateBack).toHaveBeenCalledTimes(1)
			expect(router.state.location.pathname).toBe("/somewhere")

			onNavigateBack.mock.calls[0][0]()
			await waitFor(() => {
				expect(router.state.location.pathname).toBe(target)
			})
			unmount()
		}
	})

	it("navigates directly when no animation is registered", async () => {
		const user = userEvent.setup()
		const { router } = await renderWithRouterProviders(
			<ProgramsSubpageHeader />,
			{ path: "/programs/frm/results", initialEntries: ["/programs/frm/results"] },
		)

		await user.click(screen.getByRole("link", { name: "Programs" }))
		await waitFor(() => {
			expect(router.state.location.pathname).toBe("/programs")
		})
	})
})

describe("the optional title", () => {
	it("renders the h1 only when given one — the hero may own it", async () => {
		const { unmount } = await renderWithRouterProviders(
			<ProgramsSubpageHeader title="Exam Results" />,
		)
		expect(
			screen.getByRole("heading", { level: 1, name: "Exam Results" }),
		).toBeInTheDocument()
		unmount()

		await renderWithRouterProviders(<ProgramsSubpageHeader />)
		expect(screen.queryByRole("heading")).not.toBeInTheDocument()
	})

	it("keeps the collapsed mobile back link accessibly named", async () => {
		await renderWithRouterProviders(
			<ProgramsSubpageHeader iconOnlyBackOnMobile />,
		)
		expect(screen.getByRole("link", { name: "Programs" })).toBeInTheDocument()
	})
})
