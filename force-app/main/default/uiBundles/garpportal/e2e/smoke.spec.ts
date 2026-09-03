import { expect, test, type Page } from "@playwright/test"

/**
 * Layer-3 smoke: the BUILT app (dist/, served statically per
 * playwright.config.ts) boots in a real browser and its load-bearing
 * routing/guard/theming behavior holds. Anything expressible as a component
 * test lives in Vitest — this file stays thin (testing.md).
 *
 * Wire strategy: the static server is localhost, so the app takes its
 * local-CLI identity branch (`/__local_sf` gateway) — intercepted here.
 * A guest is simulated with the app's own local-logout flag, which resolves
 * the session to null with zero network.
 */

const ENVELOPE_OK = {
	status: "Success",
	statusCode: 200,
	errorMessage: null,
	data: {},
}

const MEMBER_GRAPHQL = {
	data: {
		uiapi: {
			currentUser: {
				Id: "005000000000001AAA",
				Name: { value: "Ada Lovelace" },
				Contact: {
					Id: "003000000000001AAA",
					GARP_Member_ID__c: { value: "123456" },
					Photo_URL__c: { value: null },
				},
			},
		},
	},
}

/**
 * Identity via the local gateway; every other org read = empty success.
 * Playwright matches routes in REVERSE registration order, so the generic
 * catch-all is registered FIRST and the identity route last — a gateway URL
 * like /__local_sf/services/data/v67.0/graphql matches both patterns.
 */
async function mockOrgWire(page: Page) {
	await page.route("**/services/**", async (route) => {
		await route.fulfill({ json: ENVELOPE_OK })
	})
	await page.route("**/__local_sf/**", async (route) => {
		if (route.request().url().includes("/graphql")) {
			await route.fulfill({ json: MEMBER_GRAPHQL })
			return
		}
		await route.fulfill({ json: ENVELOPE_OK })
	})
}

async function asGuest(page: Page) {
	await page.addInitScript(() => {
		sessionStorage.setItem("garpportal:local-logged-out", "1")
	})
}

test.describe("boot and auth wall", () => {
	test("a guest hitting the app is walled off at Login", async ({ page }) => {
		await mockOrgWire(page)
		await asGuest(page)
		await page.goto("/")
		await expect(page).toHaveURL(/\/Login/)
	})

	test("a member lands on the dashboard with the app chrome", async ({
		page,
	}) => {
		await mockOrgWire(page)
		await page.goto("/")
		await expect(page).toHaveURL(/\/dashboard$/)
		await expect(page.locator("header").first()).toBeVisible()
		await expect(page.locator("#boot-splash")).not.toBeVisible()
	})

	test("client-side navigation reaches Programs", async ({ page }) => {
		await mockOrgWire(page)
		await page.goto("/dashboard")
		await page.locator('a[href="/programs"]').first().click()
		await expect(page).toHaveURL(/\/programs$/)
	})

	test("an unknown path renders the 404 page", async ({ page }) => {
		await mockOrgWire(page)
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
		await mockOrgWire(page)
		await asGuest(page)
		await page.goto("/programs/frm/register?regCode=TEAM24")
		await expect(page).toHaveURL(/\/registration\/frm/)
		expect(page.url()).toContain("regCode=TEAM24")
	})

	test("a guest payment return keeps its params through the public-twin bounce", async ({
		page,
	}) => {
		await mockOrgWire(page)
		await asGuest(page)
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
		await mockOrgWire(page)
		await asGuest(page)
		await page.goto("/registration/affiliate")
		await expect(page).toHaveURL(/\/registration\/affiliate/)
		await expect(page.locator("header").first()).toBeVisible()
	})
})

test.describe("theming", () => {
	test("system dark scheme yields the dark theme", async ({ page }) => {
		await mockOrgWire(page)
		await page.emulateMedia({ colorScheme: "dark" })
		await page.goto("/dashboard")
		await expect(page.locator("html")).toHaveClass(/dark/)
	})

	test("system light scheme yields the light theme", async ({ page }) => {
		await mockOrgWire(page)
		await page.emulateMedia({ colorScheme: "light" })
		await page.goto("/dashboard")
		await expect(page.locator("html")).not.toHaveClass(/dark/)
	})
})
