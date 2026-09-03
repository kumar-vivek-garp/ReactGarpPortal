import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import {
	NavigationMenu,
	NavigationMenuContent,
	NavigationMenuIndicator,
	NavigationMenuItem,
	NavigationMenuLink,
	NavigationMenuList,
	NavigationMenuTrigger,
	navigationMenuTriggerStyle,
} from "@/components/atoms/navigation-menu"
import { renderWithProviders } from "@/testing/render"

function renderMenu(viewport: boolean) {
	return renderWithProviders(
		<NavigationMenu viewport={viewport} defaultValue="programs">
			<NavigationMenuList>
				<NavigationMenuItem value="programs">
					<NavigationMenuTrigger>Programs</NavigationMenuTrigger>
					<NavigationMenuContent>
						<NavigationMenuLink href="/programs/frm">FRM</NavigationMenuLink>
					</NavigationMenuContent>
				</NavigationMenuItem>
				<NavigationMenuItem value="events">
					<NavigationMenuLink href="/events">Events</NavigationMenuLink>
				</NavigationMenuItem>
				<NavigationMenuIndicator />
			</NavigationMenuList>
		</NavigationMenu>,
	)
}

describe("NavigationMenu", () => {
	it("renders the bar with its trigger, plain links, and open content", () => {
		renderMenu(true)

		expect(
			screen.getByRole("button", { name: /Programs/ }),
		).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Events" })).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "FRM" })).toBeInTheDocument()
	})

	it("also works without the shared viewport", () => {
		renderMenu(false)
		expect(screen.getByRole("link", { name: "FRM" })).toBeInTheDocument()
	})

	it("exposes the trigger style for links that pose as triggers", () => {
		expect(navigationMenuTriggerStyle()).toContain("inline-flex")
	})
})
