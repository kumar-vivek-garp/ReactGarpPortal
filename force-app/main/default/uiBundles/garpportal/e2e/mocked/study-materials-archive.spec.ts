import { expect, test } from "@playwright/test"

import type { EBookAccess, MyEBooksView } from "@/api/study-materials/types"
import { installMockOrg } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * The purchased-materials archive (`/study-materials/archive`): `myEBooks`
 * rows render grouped by edition year (newest first), and the Access flow
 * exchanges a vendorId for a signed reader link via `eBookAccess` and opens
 * it. The reader itself is a vendor page, so the assertable parts are the
 * `eBookAccess` hit (with the vendorId) and the popup it opens — the
 * accessURL is pointed at the local static server to keep the run offline.
 */

/**
 * `GET myEBooks` — a MAP keyed by edition year (Apex `Map<Integer, List>`),
 * not a list. 2025 holds one key that resolved to two vendor items; 2024
 * holds a key that resolved to none (owned but unopenable).
 */
function myEBooksData(): MyEBooksView {
	return {
		statusMessage: null,
		statusCode: 200,
		eBooks: {
			"2024": [{ title: "SCR", provider: "Mobius", eBookItems: [] }],
			"2025": [
				{
					title: "FRM",
					provider: "Mobius",
					eBookItems: [
						{ title: "Part I", vendorId: 111 },
						{ title: "Part II", vendorId: 222 },
					],
				},
			],
		},
	}
}

const ACCESS_OK: EBookAccess = {
	statusMessage: null,
	statusCode: 200,
	// Relative => resolves against the e2e static server, never the vendor.
	accessURL: "/e2e-reader-stub",
}

function baseActions(): Record<string, unknown> {
	return { myEBooks: myEBooksData(), programs: programsListData() }
}

test.describe("eBook archive", () => {
	test("purchased eBooks render grouped by edition year, newest first", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: baseActions() })
		await page.goto("/study-materials/archive")

		await expect(
			page.getByRole("heading", {
				name: "Purchased Study Materials",
				level: 1,
			}),
		).toBeVisible()
		await expect(page.getByText("3 titles across 2 editions.")).toBeVisible()

		// Year groups, newest first — the map carries no order of its own.
		const years = page.getByRole("heading", { level: 2 })
		await expect(years).toHaveText(["2025", "2024"])

		// One row per vendor item, labelled key + item. `exact` matters:
		// "FRM — Part I" substring-matches "FRM — Part II" otherwise.
		await expect(page.getByText("FRM — Part I", { exact: true })).toBeVisible()
		await expect(page.getByText("FRM — Part II", { exact: true })).toBeVisible()
		await expect(page.getByRole("button", { name: "Access" })).toHaveCount(2)

		// A key with no vendor items is shown, not hidden — just unopenable.
		// Scoped to main: the nav chrome carries its own "SCR" texts.
		await expect(
			page.getByRole("main").getByText("SCR", { exact: true }),
		).toBeVisible()
		await expect(page.getByText("Not available online")).toBeVisible()

		// Back link into the listing — scoped to main; the sidebar and the
		// footer's per-program garp.org links share the same name.
		await expect(
			page.getByRole("main").getByRole("link", { name: "Study Materials" }),
		).toBeVisible()
		await expect.poll(() => org.hits("myEBooks")).toBe(1)
	})

	test("Access mints a reader link via eBookAccess and opens it", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: { ...baseActions(), eBookAccess: ACCESS_OK },
		})
		await page.goto("/study-materials/archive")
		await expect(page.getByText("FRM — Part I", { exact: true })).toBeVisible()

		const popupPromise = page.waitForEvent("popup")
		// First Access button = first row of the newest group = Part I / 111.
		await page.getByRole("button", { name: "Access" }).first().click()
		const popup = await popupPromise

		await expect.poll(() => org.hits("eBookAccess")).toBe(1)
		const call = org.of("eBookAccess")[0]
		expect(call.method).toBe("GET")
		expect(call.url).toContain("vendorId=111")
		await expect(popup).toHaveURL(/\/e2e-reader-stub/)
	})
})
