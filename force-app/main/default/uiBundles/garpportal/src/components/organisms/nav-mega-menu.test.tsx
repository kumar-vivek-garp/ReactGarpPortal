import { fireEvent, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it } from "vitest"

import { NavMegaMenu } from "@/components/organisms/nav-mega-menu"
import { useNavigationStore } from "@/store/navigation-store"
import { renderWithRouterProviders } from "@/testing/router"
import { skipSpringAnimations } from "@/testing/springs"

/**
 * Springs settle instantly so open/close/switch assertions see the committed
 * state, not a cross-fade. Safe here: nothing in this tree mounts
 * `useSubpageTransition` (see the warning in testing/springs.ts).
 */
skipSpringAnimations()

beforeEach(() => {
	// The zustand store is module-global — a menu left open would leak.
	useNavigationStore.setState({
		openDesktopNavTitle: null,
		desktopMoreDrillTitle: null,
		isMobileNavOpen: false,
		mobileSelectedNavItem: null,
	})
})

const trigger = (name: string) => screen.getByRole("button", { name })
const openTitle = () => useNavigationStore.getState().openDesktopNavTitle

async function renderMenu() {
	return renderWithRouterProviders(<NavMegaMenu />)
}

describe("NavMegaMenu — click state machine", () => {
	it("starts fully closed, with every trigger collapsed", async () => {
		await renderMenu()

		for (const title of ["FRM", "SCR", "Membership", "About Us"]) {
			expect(trigger(title)).toHaveAttribute("aria-expanded", "false")
		}
		// The measuring copies carry the same links but are aria-hidden —
		// nothing menu-shaped is in the accessibility tree while closed.
		expect(
			screen.queryByRole("link", { name: "Overview" }),
		).not.toBeInTheDocument()
	})

	it("opens on click, showing that item's panel", async () => {
		const user = userEvent.setup()
		await renderMenu()

		await user.click(trigger("FRM"))

		expect(trigger("FRM")).toHaveAttribute("aria-expanded", "true")
		expect(
			await screen.findByRole("link", { name: "FRM Certification" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Program and Exams" }),
		).toBeInTheDocument()
	})

	it("switches to a sibling on click rather than closing first", async () => {
		const user = userEvent.setup()
		await renderMenu()

		await user.click(trigger("FRM"))
		await user.click(trigger("SCR"))

		expect(trigger("FRM")).toHaveAttribute("aria-expanded", "false")
		expect(trigger("SCR")).toHaveAttribute("aria-expanded", "true")
		expect(
			await screen.findByRole("link", { name: "SCR Certificate" }),
		).toBeInTheDocument()
		// The outgoing FRM layer is gone once the cross-fade settles.
		await waitFor(() => {
			expect(
				screen.queryByRole("link", { name: "FRM Certification" }),
			).not.toBeInTheDocument()
		})
	})

	it("closes when the open trigger is clicked again", async () => {
		const user = userEvent.setup()
		await renderMenu()

		await user.click(trigger("FRM"))
		await user.click(trigger("FRM"))

		expect(openTitle()).toBeNull()
		expect(trigger("FRM")).toHaveAttribute("aria-expanded", "false")
		await waitFor(() => {
			expect(
				screen.queryByRole("link", { name: "FRM Certification" }),
			).not.toBeInTheDocument()
		})
	})
})

describe("NavMegaMenu — dismissal", () => {
	it("closes on Escape and hands focus back to the trigger", async () => {
		const user = userEvent.setup()
		await renderMenu()

		await user.click(trigger("FRM"))
		await user.keyboard("{Escape}")

		expect(openTitle()).toBeNull()
		expect(trigger("FRM")).toHaveFocus()
	})

	it("closes on a pointerdown anywhere outside the row and panel", async () => {
		const user = userEvent.setup()
		await renderMenu()

		await user.click(trigger("SCR"))
		expect(openTitle()).toBe("SCR")

		fireEvent.pointerDown(document.body)
		expect(openTitle()).toBeNull()
	})

	it("stays open for a pointerdown inside the panel", async () => {
		const user = userEvent.setup()
		await renderMenu()

		await user.click(trigger("SCR"))
		const link = await screen.findByRole("link", { name: "SCR Certificate" })

		fireEvent.pointerDown(link)
		expect(openTitle()).toBe("SCR")
	})
})

describe("NavMegaMenu — keyboard", () => {
	it("moves focus along the row with arrows, without opening anything while closed", async () => {
		await renderMenu()

		trigger("FRM").focus()
		fireEvent.keyDown(trigger("FRM"), { key: "ArrowRight" })

		expect(trigger("SCR")).toHaveFocus()
		expect(openTitle()).toBeNull()

		// Wraps around the far end going left.
		fireEvent.keyDown(trigger("SCR"), { key: "ArrowLeft" })
		fireEvent.keyDown(trigger("FRM"), { key: "ArrowLeft" })
		expect(trigger("About Us")).toHaveFocus()
	})

	it("follows the focus with the open panel once a menu is already open", async () => {
		const user = userEvent.setup()
		await renderMenu()

		await user.click(trigger("FRM"))
		fireEvent.keyDown(trigger("FRM"), { key: "ArrowRight" })

		expect(openTitle()).toBe("SCR")
		expect(trigger("SCR")).toHaveFocus()
	})

	it("ArrowDown opens the panel and drops focus into its first link", async () => {
		await renderMenu()

		trigger("FRM").focus()
		fireEvent.keyDown(trigger("FRM"), { key: "ArrowDown" })

		expect(openTitle()).toBe("FRM")
		// Focus lands a frame later, scoped to the ENTERING layer.
		await waitFor(() => {
			const active = document.activeElement
			expect(active?.tagName).toBe("A")
			expect(active).toHaveAccessibleName("FRM Certification")
		})
	})
})
