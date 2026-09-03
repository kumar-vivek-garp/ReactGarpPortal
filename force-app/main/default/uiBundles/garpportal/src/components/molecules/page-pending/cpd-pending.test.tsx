import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { CPD_PAGE_TITLE } from "@/config/cpd"

import { CpdPending } from "./cpd-pending"

describe("CpdPending", () => {
	it("keeps the real page title over the loading body", () => {
		render(<CpdPending />)

		expect(
			screen.getByRole("heading", { level: 1, name: CPD_PAGE_TITLE }),
		).toBeInTheDocument()
		expect(screen.getByLabelText("Loading CPD credits")).toHaveAttribute(
			"aria-busy",
		)
	})
})
