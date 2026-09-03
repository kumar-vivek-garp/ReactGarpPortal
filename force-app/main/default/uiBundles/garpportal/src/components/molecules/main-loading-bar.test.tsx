import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { MainLoadingBar } from "@/components/molecules/main-loading-bar"
import { renderWithProviders } from "@/testing/render"

describe("the indeterminate line", () => {
	it("announces itself as busy while visible", () => {
		renderWithProviders(<MainLoadingBar visible />)
		const bar = screen.getByRole("progressbar")
		expect(bar).toHaveAttribute("aria-busy", "true")
		expect(bar).toHaveAttribute("aria-valuetext", "Loading")
	})

	it("renders nothing at all when idle", () => {
		const { container } = renderWithProviders(<MainLoadingBar visible={false} />)
		expect(container).toBeEmptyDOMElement()
	})
})
