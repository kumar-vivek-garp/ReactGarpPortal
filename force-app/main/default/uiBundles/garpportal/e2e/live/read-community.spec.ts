import { expect, test, type Locator, type Page } from "@playwright/test"

import { probeGateway, type LiveGate } from "../support/live-gate"
import { installOrgSafetyGuard } from "../support/live-guard"

/**
 * L1 — live read smoke: /events, /help-center (+My Requests tab),
 * /member-directory (typing a term is fine — directorySearch is a verified
 * DML-free POST on the guard's allow-list). REAL org reads behind the
 * org-safety guard; see read-core.spec.ts for the assertion contract.
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

test("events page renders bookings or its empty state", async ({ page }) => {
	const { guard, apiFailures } = await armLivePage(page)
	await gotoLive(page, "/events")

	await expect(
		page.getByRole("heading", { name: "My Events", level: 1 }),
	).toBeVisible({ timeout: 30_000 })

	const upNext = page.getByText("Up next — you're attending")
	const listing = page
		.getByRole("heading", { name: /Also happening|Upcoming events/ })
		.first()
	const empty = page.getByText("No events to show")
	await expect(settleUnion(page, upNext, listing, empty)).toBeVisible({
		timeout: 30_000,
	})
	await expectNoErrorCopy(page)
	noteOrg(
		`/events → ${
			(await empty.isVisible())
				? "no events (empty state)"
				: (await upNext.isVisible())
					? "up-next hero + listing"
					: "event listing"
		}` + (apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	expect(guard.blocked).toEqual([])
})

test("help center: the case form renders and My Requests lists or is empty", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)
	await gotoLive(page, "/help-center")

	await expect(
		page.getByRole("heading", { name: "Help Center", level: 1 }),
	).toBeVisible({ timeout: 30_000 })
	// The case-form card title is a CardTitle (a div, not a heading role);
	// exact match keeps the chrome's "Open a support case with Member
	// Services…" subtitle out of it.
	await expect(
		page.getByText("Open a support case", { exact: true }),
	).toBeVisible({ timeout: 30_000 })

	// The requests tab — its search-param value is "requests" (the pill reads
	// "My Requests"); reached by the pill so the URL round-trip is exercised.
	await page.getByRole("tab", { name: /My Requests/ }).click()
	await expect(page).toHaveURL(/tab=requests/, { timeout: 30_000 })

	const caseTable = page.getByText("Case", { exact: true }).first()
	const noRequests = page.getByText("You haven't raised any requests yet")
	await expect(settleUnion(page, caseTable, noRequests)).toBeVisible({
		timeout: 30_000,
	})
	await expectNoErrorCopy(page)
	noteOrg(
		`/help-center?tab=requests → ${
			(await noRequests.isVisible())
				? "zero support cases (empty state)"
				: "case rows listed"
		}` + (apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	expect(guard.blocked).toEqual([])
})

test("member directory searches the live org (allow-listed POST) or shows its gate", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)
	await gotoLive(page, "/member-directory")

	await expect(
		page.getByRole("heading", { name: "Member Directory", level: 1 }),
	).toBeVisible({ timeout: 30_000 })

	const searchBox = page.getByRole("textbox", {
		name: "Search the member directory",
	})
	const noAccess = page.getByText(
		"The directory is not available on your membership",
	)
	await expect(settleUnion(page, searchBox, noAccess)).toBeVisible({
		timeout: 30_000,
	})

	if (await noAccess.isVisible()) {
		noteOrg(
			"/member-directory → directory not on this membership (access gate)",
		)
	} else {
		// The mount search (empty term) has already fired; settle it first.
		const rows = page.getByRole("button", { name: /^View / })
		const zero = page.getByText("No members found")
		await expect(settleUnion(page, rows.first(), zero)).toBeVisible({
			timeout: 30_000,
		})

		// Typing is safe: directorySearch is a verified DML-free POST on the
		// guard's allow-list. Assert results or the zero state — both pass.
		await searchBox.pressSequentially("an", { delay: 60 })
		await expect(settleUnion(page, rows.first(), zero)).toBeVisible({
			timeout: 30_000,
		})
		noteOrg(
			`/member-directory → search "an": ${
				(await zero.isVisible())
					? "no members found"
					: `${await rows.count()} member row(s) on page 1`
			}`,
		)
	}
	await expectNoErrorCopy(page)
	if (apiFailures.length)
		noteOrg(`/member-directory API >=400: ${apiFailures.join(" | ")}`)

	expect(guard.blocked).toEqual([])
})
