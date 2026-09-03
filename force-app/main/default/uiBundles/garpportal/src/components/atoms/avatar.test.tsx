import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import {
	Avatar,
	AvatarBadge,
	AvatarFallback,
	AvatarGroup,
	AvatarGroupCount,
	AvatarImage,
} from "@/components/atoms/avatar"
import { renderWithProviders } from "@/testing/render"

describe("Avatar", () => {
	it("shows the fallback while no image has loaded", () => {
		renderWithProviders(
			<Avatar>
				<AvatarImage src="/grace.png" alt="Grace Hopper" />
				<AvatarFallback>GH</AvatarFallback>
			</Avatar>,
		)
		// jsdom never loads images, so the initials carry the identity.
		expect(screen.getByText("GH")).toBeInTheDocument()
	})

	it("carries its size and an optional status badge", () => {
		renderWithProviders(
			<Avatar size="lg" data-testid="avatar">
				<AvatarFallback>GH</AvatarFallback>
				<AvatarBadge aria-label="Online" />
			</Avatar>,
		)
		expect(screen.getByTestId("avatar")).toHaveAttribute("data-size", "lg")
		expect(screen.getByLabelText("Online")).toBeInTheDocument()
	})

	it("groups avatars with an overflow count", () => {
		renderWithProviders(
			<AvatarGroup>
				<Avatar size="sm">
					<AvatarFallback>GH</AvatarFallback>
				</Avatar>
				<Avatar size="sm">
					<AvatarFallback>AL</AvatarFallback>
				</Avatar>
				<AvatarGroupCount>+3</AvatarGroupCount>
			</AvatarGroup>,
		)
		expect(screen.getByText("GH")).toBeInTheDocument()
		expect(screen.getByText("AL")).toBeInTheDocument()
		expect(screen.getByText("+3")).toBeInTheDocument()
	})
})
