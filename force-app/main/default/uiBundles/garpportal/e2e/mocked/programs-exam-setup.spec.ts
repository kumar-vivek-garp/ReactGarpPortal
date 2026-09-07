import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import {
	examSetupAuthorizeResult,
	examSetupSaveResult,
	examSetupView,
} from "@/testing/factories/exam-setup"
import { installMockOrg } from "../support/mock-org"
import { dashboardActionSet } from "../support/payloads"

/**
 * Exam setup wizard journeys against the built bundle.
 *
 * One page — the sitting, the ID, one Save — over the real `examSetup` /
 * `examSetupId` / `examSetupFees` actions. What this layer is for
 * is the wire contract and the screen outcome: the exact body Apex reads, that
 * a fee-bearing change prices exactly once, and that a scheduling-required save
 * pushes to the provider exactly once. Field-level rules stay in the component
 * suite; the 20s retry stays in the fake-timer hook test, because waiting it out
 * in a real browser would cost the suite 20 seconds to prove nothing new.
 */

/** No floating alert over the wizard's controls (see programs.spec.ts). */
const NO_ALERT = {
	statusMessage: null,
	statusCode: 200,
	examType: null,
	examPart: null,
	alertStatus: null,
	deadline: null,
	orderId: null,
	route: null,
} satisfies AlertBarView

const FEES_VIEW = {
	statusMessage: null,
	statusCode: 200,
	examType: "FRM",
	fees: [
		{
			name: "FRM Part I from May 2026 to November 2026",
			type: "fee",
			amount: 250,
			description: "Standard exam administration change fee",
			productCode: "FRM1",
			glCode: "4040",
			accountingCode: null,
			examRegId: null,
			examSiteId: null,
		},
	],
	examEmailParts: null,
	deferralSubType: "Deferral Standard",
	transactionType: "Salesforce - Deferral",
}

function examSetupActions(
	overrides: Record<string, unknown> = {},
): Record<string, unknown> {
	return {
		...dashboardActionSet(),
		alertBar: NO_ALERT,
		examSetup: examSetupView(),
		examSetupId: examSetupSaveResult(),
		examSetupFees: FEES_VIEW,
		...overrides,
	}
}

const SAVE = "Save exam setup"

/** The form is interactive once the sitting tiles have rendered. */
async function ready(page: import("@playwright/test").Page) {
	await expect(page.getByRole("radio", { name: /May 2026/ })).toBeVisible()
}

