import { expect, test } from "@playwright/test"

import { examLoad, feesResult } from "@/testing/factories/exam"
import { installMockOrg } from "../support/mock-org"

/**
 * Programme identity on the SIGNED-IN bar, against the BUILT app.
 *
 * The component tests already assert which seal and wash each programme gets.
 * What only this layer can show is the whole bar resolved together: that the
 * wash composites over an opaque base, that the seal asset actually loads out
 * of `dist/`, and — the one with teeth — that adding a seal did not change the
 * bar's height. `REGISTRATION_RAIL_COLUMN`'s `lg:top-28` is derived from that
 * 5.5rem, so a taller bar silently unpins the order rail on every page.
 *
 * Deep links 404 against the static server, so each route is reached by client
 * navigation from the dashboard — the way a member reaches it anyway.
 */
const orgFixtures = { info: examLoad(), fees: feesResult(600) }

const REDESIGNED = [
	{ path: "/programs/frm/register", seal: "frm-seal", hue: "garp-cyan" },
	{ path: "/programs/scr/register", seal: "scr-seal", hue: "garp-saffron" },
	{ path: "/programs/riskai/register", seal: "rai-seal", hue: "rai-orange" },
] as const

/** Client-side navigation; the static server has no deep-link fallback. */
async function goTo(page: import("@playwright/test").Page, path: string) {
	await page.evaluate((p) => {
		history.pushState({}, "", p)
		window.dispatchEvent(new PopStateEvent("popstate"))
	}, path)
	await page.waitForTimeout(1500)
}

test.describe("member registration bar identity", () => {
	for (const { path, seal, hue } of REDESIGNED) {
		test(`${path} wears its seal and brand wash`, async ({ page }) => {
			await installMockOrg(page, { examreg: orgFixtures })
			await page.goto("/dashboard")
			await goTo(page, path)

			const bar = page.locator("div.sticky").first()
			await expect(bar).toBeVisible()

			// The wash is that programme's hue, and it sits over an OPAQUE base —
			// cards scroll under this bar.
			await expect(bar).toHaveClass(new RegExp(`from-${hue}/12`))
			await expect(bar).toHaveClass(/bg-background/)

			// The seal resolves out of dist/ and decodes; it is decoration, so the
			// h1 beside it is the only thing that names the programme.
			const img = bar.locator("img").first()
			await expect(img).toHaveAttribute("alt", "")
			expect(await img.getAttribute("src")).toContain(seal)
			expect(
				await img.evaluate((el) => (el as HTMLImageElement).naturalWidth),
				`the ${seal} asset did not load`,
			).toBeGreaterThan(0)

			await expect(page.getByRole("heading", { level: 1 })).toHaveCount(1)

			// 5.5rem, unchanged by the seal — see the note above.
			const height = await bar.evaluate((el) =>
				Math.round(el.getBoundingClientRect().height),
			)
			expect(height, "the seal must not grow the bar").toBe(88)

			// The GARP logo stays in the navbar; only the bar gained identity.
			await expect(
				page.locator("header").first().getByRole("img", { name: "GARP" }),
			).toBeVisible()
		})
	}

	test("a programme with no designed chrome keeps the plain bar", async ({
		page,
	}) => {
		await installMockOrg(page, { examreg: orgFixtures })
		await page.goto("/dashboard")
		await goTo(page, "/programs/raij/register")

		const bar = page.locator("div.sticky").first()
		await expect(bar).toBeVisible()
		await expect(bar).not.toHaveClass(/from-/)
		await expect(bar.locator("img")).toHaveCount(0)
		await expect(page.getByRole("heading", { level: 1 })).toHaveCount(1)
	})

	/* Exam Setup is literally the same bar, so it carries the same identity. */
	test("the exam setup bar matches its registration bar", async ({ page }) => {
		await installMockOrg(page, { examreg: orgFixtures })
		await page.goto("/dashboard")
		await goTo(page, "/programs/frm/exam-setup")

		const bar = page.locator("div.sticky").first()
		await expect(bar).toBeVisible()
		await expect(bar).toHaveClass(/from-garp-cyan\/12/)
		expect(await bar.locator("img").first().getAttribute("src")).toContain(
			"frm-seal",
		)
	})
})
