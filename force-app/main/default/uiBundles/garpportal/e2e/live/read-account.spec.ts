import { expect, test, type Locator, type Page } from "@playwright/test"

import { probeGateway, type LiveGate } from "../support/live-gate"
import { installOrgSafetyGuard } from "../support/live-guard"

/**
 * L1 — live read smoke, /my-account: default tab, order history (+first order
 * detail, READ only — Pay/Cancel are never clicked), contact preferences.
 * REAL org reads behind the org-safety guard; see read-core.spec.ts for the
 * assertion contract.
 */

const ERROR_COPY = /unable to load|went wrong|couldn['’]t (load|run)/i

let gate: LiveGate

test.beforeAll(async () => {
	gate = await probeGateway()
})

test.beforeEach(() => {
	test.skip(!gate.ok, gate.reason)
	test.setTimeout(120_000)
})

async function armLivePage(page: Page) {
	const guard = await installOrgSafetyGuard(page)
	const apiFailures: string[] = []
	page.on("response", (response) => {
		const url = response.url()
		if (
			response.status() >= 400 &&
			(url.includes("/services/") || url.includes("/__local_sf/"))
		) {
			apiFailures.push(
				`${response.status()} ${response.request().method()} ${url}`,
			)
		}
	})
	return { guard, apiFailures }
}

async function gotoLive(page: Page, path: string) {
	await page.goto(path)
	await expect(page.locator("header").first()).toBeVisible({ timeout: 30_000 })
	await expect(page.locator("#boot-splash")).not.toBeVisible({
		timeout: 30_000,
	})
}

function settleUnion(page: Page, first: Locator, ...rest: Locator[]) {
	let union = first
	for (const locator of rest) union = union.or(locator)
	return union.or(page.getByText(ERROR_COPY).first()).first()
}

async function expectNoErrorCopy(page: Page) {
	await expect(page.getByText(ERROR_COPY)).toHaveCount(0)
}

function noteOrg(what: string) {
	test.info().annotations.push({ type: "org-data", description: what })
	console.log(`[live] ${what}`)
}

test("my-account default tab renders the account cards", async ({ page }) => {
	const { guard, apiFailures } = await armLivePage(page)
	await gotoLive(page, "/my-account")

	await expect(
		page.getByRole("heading", { name: "My Account", level: 1 }),
	).toBeVisible({ timeout: 30_000 })
	await expect(
		page.getByRole("tab", { name: "Account Information" }),
	).toHaveAttribute("aria-selected", "true", { timeout: 30_000 })

	// The section cards render for any resolved contact; the fields inside
	// are whatever the org holds (blank is fine).
	const personal = page.getByText("Personal Information").first()
	const career = page.getByText("Career Information").first()
	await expect(settleUnion(page, personal, career)).toBeVisible({
		timeout: 30_000,
	})
	await expectNoErrorCopy(page)
	noteOrg(
		"/my-account → account-information cards rendered" +
			(apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	expect(guard.blocked).toEqual([])
})

test("order history lists orders or its zero state; first order opens read-only", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)
	await gotoLive(page, "/my-account?tab=order-history")

	await expect(
		page.getByRole("heading", { name: "My Account", level: 1 }),
	).toBeVisible({ timeout: 30_000 })
	await expect(
		page.getByRole("tab", { name: "Order History" }),
	).toHaveAttribute("aria-selected", "true", { timeout: 30_000 })

	const sections = page
		.getByRole("heading", { name: /Unpaid Purchases|Paid Purchases/ })
		.first()
	const zeroState = page.getByText("No orders yet")
	await expect(settleUnion(page, sections, zeroState)).toBeVisible({
		timeout: 30_000,
	})
	await expectNoErrorCopy(page)

	// Navigate into the first order, if the org holds one. READ only —
	// Pay Order / Cancel Order exist on the detail and are never clicked.
	const orderLinks = page.getByRole("link", { name: /^View order / })
	const orderCount = await orderLinks.count()
	if (orderCount > 0) {
		await orderLinks.first().click()
		// Order rows land on /my-account/orders/$orderNumber (the in-tab order
		// detail) — /order-details/ is a different, deep-linked page.
		await expect(page).toHaveURL(/\/my-account\/orders\//, {
			timeout: 30_000,
		})
		await expect(page.getByText("Order ID").first()).toBeVisible({
			timeout: 30_000,
		})
		await expectNoErrorCopy(page)
		noteOrg(
			`/my-account?tab=order-history → ${orderCount} order row(s); first detail opened at ${page.url()}`,
		)
	} else {
		noteOrg("/my-account?tab=order-history → zero orders (empty state)")
	}
	if (apiFailures.length)
		noteOrg(`order-history API >=400: ${apiFailures.join(" | ")}`)

	expect(guard.blocked).toEqual([])
})

test("contact preferences renders its cards from the live GraphQL read", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)
	await gotoLive(page, "/my-account?tab=contact-preferences")

	await expect(
		page.getByRole("tab", { name: "Contact Preferences" }),
	).toHaveAttribute("aria-selected", "true", { timeout: 30_000 })

	// This tab is the one GraphQL-read page in the suite — its POST must pass
	// the guard's query inspection (a blocked query would land in
	// guard.blocked AND leave the cards unrendered).
	const email = page.getByText("Email Preferences").first()
	const sms = page.getByText("SMS Preferences").first()
	await expect(settleUnion(page, email, sms)).toBeVisible({ timeout: 30_000 })
	await expectNoErrorCopy(page)
	noteOrg(
		"/my-account?tab=contact-preferences → preference cards rendered" +
			(apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	expect(guard.blocked).toEqual([])
})
