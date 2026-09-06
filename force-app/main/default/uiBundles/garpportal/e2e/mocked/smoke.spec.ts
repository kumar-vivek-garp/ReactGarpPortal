import { expect, test } from "@playwright/test"

import { installMockOrg } from "../support/mock-org"

/**
 * Boot smoke for the BUILT app (dist/, served statically): the load-bearing
 * routing/guard/theming contracts hold in a real browser. Module-level
 * journeys live in the sibling specs; this file stays the thin floor.
 */

test.describe("boot and auth wall", () => {
	test("a guest hitting the app is walled off at Login", async ({ page }) => {
		await installMockOrg(page, { identity: "guest" })
		await page.goto("/")
		await expect(page).toHaveURL(/\/Login/)
	})

	test("a member lands on the dashboard with the app chrome", async ({
		page,
	}) => {
		await installMockOrg(page)
		await page.goto("/")
		await expect(page).toHaveURL(/\/dashboard$/)
		await expect(page.locator("header").first()).toBeVisible()
		await expect(page.locator("#boot-splash")).not.toBeVisible()
	})

	test("client-side navigation reaches Programs", async ({ page }) => {
		await installMockOrg(page)
		await page.goto("/dashboard")
		await page.locator('a[href="/programs"]').first().click()
		await expect(page).toHaveURL(/\/programs$/)
	})

	test("an unknown path renders the 404 page", async ({ page }) => {
		await installMockOrg(page)
		await page.goto("/this-page-does-not-exist")
		await expect(
			page.getByRole("heading", { name: "Page not found" }),
		).toBeVisible()
	})
})

test.describe("registration guards", () => {
	test("a guest deep-linking the member form lands on its public twin, code intact", async ({
		page,
	}) => {
		await installMockOrg(page, { identity: "guest" })
		await page.goto("/programs/frm/register?regCode=TEAM24")
		await expect(page).toHaveURL(/\/registration\/frm/)
		expect(page.url()).toContain("regCode=TEAM24")
	})

	test("a guest payment return keeps its params through the public-twin bounce", async ({
		page,
	}) => {
		await installMockOrg(page, { identity: "guest" })
		await page.goto("/programs/frm/register?stripe_return=1&oid=801&on=1234")
		// The guard sends a guest to the public twin WITH search preserved —
		// dropping oid/on here would blank a confirmation for a charged order.
		await expect(page).toHaveURL(/\/registration\/frm/)
		expect(page.url()).toContain("stripe_return")
		expect(page.url()).toContain("801")
	})

	test("the public form route serves a guest under its own chrome", async ({
		page,
	}) => {
		await installMockOrg(page, { identity: "guest" })
		await page.goto("/registration/affiliate")
		await expect(page).toHaveURL(/\/registration\/affiliate/)
		await expect(page.locator("header").first()).toBeVisible()
	})
})

test.describe("theming", () => {
	test("system dark scheme yields the dark theme", async ({ page }) => {
		await installMockOrg(page)
		await page.emulateMedia({ colorScheme: "dark" })
		await page.goto("/dashboard")
		await expect(page.locator("html")).toHaveClass(/dark/)
	})

	test("system light scheme yields the light theme", async ({ page }) => {
		await installMockOrg(page)
		await page.emulateMedia({ colorScheme: "light" })
		await page.goto("/dashboard")
		await expect(page.locator("html")).not.toHaveClass(/dark/)
	})
})
