import { Link, useLocation } from "@tanstack/react-router"
import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import { renderWithRouterProviders } from "@/testing/router"

/** Self-test for the harness every Phase 4+ component test leans on. */
function Probe() {
	const location = useLocation()
	return (
		<div>
			<p>at {location.pathname}</p>
			<p>code {String(location.search.regCode ?? "none")}</p>
			<Link to="/dashboard">Dashboard</Link>
		</div>
	)
}

describe("renderWithRouterProviders", () => {
	it("mounts the UI at the given path with parsed search", async () => {
		await renderWithRouterProviders(<Probe />, {
			path: "/programs/$programType/register",
			initialEntries: ["/programs/frm/register?regCode=TEAM24"],
		})
		expect(
			screen.getByText("at /programs/frm/register"),
		).toBeInTheDocument()
		expect(screen.getByText("code TEAM24")).toBeInTheDocument()
	})

	it("gives Link a real resolved href and navigates on click", async () => {
		const { router } = await renderWithRouterProviders(<Probe />)
		const link = screen.getByRole("link", { name: "Dashboard" })
		expect(link).toHaveAttribute("href", "/dashboard")

		await userEvent.click(link)
		expect(router.state.location.pathname).toBe("/dashboard")
	})
})
