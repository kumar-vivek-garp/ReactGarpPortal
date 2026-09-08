import { expect, test, type Route } from "@playwright/test"

import { accountStanding, accountView } from "@/testing/factories/account"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { portalOrder } from "@/testing/factories/orders"
import { installMockOrg, refuse, type MockOrgOptions } from "../support/mock-org"

/**
 * My Account module: the tab shell, per-tab data laziness, the membership
 * auto-renew toggle, and the account error leg. Order History list/detail
 * journeys live in my-account.orders.spec.ts; Contact Preferences in
 * my-account.preferences.spec.ts; the Personal Information edit dialog in
 * my-account.profile-edit.spec.ts.
 */

/** `GET /memberportal/expertise` happy shape so the SME card stays quiet. */
const EXPERTISE_OK = {
	statusCode: 200,
	statusMessage: null,
	values: {},
	options: {},
	labels: {},
}

function baseOptions(): MockOrgOptions {
	return {
		actions: {
			account: accountView(),
			expertise: EXPERTISE_OK,
			orders: { unpaidOrders: [portalOrder()], paidOrders: [] },
		},
	}
}

test.describe("my-account tabs and laziness", () => {
	test("default tab renders account information; only its own queries fire", async ({
		page,
	}) => {
		const org = await installMockOrg(page, baseOptions())
		await page.goto("/my-account")

		await expect(
			page.getByRole("heading", { level: 1, name: "My Account" }),
		).toBeVisible()
		// Identity hero from the REST account payload.
		await expect(page.getByRole("heading", { name: "Ada Lovelace" })).toBeVisible()
		await expect(page.getByText("G-IDENTITY").first()).toBeVisible()
		// The Personal Information bento card with its field grid.
		await expect(
			page.getByText("Personal Information", { exact: true }).first(),
		).toBeVisible()
		await expect(page.getByText("First Name", { exact: true })).toBeVisible()

		// This tab's own calls: REST account + the SME card's expertise read.
		await expect.poll(() => org.hits("account")).toBe(1)
		await expect.poll(() => org.hits("expertise")).toBe(1)
		// Tabs are lazy — nothing belonging to the other two tabs fires.
		expect(org.hits("orders")).toBe(0)
		// The edit dialog is closed, so its billing-company read must not run —
		// the session probe is the only GraphQL traffic on this tab.
		expect(org.of("graphql").every((call) => call.key === "CurrentUser")).toBe(true)
	})

	test("landing directly on order-history fetches orders, not profile reads", async ({
		page,
	}) => {
		const org = await installMockOrg(page, baseOptions())
		await page.goto("/my-account?tab=order-history")

		await expect(
			page.getByRole("heading", { name: "Unpaid Orders" }),
		).toBeVisible()
		await expect(page.getByText("INV-0001")).toBeVisible()

		await expect.poll(() => org.hits("orders")).toBe(1)
		// Real behavior: the REST account call still fires on every tab — the
		// panel needs it for completeness + contactId — but the GraphQL
		// ContactPreferences read and the account tab's expertise read do not.
		expect(org.hits("account")).toBe(1)
		expect(org.hits("ContactPreferences")).toBe(0)
		expect(org.hits("expertise")).toBe(0)
	})

	test("the tab bar switches to Order History client-side", async ({ page }) => {
		const org = await installMockOrg(page, baseOptions())
		await page.goto("/my-account")
		await expect(
			page.getByRole("heading", { name: "Ada Lovelace" }),
		).toBeVisible()
		expect(org.hits("orders")).toBe(0)

		await page.getByRole("tab", { name: "Order History" }).click()

		await expect(page).toHaveURL(/\/my-account\?tab=order-history/)
		await expect(
			page.getByRole("heading", { name: "Unpaid Orders" }),
		).toBeVisible()
		await expect.poll(() => org.hits("orders")).toBe(1)
	})
})

test.describe("membership auto-renew", () => {
	test("Turn On Auto-Renew posts the return URL and leaves for Stripe's setup page", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				// An Individual contract with auto-renew off => turn-on callout.
				account: accountView({ standing: accountStanding() }),
				expertise: EXPERTISE_OK,
				// Same origin as the app so the "Stripe" page can be routed below;
				// the real one is checkout.stripe.com and the browser leaves.
				membershipAutoRenewOn: async (route: Route) => {
					const origin = new URL(route.request().url()).origin
					await route.fulfill({
						json: memberPortalEnvelope({
							statusCode: 200,
							statusMessage: "Call Succuess",
							needPaymentInfo: true,
							setupUrl: `${origin}/stripe-setup-stub`,
						}),
					})
				},
			},
		})
		await page.route("**/stripe-setup-stub", (route) =>
			route.fulfill({
				contentType: "text/html",
				body: "<h1>Stripe setup</h1>",
			}),
		)
		await page.goto("/my-account")

		const turnOn = page.getByRole("button", { name: "Turn On Auto-Renew" })
		await expect(turnOn).toBeVisible()
		await turnOn.click()

		await expect(page).toHaveURL(/\/stripe-setup-stub$/)
		await expect.poll(() => org.hits("membershipAutoRenewOn")).toBe(1)
		const call = org.of("membershipAutoRenewOn")[0]
		expect(call.method).toBe("POST")
		const body = JSON.parse(call.postData ?? "{}") as { returnUrl?: string }
		expect(body.returnUrl).toMatch(
			/^https?:\/\/[^/]+\/my-account\?status=autorenewsetupcomplete$/,
		)
	})

	test("Disable Auto Renew asks first, then posts and flips the card", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				account: accountView({
					standing: accountStanding({ isAutoRenewEnabled: true }),
				}),
				expertise: EXPERTISE_OK,
				membershipAutoRenewOff: {
					statusCode: 200,
					statusMessage: "Membership Information returned",
				},
			},
		})
		await page.goto("/my-account")

		await page.getByRole("button", { name: "Disable Auto Renew" }).click()

		const dialog = page.getByRole("dialog", { name: "Turn off auto-renew?" })
		await expect(dialog).toBeVisible()
		// Nothing is posted until the member confirms.
		expect(org.hits("membershipAutoRenewOff")).toBe(0)

		// The success path invalidates the account cache — serve the flipped
		// contract so the refetched card shows the auto-renew-off state.
		org.use({
			actions: {
				account: accountView({
					standing: accountStanding({ isAutoRenewEnabled: false }),
				}),
			},
		})
		await dialog.getByRole("button", { name: "Yes, turn it off" }).click()

		await expect(dialog).toBeHidden()
		await expect(page.getByText("Auto-renew is off").first()).toBeVisible()
		await expect.poll(() => org.hits("membershipAutoRenewOff")).toBe(1)
		expect(org.of("membershipAutoRenewOff")[0].method).toBe("POST")
		await expect(
			page.getByRole("button", { name: "Turn On Auto-Renew" }),
		).toBeVisible()
	})
})

test.describe("error leg", () => {
	test("an account 500 shows the panel error with the chrome intact", async ({
		page,
	}) => {
		await installMockOrg(page, {
			actions: {
				account: refuse(500, "Account service unavailable"),
				expertise: EXPERTISE_OK,
			},
		})
		await page.goto("/my-account")

		await expect(
			page.getByText(
				"We couldn't load your account information. Please try again later.",
			),
		).toBeVisible()
		// Chrome survives: page heading, tab bar, and the app header all stand.
		await expect(
			page.getByRole("heading", { level: 1, name: "My Account" }),
		).toBeVisible()
		await expect(page.getByRole("tab", { name: "Order History" })).toBeVisible()
		await expect(page.locator("header").first()).toBeVisible()
	})
})
