import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { WorkExperiencePending } from "./work-experience-pending"

describe("WorkExperiencePending", () => {
	it("renders the work experience shell with its loading landmark", () => {
		render(<WorkExperiencePending />)

		expect(screen.getByLabelText("Loading work experience")).toHaveAttribute(
			"aria-busy",
		)
	})
})
