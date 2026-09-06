import { expect, test, type Locator, type Page } from "@playwright/test"

import { probeGateway, type LiveGate } from "../support/live-gate"
import { installOrgSafetyGuard } from "../support/live-guard"

/**
 * L1 — live read smoke: /study-materials (+/archive), /cpd, /cpd/activities.
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

test("study materials and the purchased archive render live org buckets", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)

	await gotoLive(page, "/study-materials")
	await expect(
		page.getByRole("heading", {
			name: "Study Materials for Risk Professionals",
			level: 1,
		}),
	).toBeVisible({ timeout: 30_000 })
	// Both section headings render once the payload lands ("My Materials (n)"
	// / "Catalogue (n)"); empty buckets show their own messages inside.
	const sections = page
		.getByRole("heading", { name: /My Materials|Catalogue/ })
		.first()
	await expect(settleUnion(page, sections)).toBeVisible({ timeout: 30_000 })
	await expectNoErrorCopy(page)
	noteOrg(
		"/study-materials → sections rendered" +
			(apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	await gotoLive(page, "/study-materials/archive")
	await expect(
		page.getByRole("heading", { name: "Purchased Study Materials", level: 1 }),
	).toBeVisible({ timeout: 30_000 })
	const yearGroup = page.getByRole("heading", { name: /^\d{4}$/, level: 2 })
	const archiveEmpty = page.getByText("No purchased materials yet")
	await expect(
		settleUnion(page, yearGroup.first(), archiveEmpty),
	).toBeVisible({ timeout: 30_000 })
	await expectNoErrorCopy(page)
	noteOrg(
		`/study-materials/archive → ${
			(await archiveEmpty.isVisible())
				? "zero purchased materials (empty state)"
				: `${await yearGroup.count()} edition year group(s)`
		}`,
	)

	expect(guard.blocked).toEqual([])
})

test("cpd summary renders a cycle or the no-cycle state", async ({ page }) => {
	const { guard, apiFailures } = await armLivePage(page)
	await gotoLive(page, "/cpd")

	await expect(
		page.getByRole("heading", {
			name: "Continuing Professional Development",
			level: 1,
		}),
	).toBeVisible({ timeout: 30_000 })

	const cycleContent = page
		.getByRole("heading", { name: /Pending Activities|Approved Activities/ })
		.first()
	const noCycle = page.getByText("No CPD cycle yet")
	await expect(settleUnion(page, cycleContent, noCycle)).toBeVisible({
		timeout: 30_000,
	})
	await expectNoErrorCopy(page)
	noteOrg(
		`/cpd → ${
			(await noCycle.isVisible())
				? "no CPD cycle for this contact (empty state)"
				: "cycle summary with activity sections"
		}` + (apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	expect(guard.blocked).toEqual([])
})

test("cpd activities catalogue lists opportunities or its zero state", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)
	await gotoLive(page, "/cpd/activities")

	await expect(
		page.getByRole("heading", { name: "Browse CPD Activities", level: 1 }),
	).toBeVisible({ timeout: 30_000 })

	// With results the pagination strip always renders; with none the panel's
	// own zero state does.
	const paging = page.getByText(/Showing \d+–\d+ of \d+/)
	const zeroState = page.getByText("No CPD activity found")
	await expect(settleUnion(page, paging, zeroState)).toBeVisible({
		timeout: 30_000,
	})
	await expectNoErrorCopy(page)
	noteOrg(
		`/cpd/activities → ${
			(await zeroState.isVisible())
				? "zero activities (empty state)"
				: `catalogue: ${(await paging.textContent())?.trim() ?? "paged results"}`
		}` + (apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	expect(guard.blocked).toEqual([])
})
