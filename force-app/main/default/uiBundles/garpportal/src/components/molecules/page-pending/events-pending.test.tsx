import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { EventsPending } from "./events-pending"

describe("EventsPending", () => {
	it("renders the events page shell with its loading landmark", () => {
		render(<EventsPending />)

		const region = screen.getByLabelText("Loading events")
		expect(region).toHaveAttribute("aria-busy")
		expect(
			screen.getByRole("heading", { level: 1, name: "My Events" }),
		).toBeInTheDocument()
	})
})
