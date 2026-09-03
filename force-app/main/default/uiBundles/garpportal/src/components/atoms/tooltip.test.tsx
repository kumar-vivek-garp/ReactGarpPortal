import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import {
	Tooltip,
	TooltipContent,
	TooltipProvider,
	TooltipTrigger,
} from "@/components/atoms/tooltip"
import { renderWithProviders } from "@/testing/render"

function renderTooltip(open: boolean) {
	return renderWithProviders(
		<TooltipProvider>
			<Tooltip open={open}>
				<TooltipTrigger>Programs</TooltipTrigger>
				<TooltipContent>All certification programs</TooltipContent>
			</Tooltip>
		</TooltipProvider>,
	)
}

describe("Tooltip", () => {
	it("stays hidden until opened", () => {
		renderTooltip(false)
		expect(screen.queryByRole("tooltip")).not.toBeInTheDocument()
	})

	it("shows the animated label panel when open", () => {
		renderTooltip(true)
		expect(screen.getByRole("tooltip")).toBeInTheDocument()
		// The visible panel plus Radix's screen-reader copy both carry the text.
		expect(
			screen.getAllByText("All certification programs").length,
		).toBeGreaterThan(0)
	})
})
