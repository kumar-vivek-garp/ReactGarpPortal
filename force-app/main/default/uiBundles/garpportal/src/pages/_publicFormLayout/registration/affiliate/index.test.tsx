import { screen } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { Route } from "./index"

/*
 * vi.mock (not MSW): the affiliate panel is deep-tested by its own suite —
 * this page only mounts it, so a stub proves the wiring without dragging the
 * affiliate load contract through MSW.
 */
vi.mock("@/components/forms/affiliate/affiliate-registration-panel", () => ({
	AffiliateRegistrationPanel: () => <p>affiliate panel</p>,
}))

describe("/registration/affiliate page", () => {
	it("serves the sign-up panel to a guest at its own address", async () => {
		const { router } = await renderFileRoute(Route, {
			id: "/_publicFormLayout/registration/affiliate/",
			path: "/registration/affiliate/",
			initialEntries: ["/registration/affiliate"],
			user: null,
		})

		expect(screen.getByText("affiliate panel")).toBeInTheDocument()
		expect(router.state.location.pathname).toBe("/registration/affiliate")
	})
})
