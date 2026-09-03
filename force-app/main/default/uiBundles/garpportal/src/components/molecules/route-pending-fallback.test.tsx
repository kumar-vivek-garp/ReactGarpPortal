import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import {
	AppRoutePending,
	AuthRoutePending,
	BootSplashScreen,
} from "./route-pending-fallback"

describe("BootSplashScreen", () => {
	it("announces itself as a busy loading status", () => {
		render(<BootSplashScreen />)

		const status = screen.getByRole("status")
		expect(status).toHaveAttribute("aria-busy", "true")
		expect(status).toHaveAccessibleName("Loading GARP")
	})

	it("is the same shell for the app and auth layout pending slots", () => {
		// Both layouts must show pixel-identical waits — the aliases existing
		// as *the same component* is what guarantees that.
		expect(AppRoutePending).toBe(BootSplashScreen)
		expect(AuthRoutePending).toBe(BootSplashScreen)
	})
})
