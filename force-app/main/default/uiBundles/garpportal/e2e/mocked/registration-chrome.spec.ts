import { expect, test } from "@playwright/test"

import { examLoad, feesResult } from "@/testing/factories/exam"
import { installMockOrg } from "../support/mock-org"

/**
 * The 2027 guest registration chrome, against the BUILT app.
 *
 * Deliberately thin, and deliberately not a re-run of the component tests:
 * those already assert which wordmark and title each programme gets. What only
 * this layer can catch is that the **artwork actually resolves in `dist/`** —
 * the banner, seal and wordmark are hashed asset imports, so a broken path is
 * a 404 in the built bundle and shows up as a blank band, with nothing a jsdom
 * test could see.
 *
 * The `examreg` fixtures are not incidental: the form reads `load.program.kind`
 * while rendering, so a bare mock org throws before any chrome is on screen.
 */
const orgFixtures = { info: examLoad(), fees: feesResult(600) }

/** Programmes with designed chrome, and the acronym their navbar logo names. */
const REDESIGNED = [
	{ path: "/registration/frm", label: "FRM" },
	{ path: "/registration/scr", label: "SCR" },
	// The legacy marketing address — it must reach the same chrome as /riskai.
	{ path: "/registration/rai", label: "RAI" },
] as const

test.describe("guest registration chrome", () => {
	for (const { path, label } of REDESIGNED) {
		test(`${path} renders its banner and every chrome asset loads`, async ({
			page,
		}) => {
			const failed: string[] = []
			page.on("response", (response) => {
				const url = response.url()
				if (/-(banner|seal|wordmark-(knockout|ink))-/.test(url) && !response.ok()) {
					failed.push(`${response.status()} ${url}`)
				}
			})

			await installMockOrg(page, { identity: "guest", examreg: orgFixtures })
			await page.goto(path)

			// The banner owns the page's h1 on these routes — and only one exists,
			// because the form's sticky bar stands its own title down.
			await expect(page.getByRole("heading", { level: 1 })).toBeVisible()
			await expect(page.getByRole("heading", { level: 1 })).toHaveCount(1)

			// Programme wordmark in the navbar, in place of the GARP mark. The
			// link carries the name — the lockup is two images swapped by theme.
			const header = page.locator("header").first()
			await expect(header.getByRole("link", { name: label })).toBeVisible()
			await expect(header.getByRole("link", { name: "GARP" })).toHaveCount(0)

			// The banner art has to have DECODED, not merely been requested — a
			// 404 still resolves the locator, it just never paints.
			const art = page.locator("main img").first()
			await expect(art).toBeAttached()
			const naturalWidth = await art.evaluate(
				(el) => (el as HTMLImageElement).naturalWidth,
			)
			expect(naturalWidth, `banner art did not decode on ${path}`).toBeGreaterThan(0)

			expect(failed, `chrome assets failed to load on ${path}`).toEqual([])
		})
	}

	/*
	 * The fallback, in the built app. `raij` is a real exam programme that was
	 * deliberately left out of the redesign, so it is the honest check that an
	 * undesigned programme still gets a complete page rather than half of one.
	 */
	test("a programme with no designed chrome keeps the GARP chrome", async ({
		page,
	}) => {
		await installMockOrg(page, { identity: "guest", examreg: orgFixtures })
		await page.goto("/registration/raij")

		// The link carries the name; the GARP mark inside it is decorative.
		const header = page.locator("header").first()
		await expect(header.getByRole("link", { name: "GARP" })).toBeVisible()

		// No banner above the form…
		await expect(page.locator("main img")).toHaveCount(0)
		// …so the form's sticky bar keeps the title, and there is still exactly one.
		await expect(page.getByRole("heading", { level: 1 })).toHaveCount(1)
	})
})
