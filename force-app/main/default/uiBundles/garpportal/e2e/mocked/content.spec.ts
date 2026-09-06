import { expect, test } from "@playwright/test"

import { identity, membershipView } from "@/testing/factories/identity"
import { installMockOrg } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * The `/content` paywall: garp.org drops the `garp_gated_url` cookie and sends
 * the member here. Entitlement comes from the same `membership` action the
 * benefits page uses — a member in good standing gets the hand-off, anyone
 * else the upsell, and a missing/invalid cookie the expired-link state.
 *
 * The hand-off itself is `window.location.href = <cookie url>` after clearing
 * the cookie, so the observable parts are: the membership hit, the cookie
 * being gone, and the navigation to the (stubbed) garp.org article.
 */

const ARTICLE_URL = "https://www.garp.org/risk-intelligence/research/article-42"
const COOKIE_NAME = "garp_gated_url"

function baseActions(view = membershipView()): Record<string, unknown> {
	return { membership: view, programs: programsListData() }
}

test.describe("gated content", () => {
	test("a member in good standing is handed to the article and the cookie is cleared", async ({
		page,
		context,
		baseURL,
	}) => {
		const org = await installMockOrg(page, { actions: baseActions() })
		await context.addCookies([
			{ name: COOKIE_NAME, value: ARTICLE_URL, url: baseURL! },
		])
		// The destination is a real cross-origin navigation; stub garp.org so
		// the test never leaves the machine.
		await page.route("https://www.garp.org/**", (route) =>
			route.fulfill({
				contentType: "text/html",
				body: "<!doctype html><title>Article</title><h1>Members-only article</h1>",
			}),
		)

		await page.goto("/content")

		await expect(
			page.getByRole("heading", { name: "GARP Content", level: 1 }),
		).toBeVisible()
		await expect(
			page.getByText("Your membership gives you access to this content."),
		).toBeVisible()
		await expect.poll(() => org.hits("membership")).toBe(1)

		await page.getByRole("button", { name: "Continue to your content" }).click()

		await expect(page).toHaveURL(ARTICLE_URL)
		// The cookie is single-use: cleared on the portal host before leaving.
		const cookies = await context.cookies(baseURL!)
		expect(cookies.find((cookie) => cookie.name === COOKIE_NAME)).toBeUndefined()
	})

	test("a member not in good standing gets the upsell carrying the article", async ({
		page,
		context,
		baseURL,
	}) => {
		await installMockOrg(page, {
			actions: baseActions(
				membershipView({
					identity: identity({
						isMember: false,
						isIndividualMember: false,
						isAffiliateMember: true,
						isMemberInGoodStanding: false,
						membershipType: "Affiliate",
						membershipStatus: "Lapsed",
					}),
				}),
			),
		})
		await context.addCookies([
			{ name: COOKIE_NAME, value: ARTICLE_URL, url: baseURL! },
		])
		await page.goto("/content")

		await expect(
			page.getByText("This content is for members in good standing."),
		).toBeVisible()
		await expect(page.getByRole("link", { name: "My Account" })).toBeVisible()

		// Not an Individual member => "Upgrade"; the CTA carries the attribution
		// tag and the article so checkout can return them to it.
		const upsell = page.getByRole("link", { name: "Upgrade your membership" })
		await expect(upsell).toBeVisible()
		const href = await upsell.getAttribute("href")
		expect(href).toContain("track_cta=PortalGatedContent")
		expect(href).toContain("garp_gated_url=https%3A%2F%2Fwww.garp.org")
	})

	test("without the cookie the page reports an expired link", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: baseActions() })
		await page.goto("/content")

		await expect(page.getByText("This link has expired")).toBeVisible()
		const back = page.getByRole("link", { name: /Back to garp\.org/ })
		await expect(back).toBeVisible()
		expect(await back.getAttribute("href")).toBe("https://www.garp.org")
	})
})
