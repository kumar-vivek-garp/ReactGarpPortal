import { expect, test, type Locator, type Page } from "@playwright/test"

import { probeGateway, type LiveGate } from "../support/live-gate"
import { installOrgSafetyGuard } from "../support/live-guard"

/**
 * L1 — live read smoke, core surfaces: /dashboard, /programs (+first in-app
 * detail), /membership, /content. REAL org reads (devjuly25a) through the CLI
 * gateway; strictly read-only — every test runs behind the org-safety guard
 * and ends by proving the page attempted no unexpected writes.
 *
 * Assertion contract per page: no error copy, the page's h1 renders, and
 * EITHER real data OR the page's own empty state is visible — org data for
 * the CLI fallback contact is whatever it is, so both are passes.
 */

/** Error copy that must not survive a settled page (contract (a)). */
const ERROR_COPY = /unable to load|went wrong|couldn['’]t (load|run)/i

let gate: LiveGate

test.beforeAll(async () => {
	gate = await probeGateway()
})

test.beforeEach(() => {
	test.skip(!gate.ok, gate.reason)
	// Real org round-trips are slow; one generous budget for every spec.
	test.setTimeout(120_000)
})

/** Guard + response log installed BEFORE any navigation (THE BIG RULE). */
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

/** Full-load a route and wait for the app shell to come up. */
async function gotoLive(page: Page, path: string) {
	await page.goto(path)
	await expect(page.locator("header").first()).toBeVisible({ timeout: 30_000 })
	await expect(page.locator("#boot-splash")).not.toBeVisible({
		timeout: 30_000,
	})
}

/**
 * Union of the page's real end-states PLUS its error copy, so the settle
 * wait resolves either way and the follow-up no-error check names the truth
 * instead of timing out blind.
 */
function settleUnion(page: Page, first: Locator, ...rest: Locator[]) {
	let union = first
	for (const locator of rest) union = union.or(locator)
	return union.or(page.getByText(ERROR_COPY).first()).first()
}

/** Contract (a): after settle, no error copy anywhere (toasts included). */
async function expectNoErrorCopy(page: Page) {
	await expect(page.getByText(ERROR_COPY)).toHaveCount(0)
}

/** Surface what the org actually answered, for the morning report. */
function noteOrg(what: string) {
	test.info().annotations.push({ type: "org-data", description: what })
	console.log(`[live] ${what}`)
}

test("dashboard: cards or caught-up state, identity chrome, no writes", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)
	await gotoLive(page, "/dashboard")

	await expect(
		page.getByRole("heading", { name: "Dashboard", level: 1 }),
	).toBeVisible({ timeout: 30_000 })
	await expect(page.getByText("Member home")).toBeVisible()

	// Identity chrome: the sidebar profile row carries name + GARP ID. Assert
	// non-empty identity only — never a specific name (the CLI session may
	// resolve as "CLI Member" or the fallback contact's real name).
	await expect(page.getByRole("link", { name: /GARP ID/ }).first()).toBeVisible(
		{ timeout: 30_000 },
	)

	const caughtUp = page.getByText("You're all caught up")
	const cardGrid = page.locator("main .grid > *")
	await expect(settleUnion(page, caughtUp, cardGrid.first())).toBeVisible({
		timeout: 30_000,
	})

	const cardCount = await cardGrid.count()
	noteOrg(
		`/dashboard → ${cardCount > 0 ? `${cardCount} card(s)` : "caught-up empty state"}` +
			(apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	await expectNoErrorCopy(page)
	expect(guard.blocked).toEqual([])
})

test("programs: listing renders; first in-app detail opens read-only", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)
	await gotoLive(page, "/programs")

	await expect(
		page.getByRole("heading", { name: "My Programs", level: 1 }),
	).toBeVisible({ timeout: 30_000 })

	const anyCardAction = page
		.getByRole("link", { name: /View Details|Register Now|Learn more about/ })
		.first()
	const anyEmpty = page
		.getByText(
			/No programs (to show|in progress)|No completed programs|Nothing else to explore/,
		)
		.first()
	await expect(settleUnion(page, anyCardAction, anyEmpty)).toBeVisible({
		timeout: 30_000,
	})
	await expectNoErrorCopy(page)

	// Click into the first IN-APP program detail, if the org gave us one.
	// (Some View Details links are external garp.org hrefs — those stay shut.)
	const inAppDetail = page
		.locator('a[href^="/programs/"], a[href^="/courses/"]')
		.filter({ hasText: "View Details" })
		.first()
	const detailCount = await inAppDetail.count()
	if (detailCount > 0) {
		const href = await inAppDetail.getAttribute("href")
		await inAppDetail.click()
		await expect(page).toHaveURL(new RegExp(`${href ?? ""}$`), {
			timeout: 30_000,
		})
		await expect(
			page.getByRole("heading", { level: 1 }).first(),
		).toBeVisible({ timeout: 30_000 })
		await expectNoErrorCopy(page)
		noteOrg(`/programs → in-app detail opened: ${href}`)
	} else {
		noteOrg(
			"/programs → no in-app View Details link (no enrolled program with a detail page)",
		)
	}
	if (apiFailures.length) noteOrg(`/programs API >=400: ${apiFailures.join(" | ")}`)

	expect(guard.blocked).toEqual([])
})

test("membership and content render their real-org states", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)

	await gotoLive(page, "/membership")
	await expect(
		page.getByRole("heading", { name: "Membership Benefits", level: 1 }),
	).toBeVisible({ timeout: 30_000 })
	// A benefits bucket heading carries its count ("Career (2)"); zero
	// published benefits renders the panel's own empty state.
	const bucket = page.getByRole("heading", { name: /\(\d+\)/ }).first()
	const noBenefits = page.getByText("No benefits published yet")
	await expect(settleUnion(page, bucket, noBenefits)).toBeVisible({
		timeout: 30_000,
	})
	await expectNoErrorCopy(page)
	noteOrg(
		`/membership → ${(await noBenefits.isVisible()) ? "empty benefits state" : "benefit buckets rendered"}`,
	)

	// /content without the gated cookie is the expired-link state by design —
	// a legitimate page state, not an error.
	await gotoLive(page, "/content")
	await expect(
		page.getByRole("heading", { name: "GARP Content", level: 1 }),
	).toBeVisible({ timeout: 30_000 })
	const expired = page.getByText("This link has expired")
	const allowed = page.getByText(
		"Your membership gives you access to this content.",
	)
	const refused = page.getByText(
		"This content is for members in good standing.",
	)
	await expect(settleUnion(page, expired, allowed, refused)).toBeVisible({
		timeout: 30_000,
	})
	await expectNoErrorCopy(page)
	noteOrg(
		`/content → ${
			(await expired.isVisible())
				? "expired-link state (no gated cookie — expected)"
				: (await allowed.isVisible())
					? "member-in-good-standing hand-off"
					: "not-entitled upsell"
		}` + (apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	expect(guard.blocked).toEqual([])
})
