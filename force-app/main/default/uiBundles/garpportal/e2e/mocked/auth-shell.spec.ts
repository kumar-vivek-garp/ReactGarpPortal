import { expect, test } from "@playwright/test"

import { installMockOrg } from "../support/mock-org"

/**
 * The auth shell: /Login for both audiences, sign-out, and the session-aware
 * 404. Expectations come from the real sources, not the brief:
 * - `_authLayout/route.tsx` bounces a member off /Login to
 *   `getSafeStartUrl(startUrl)` (default /dashboard; `isSafeStartUrl` rejects
 *   `//host` and absolute URLs — src/auth/start-url.ts).
 * - `src/auth/logout.ts` on localhost sets the local-logout flag and
 *   `location.replace(LOGIN_PATH)` — asserted here by URL/visible outcome only.
 * - `__root.tsx` notFoundComponent (NotFoundPage) is session-aware: member →
 *   AppLayoutShell chrome, guest → PublicShell with Sign In.
 */

test.describe("/Login", () => {
	test("a guest gets the sign-in form", async ({ page }) => {
		await installMockOrg(page, { identity: "guest" })
		await page.goto("/Login")
		await expect(page).toHaveURL(/\/Login/)
		await expect(page.getByRole("button", { name: "Sign In" })).toBeVisible()
	})

	test("a member visiting /Login is bounced to the dashboard", async ({
		page,
	}) => {
		await installMockOrg(page)
		await page.goto("/Login")
		await expect(page).toHaveURL(/\/dashboard$/)
	})

	test("the member bounce honors a safe startUrl", async ({ page }) => {
		await installMockOrg(page)
		await page.goto("/Login?startUrl=%2Fprograms")
		await expect(page).toHaveURL(/\/programs$/)
	})

	// Open-redirect probes — isSafeStartUrl rejects protocol-relative and
	// absolute URLs, so the bounce falls back to the dashboard.
	for (const unsafe of ["//evil.test", "https://evil.test/phish"]) {
		test(`an unsafe startUrl (${unsafe}) falls back to the dashboard`, async ({
			page,
		}) => {
			await installMockOrg(page)
			await page.goto(`/Login?startUrl=${encodeURIComponent(unsafe)}`)
			await expect(page).toHaveURL(/\/dashboard$/)
		})
	}
})

test.describe("sign out", () => {
	test("a member signing out lands on /Login and stays walled off", async ({
		page,
	}) => {
		await installMockOrg(page)
		await page.goto("/dashboard")
		await page.getByRole("button", { name: "Sign Out" }).click()
		await expect(page).toHaveURL(/\/Login/)
		await expect(page.getByRole("button", { name: "Sign In" })).toBeVisible()

		// The local session really ended: the portal is a wall again.
		await page.goto("/dashboard")
		await expect(page).toHaveURL(/\/Login/)
	})
})

test.describe("404 in both chromes", () => {
	test("a member gets the styled 404 inside the portal chrome", async ({
		page,
	}) => {
		await installMockOrg(page)
		await page.goto("/this-page-does-not-exist")
		await expect(
			page.getByRole("heading", { name: "Page not found" }),
		).toBeVisible()
		// Portal chrome, not the public shell: toolbar with Sign Out, and the
		// member variant's way forward.
		await expect(page.locator("header").first()).toBeVisible()
		await expect(page.getByRole("button", { name: "Sign Out" })).toBeVisible()
		await expect(
			page.getByRole("link", { name: "Go to Dashboard" }),
		).toBeVisible()
	})

	test("a guest gets the 404 under the public chrome with Sign In", async ({
		page,
	}) => {
		await installMockOrg(page, { identity: "guest" })
		await page.goto("/this-page-does-not-exist")
		await expect(
			page.getByRole("heading", { name: "Page not found" }),
		).toBeVisible()
		// PublicShell chrome + the guest variant's Sign In (both the toolbar
		// and the panel offer it — either satisfies `.first()`).
		await expect(page.locator("header").first()).toBeVisible()
		await expect(page.getByRole("link", { name: "Sign In" }).first()).toBeVisible()
		// And none of the member furniture.
		await expect(page.getByRole("button", { name: "Sign Out" })).not.toBeVisible()
		await expect(
			page.getByRole("link", { name: "Go to Dashboard" }),
		).not.toBeVisible()
	})
})
