import { screen, within } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { Route } from "./route"

/** Mounts the layout at a concrete public path so the shell can derive chrome. */
async function renderAt(pathname: string) {
	return renderFileRoute(Route, {
		id: "/_publicFormLayout",
		path: "/registration/$programType",
		initialEntries: [pathname],
		user: null,
	})
}

describe("_publicFormLayout", () => {
	it("wraps its outlet in the public shell's chrome", async () => {
		await renderFileRoute(Route, {
			id: "/_publicFormLayout",
			path: "/",
			initialEntries: ["/"],
			user: null,
		})

		expect(screen.getByRole("banner")).toBeInTheDocument()
		expect(screen.getByRole("main")).toBeInTheDocument()
		expect(screen.getByRole("contentinfo")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Sign In/ })).toBeInTheDocument()
	})

	/*
	 * The guest chrome is per-programme (2027 Reg Redesign): the shell derives
	 * it from the pathname, because it is an ancestor of the route that owns
	 * `$programType` and cannot read the param.
	 */
	describe("per-programme chrome", () => {
		it.each([
			["/registration/frm", "FRM", "Financial Risk Manager (FRM®) Exam Registration"],
			[
				"/registration/scr",
				"SCR",
				"Sustainability and Climate Risk (SCR®) Exam Registration",
			],
			["/registration/riskai", "RAI", "Risk and AI (RAI™) Exam Registration"],
			// The legacy marketing address must land on the same chrome.
			["/registration/rai", "RAI", "Risk and AI (RAI™) Exam Registration"],
		])("dresses %s in its own chrome", async (path, label, title) => {
			await renderAt(path)

			// The banner owns the page's h1; the form's sticky bar stands down.
			expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(title)

			/*
			 * The LINK carries the name, not the images: the lockup is two `<img>`s
			 * swapped by theme, so naming both would expose the programme twice
			 * depending on the mode. Scoped to the header because the footer keeps
			 * the GARP mark on every guest page.
			 */
			const header = within(screen.getByRole("banner"))
			expect(header.getByRole("link", { name: label })).toBeInTheDocument()
			expect(header.queryByRole("link", { name: "GARP" })).not.toBeInTheDocument()
		})

		/*
		 * The fallback is the contract, not a gap — it is what keeps the guest
		 * 404, affiliate, and every programme with no Figma frame on the existing
		 * look rather than painting them half-redesigned. `raij` is the live
		 * example: a real exam programme, deliberately deferred.
		 */
		it.each([
			["/registration/raij"],
			["/registration/affiliate"],
			["/registration/micro"],
		])("keeps the GARP chrome and shows no banner on %s", async (path) => {
			await renderAt(path)

			expect(
				within(screen.getByRole("banner")).getByRole("link", { name: "GARP" }),
			).toBeInTheDocument()
			// No banner means no h1 from the shell — the form supplies its own.
			expect(screen.queryByRole("heading", { level: 1 })).not.toBeInTheDocument()
		})
	})
})
