import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import {
	REGISTRATION_GRID,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"

import {
	StudyMaterialPurchasePending,
	StudyMaterialPurchaseSkeleton,
} from "./study-material-purchase-pending"

describe("StudyMaterialPurchaseSkeleton", () => {
	it("announces itself as busy with a label", () => {
		render(<StudyMaterialPurchaseSkeleton />)
		expect(screen.getByLabelText("Loading your purchase")).toHaveAttribute("aria-busy")
	})

	it("mirrors the form's bar and checkout grid so nothing shifts on arrival", () => {
		render(<StudyMaterialPurchaseSkeleton />)
		const wrapper = screen.getByLabelText("Loading your purchase")
		expect(wrapper.children[0]).toHaveClass(...REGISTRATION_STICKY_BAR.split(" "))
		expect(wrapper.children[1]).toHaveClass(...REGISTRATION_GRID.split(" "))
	})
})

describe("StudyMaterialPurchasePending", () => {
	it("renders the skeleton inside the registration shell", () => {
		render(<StudyMaterialPurchasePending />)
		expect(screen.getByLabelText("Loading your purchase")).toBeInTheDocument()
	})
})