test.describe("exam setup", () => {
	test("opens with the current sitting selected and read out in the bar", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: examSetupActions() })
		await page.goto("/programs/frm/exam-setup")
		await ready(page)

		await expect(
			page.getByRole("heading", { level: 1, name: /Financial Risk Manager.*Exam Setup/ }),
		).toBeVisible()
		await expect(page.getByRole("radio", { name: /May 2026/ })).toBeChecked()
		await expect(
			page.getByRole("combobox", { name: /Where do you plan to sit/ }),
		).toContainText("London")
		await expect(page.getByText("May 2026 · London")).toBeVisible()
		expect(org.hits("examSetup")).toBe(1)
	})

	test("saves through examSetupId with the exact body Apex reads", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: examSetupActions() })
		await page.goto("/programs/frm/exam-setup")

		await ready(page)
		// Same administration, different site — the free change.
		await page.getByRole("combobox", { name: /Where do you plan to sit/ }).click()
		await page.getByRole("option", { name: "Paris" }).click()
		await page.getByRole("button", { name: SAVE }).click()

		await expect(page.getByText("Your exam setup is complete.")).toBeVisible()
		await expect.poll(() => org.hits("examSetupId")).toBe(1)

		const call = org.of("examSetupId")[0]
		expect(call.method).toBe("POST")
		const body = JSON.parse(call.postData ?? "{}") as {
			programType: string
			id: Record<string, unknown>
			selection: Record<string, unknown>
		}
		expect(body.programType).toBe("frm")
		expect(body.selection).toEqual({
			selectedAdminPart1: "admin-may",
			selectedSitePart1: "site-paris",
			selectedAdminPart2: null,
			selectedSitePart2: null,
		})
		// FRM sends the government-ID trio, with the date in the US format the
		// write expects — not the ISO the read returned.
		expect(body.id).toMatchObject({
			idName: "Ada Lovelace",
			idType: "passport",
			idNumber: "45678",
			idExpireDate: "01/01/2030",
		})
		// No OSTA block: this member does not sit in mainland China.
		expect(body.id.ostaIDLocation).toBeUndefined()
	})

	test("a fee-bearing change is written, then priced exactly once", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: examSetupActions({
				examSetupId: examSetupSaveResult({
					nextScreen: "Pay Fees",
					paymentRequired: true,
					examModificationId: "a0M999",
				}),
			}),
		})
		await page.goto("/programs/frm/exam-setup")

		await ready(page)
		await page.getByRole("radio", { name: /November 2026/ }).click()
		await expect(page.getByText("New sitting")).toBeVisible()
		await page.getByRole("button", { name: SAVE }).click()

		await expect(page.getByText("There's a fee for this change")).toBeVisible()
		await expect(page.getByText("$250.00").first()).toBeVisible()

		// Priced from the modification the write raised — one call, no polling.
		await expect.poll(() => org.hits("examSetupFees")).toBe(1)
		const fees = JSON.parse(org.of("examSetupFees")[0].postData ?? "{}") as {
			modificationId: string
		}
		expect(fees.modificationId).toBe("a0M999")

		await expect(page.getByRole("link", { name: "Pay Fees" })).toHaveAttribute(
			"href",
			/myprograms\/setup\/feescheckout\/a0M999/,
		)
	})

	test("nothing is priced when nothing is owed", async ({ page }) => {
		const org = await installMockOrg(page, { actions: examSetupActions() })
		await page.goto("/programs/frm/exam-setup")

		await ready(page)
		await page.getByRole("button", { name: SAVE }).click()

		await expect(page.getByText("Your exam setup is complete.")).toBeVisible()
		expect(org.hits("examSetupFees")).toBe(0)
	})

	test("a scheduling-required save pushes to the provider once and links out", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: examSetupActions({
				examSetupId: examSetupSaveResult({
					nextScreen: "Check Authorization",
					schedulingRequired: true,
				}),
				examSetupAuthorize: examSetupAuthorizeResult({
					isAuthorized: true,
					examScheduleExamURLPart1: "https://provider.example/schedule/one",
				}),
			}),
		})
		await page.goto("/programs/frm/exam-setup")

		await ready(page)
		await page.getByRole("button", { name: SAVE }).click()

		await expect(page.getByText("Your exam setup was successful.")).toBeVisible()
		await expect(
			page.getByRole("link", { name: "Schedule Exam" }),
		).toHaveAttribute("href", "https://provider.example/schedule/one")

		// Accepted first time, so no retry: the second attempt only exists for a
		// provider that answers "not yet". Never a poll.
		await expect.poll(() => org.hits("examSetupAuthorize")).toBe(1)
		const call = org.of("examSetupAuthorize")[0]
		expect(JSON.parse(call.postData ?? "{}")).toEqual({
			programType: "frm",
			isRetry: false,
		})
	})

	test("a server refusal keeps the member on the form", async ({ page }) => {
		const org = await installMockOrg(page, {
			actions: examSetupActions({
				examSetupId: examSetupSaveResult({
					statusCode: 505,
					statusMessage: "Part II cannot be taken before Part I",
				}),
			}),
		})
		await page.goto("/programs/frm/exam-setup")

		await ready(page)
		await page.getByRole("button", { name: SAVE }).click()

		await expect(page.getByRole("alert")).toContainText(
			"Part II cannot be taken before Part I",
		)
		// Still the form, not an outcome: the member can act on it.
		await expect(page.getByRole("button", { name: SAVE })).toBeVisible()
		expect(org.hits("examSetupFees")).toBe(0)
	})
})
