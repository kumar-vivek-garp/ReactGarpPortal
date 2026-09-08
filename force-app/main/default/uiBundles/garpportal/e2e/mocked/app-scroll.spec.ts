import { expect, test } from "@playwright/test"

import { accountView } from "@/testing/factories/account"
import { portalOrder } from "@/testing/factories/orders"
import { installMockOrg, type MockOrgOptions } from "../support/mock-org"
import { dashboardActionSet } from "../support/payloads"

/**
 * The shell owns the only scroll container.
 *
 * Every panel used to pin itself to `h-[calc(100vh-4rem)]` and open a scroller
 * of its own, which stacked a second scroll container inside the document's and
 * left the footer outside all twenty-four of them. These assertions are the
 * ones a unit test cannot make: they need real layout.
 */

const SCROLLER = "#app-scroll"

/**
 * Enough of an org that every page in this file renders its real content
 * rather than an error boundary — the geometry is only meaningful once the
 * page it belongs to has actually drawn.
 */
function baseOptions(): MockOrgOptions {
	return {
		actions: {
			...dashboardActionSet(),
			account: accountView(),
			expertise: {
				statusCode: 200,
				statusMessage: null,
				values: {},
				options: {},
				labels: {},
			},
			orders: { unpaidOrders: [portalOrder()], paidOrders: [] },
		},
	}
}

/** Pages that used to carry the viewport arithmetic, one per shape. */
const PAGES = [
	["the dashboard", "/dashboard"],
	["a tabbed page", "/my-account"],
	["a listing", "/programs"],
	["a detail page", "/study-materials"],
] as const

test.describe("the app scroll container", () => {
	for (const [what, path] of PAGES) {
		test(`${what} leaves the document unscrollable and scrolls in one place`, async ({
			page,
		}) => {
			await installMockOrg(page, baseOptions())
			await page.goto(path)
			await expect(page.locator(SCROLLER)).toBeAttached()

			const shape = await page.evaluate((selector) => {
				const root = document.documentElement
				const scrollers = [...document.querySelectorAll<HTMLElement>("*")]
					.filter((el) => {
						const { overflowY } = getComputedStyle(el)
						return (
							(overflowY === "auto" || overflowY === "scroll") &&
							el.scrollHeight > el.clientHeight + 1
						)
					})
					.map((el) => el.id || el.tagName.toLowerCase())
				const scroller = document.querySelector<HTMLElement>(selector)!
				return {
					documentOverflows: root.scrollHeight > root.clientHeight + 1,
					scrollers,
					footerInsideScroller: Boolean(scroller.querySelector("footer")),
				}
			}, SCROLLER)

			// The page itself never scrolls, so the toolbar and rail hold their
			// place without re-deriving the viewport height.
			expect(shape.documentOverflows).toBe(false)
			// Exactly one thing scrolls, and it is ours.
			expect(shape.scrollers).toEqual(["app-scroll"])
			// The footer is reached by the same gesture that reads the page.
			expect(shape.footerInsideScroller).toBe(true)
		})
	}

	test("the footer can actually be reached, and the rail does not move with it", async ({
		page,
	}) => {
		await installMockOrg(page, baseOptions())
		await page.goto("/my-account")
		await expect(page.locator(SCROLLER)).toBeAttached()

		const railBefore = await page.locator("aside").first().boundingBox()

		await page.locator(SCROLLER).evaluate((el) => {
			el.scrollTop = el.scrollHeight
		})
		await expect(page.locator("footer")).toBeInViewport()

		// Same rail, same place: it is outside the scrolling column entirely.
		const railAfter = await page.locator("aside").first().boundingBox()
		expect(railAfter?.y).toBe(railBefore?.y)
	})

	test("the shell survives navigation without remounting", async ({ page }) => {
		await installMockOrg(page, baseOptions())
		await page.goto("/dashboard")
		await expect(page.locator(SCROLLER)).toBeAttached()

		// Node identity, not appearance: a remounted shell replays the page fade
		// over the whole chrome, which reads as a full-screen flash.
		await page.evaluate(() => {
			;(window as unknown as { __chrome: unknown }).__chrome = {
				header: document.querySelector("header"),
				scroller: document.querySelector("#app-scroll"),
			}
		})

		await page.locator('a[href="/programs"]').first().click()
		await expect(page).toHaveURL(/\/programs$/)
		await expect(
			page.getByRole("heading", { name: "My Programs" }),
		).toBeVisible()

		const same = await page.evaluate(() => {
			const before = (
				window as unknown as {
					__chrome: { header: Element | null; scroller: Element | null }
				}
			).__chrome
			return {
				header: before.header === document.querySelector("header"),
				scroller: before.scroller === document.querySelector("#app-scroll"),
			}
		})
		expect(same).toEqual({ header: true, scroller: true })
	})

	test("the rail's collapse toggle clears the toolbar it sits under", async ({
		page,
	}) => {
		await installMockOrg(page, baseOptions())
		await page.goto("/dashboard")
		await expect(page.locator('button[aria-label*="sidebar"]')).toBeVisible()

		/*
		 * The pill straddles the rail's right edge and is centred on `top-3`, so
		 * its top edge lands exactly on the toolbar's bottom edge. The toolbar is
		 * `z-[1000]` and would cover anything above that line — the symptom is a
		 * toggle that looks half hidden. It reached this y through `sticky
		 * top-20` before the shell framed the viewport, so it is worth an
		 * assertion that does not care how it gets there.
		 */
		const geometry = await page.evaluate(() => {
			const pill = document.querySelector<HTMLElement>(
				'button[aria-label*="sidebar"]',
			)!
			const toolbar = document.querySelector<HTMLElement>("header")!
			const box = pill.getBoundingClientRect()
			return {
				topEdge: box.top,
				toolbarBottom: toolbar.getBoundingClientRect().bottom,
				size: { w: box.width, h: box.height },
				// Nothing is painting over it at its own centre.
				hits: pill.contains(
					document.elementFromPoint(
						box.x + box.width / 2,
						box.y + box.height / 2,
					),
				),
			}
		})

		expect(geometry.topEdge).toBe(geometry.toolbarBottom)
		expect(geometry.size).toEqual({ w: 32, h: 24 })
		expect(geometry.hits).toBe(true)
	})

	test("a new route lands at the top rather than mid-page", async ({ page }) => {
		await installMockOrg(page, baseOptions())
		await page.goto("/study-materials")
		await expect(page.locator(SCROLLER)).toBeAttached()

		await page.locator(SCROLLER).evaluate((el) => {
			el.scrollTop = 400
		})
		await page.locator('a[href="/programs"]').first().click()
		await expect(page).toHaveURL(/\/programs$/)

		// The browser does this for free only when the document scrolls; on an
		// element it is the router's `scrollToTopSelectors` doing it.
		await expect
			.poll(() =>
				page.locator(SCROLLER).evaluate((el) => el.scrollTop),
			)
			.toBe(0)
	})
})
