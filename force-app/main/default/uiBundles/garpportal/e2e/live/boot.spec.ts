import { expect, test } from "@playwright/test"

import { probeGateway, type LiveGate } from "../support/live-gate"
import { installOrgSafetyGuard } from "../support/live-guard"

/**
 * L0 — live infrastructure gate. REAL org reads through the CLI gateway.
 * Every spec installs the org-safety guard first; the negative spec below
 * PROVES the guard blocks mutations before any L1 spec trusts it.
 */

let gate: LiveGate

test.beforeAll(async () => {
	gate = await probeGateway()
})

test.beforeEach(() => {
	test.skip(!gate.ok, gate.reason)
})

test("gateway is healthy and pointed at the expected org", async () => {
	expect(gate.targetOrg).toBeTruthy()
	test.info().annotations.push(
		{ type: "org", description: `${gate.targetOrg} (${gate.orgId})` },
		{ type: "cli-user", description: gate.username ?? "unknown" },
	)
})

test("the org-safety guard blocks a mutation POST", async ({ page }) => {
	const guard = await installOrgSafetyGuard(page)
	await page.goto("/dashboard")
	await expect(page.locator("header").first()).toBeVisible({
		timeout: 20_000,
	})

	const outcome = await page.evaluate(async () => {
		try {
			const response = await fetch(
				"/services/apexrest/memberportal/dismissCard",
				{ method: "POST", body: JSON.stringify({ cardKey: "e2e-probe" }) },
			)
			return `unexpected HTTP ${response.status}`
		} catch {
			return "blocked"
		}
	})

	expect(outcome).toBe("blocked")
	expect(
		guard.blocked.some((entry) => entry.includes("dismissCard")),
	).toBe(true)
})

test("the app boots against the real org and resolves an identity", async ({
	page,
}) => {
	const guard = await installOrgSafetyGuard(page)
	await page.goto("/")
	await expect(page).toHaveURL(/\/dashboard/, { timeout: 30_000 })
	await expect(page.locator("header").first()).toBeVisible()
	await expect(page.locator("#boot-splash")).not.toBeVisible({
		timeout: 30_000,
	})

	// Surface what the org actually answered, for the morning report.
	const memberHome = page.getByText(/member home/i).first()
	await expect(memberHome).toBeVisible({ timeout: 30_000 })
	expect(guard.blocked).toEqual([])
})
