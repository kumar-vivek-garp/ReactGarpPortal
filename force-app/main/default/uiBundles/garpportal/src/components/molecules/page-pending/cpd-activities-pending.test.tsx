import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { CPD_ACTIVITIES_TITLE } from "@/config/cpd"

import { CpdActivitiesPending } from "./cpd-activities-pending"

describe("CpdActivitiesPending", () => {
	it("keeps the real page title over the loading body", () => {
		render(<CpdActivitiesPending />)

		expect(
			screen.getByRole("heading", { level: 1, name: CPD_ACTIVITIES_TITLE }),
		).toBeInTheDocument()
		expect(
			screen.getByLabelText("Loading credit opportunities"),
		).toHaveAttribute("aria-busy")
	})
})
