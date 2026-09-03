import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { ExamSetupPending } from "./exam-setup-pending"

describe("ExamSetupPending", () => {
	it("renders the exam setup shell with its loading landmark", () => {
		render(<ExamSetupPending />)

		expect(screen.getByLabelText("Loading exam setup")).toHaveAttribute(
			"aria-busy",
		)
	})
})
