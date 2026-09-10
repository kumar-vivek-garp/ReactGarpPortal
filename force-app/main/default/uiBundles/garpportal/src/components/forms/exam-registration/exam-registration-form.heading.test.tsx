import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { feesResult } from "@/testing/factories/exam"
import { EXAM_PROGRAMS } from "@/config/registration"
import { renderExamForm } from "@/testing/exam-registration-ui"
import { examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"

function armFees(total = 100) {
	const fees = examregPost("fees", () => feesResult(total))
	server.use(fees.handler)
	return fees
}

/**
 * Exactly one `h1`, on either route.
 *
 * The 2027 Reg Redesign moved the guest title into the shell's programme
 * banner, so the sticky bar stands its own copy down (`titleInBanner`). Both
 * ways of getting that wrong are silent in a browser and cost real
 * accessibility: leave the bar title in and the guest page has two `h1`s;
 * default the flag the other way and the MEMBER page — which has no banner —
 * has none at all.
 */
describe("ExamRegistrationForm — the page heading", () => {
	it("titles the sticky bar when no banner is above it", async () => {
		armFees()
		await renderExamForm()

		const headings = screen.getAllByRole("heading", { level: 1 })
		expect(headings).toHaveLength(1)
		expect(headings[0]).toHaveTextContent(
			"Financial Risk Manager (FRM®) Exam Registration",
		)
	})

	it("stands its title down when the banner already carries it", async () => {
		armFees()
		await renderExamForm({
			profile: null,
			isAuthenticated: false,
			titleInBanner: true,
		})

		expect(screen.queryByRole("heading", { level: 1 })).not.toBeInTheDocument()
		// The commitment and its price stay — only the title left the bar.
		expect(
			screen.getByRole("button", { name: /Register|Pay/ }),
		).toBeInTheDocument()
	})

	/*
	 * The member bar carries the programme's identity: seal beside the title,
	 * brand wash on the bar. Both come from the same record the guest banner
	 * uses, so the two audiences cannot disagree about what colour a programme
	 * is.
	 */
	it("wears the programme's seal and wash on the member bar", async () => {
		armFees()
		const { container } = await renderExamForm()

		const bar = container.querySelector("form > div.sticky")
		expect(bar?.className).toContain("from-garp-cyan/12")
		// Opaque base is kept: the wash is a background-image over it, and cards
		// scroll under this bar.
		expect(bar?.className).toContain("bg-background")

		const seal = bar?.querySelector("img")
		expect(seal).toBeTruthy()
		// Decorative — the h1 beside it already names the programme.
		expect(seal).toHaveAttribute("alt", "")
	})

	/*
	 * The fallback: a programme with no designed chrome keeps the plain bar,
	 * exactly as the guest pages do.
	 */
	it("leaves the bar plain for a programme with no chrome", async () => {
		armFees()
		const { container } = await renderExamForm({
			program: EXAM_PROGRAMS.raij,
			programType: "raij",
		})

		const bar = container.querySelector("form > div.sticky")
		expect(bar?.className).not.toContain("from-")
		expect(bar?.querySelector("img")).toBeNull()
		expect(screen.getAllByRole("heading", { level: 1 })).toHaveLength(1)
	})

	/*
	 * A member CAN reach the public route: the guard suppresses its redirect on
	 * a payment return. The back link has to survive that, so the title group
	 * is dropped only when it would be empty.
	 */
	it("keeps a member's back link on the banner route", async () => {
		armFees()
		await renderExamForm({ titleInBanner: true })

		expect(screen.queryByRole("heading", { level: 1 })).not.toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Programs" })).toBeInTheDocument()
	})
})
