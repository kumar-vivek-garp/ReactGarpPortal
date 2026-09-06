import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import {
	examSetupSaveResult,
	examSetupView,
} from "@/testing/factories/exam-setup"
import { installMockOrg } from "../support/mock-org"
import { dashboardActionSet } from "../support/payloads"

/**
 * Exam setup wizard journeys: the form renders from `examSetup`, moving the
 * administration trips the fee gate BEFORE anything is written, a free
 * site-only change saves through the real `examSetupId` action with the exact
 * body Apex reads, and a save that wants scheduling lands on the MyGarp
 * hand-off because `EXAM_SETUP_AUTHORIZE_ENABLED` is off at build time — so
 * `examSetupAuthorize` must never be called.
 */

/** No floating alert over the wizard's sticky controls (see programs.spec.ts). */
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

function examSetupActions(
	overrides: Record<string, unknown> = {},
): Record<string, unknown> {
	return {
		...dashboardActionSet(),
		alertBar: NO_ALERT,
		examSetup: examSetupView(),
		examSetupId: examSetupSaveResult(),
		...overrides,
	}
}

test.describe("exam setup", () => {
	test("the form renders the current sitting and both wizard steps", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: examSetupActions() })
		await page.goto("/programs/frm/exam-setup")

		await expect(page.getByText("Choose your sitting")).toBeVisible()
		await expect(page.getByText("Confirm your ID")).toBeVisible()

		// The selects start on where the member sits today (May, London).
		await expect(
			page.getByRole("combobox", { name: "Exam date" }),
		).toContainText("May 2026")
		await expect(
			page.getByRole("combobox", { name: "Exam site" }),
		).toContainText("London")

		// ID on file (blank box = keep it), so the save is offered immediately.
		await expect(
			page.getByRole("button", { name: "Save and continue" }),
		).toBeEnabled()
		expect(org.hits("examSetup")).toBe(1)
	})

	test("moving the administration trips the fee gate before any write", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: examSetupActions() })
		await page.goto("/programs/frm/exam-setup")

		await page.getByRole("combobox", { name: "Exam date" }).click()
		await page.getByRole("option", { name: "November 2026" }).click()

		// The gate replaces the submit button — nothing may be posted from here.
		await expect(page.getByText("This change has a fee")).toBeVisible()
		await expect(
			page.getByRole("button", { name: "Save and continue" }),
		).toBeHidden()

		await page.getByRole("button", { name: "Keep my current date" }).click()
		await expect(
			page.getByRole("combobox", { name: "Exam date" }),
		).toContainText("May 2026")
		await expect(
			page.getByRole("button", { name: "Save and continue" }),
		).toBeVisible()

		expect(org.hits("examSetupId")).toBe(0)
	})

	test("a free site change saves through examSetupId with the exact body", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: examSetupActions() })
		await page.goto("/programs/frm/exam-setup")

		// Same administration, different site — the free change, no gate.
		await page.getByRole("combobox", { name: "Exam site" }).click()
		await page.getByRole("option", { name: "Paris" }).click()
		await page.getByRole("button", { name: "Save and continue" }).click()

		await expect(
			page.getByText("Your exam setup is complete"),
		).toBeVisible()
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
		// The blank ID box means "keep what you have": no number travels, and
		// idType/expiry travel with the number or not at all.
		expect(body.id.idNumber).toBeUndefined()
		expect(body.id.idType).toBeUndefined()
		expect(body.id.idName).toBe("Ada Lovelace")
	})

	test("a scheduling-required save hands off to MyGarp without calling authorize", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: examSetupActions({
				examSetupId: examSetupSaveResult({
					nextScreen: "Check Authorization",
					schedulingRequired: true,
				}),
			}),
		})
		await page.goto("/programs/frm/exam-setup")

		await page.getByRole("combobox", { name: "Exam site" }).click()
		await page.getByRole("option", { name: "Paris" }).click()
		await page.getByRole("button", { name: "Save and continue" }).click()

		// EXAM_SETUP_AUTHORIZE_ENABLED is a build-time false: the provider push
		// is an outbound integration, so the built app must offer MyGarp and
		// call nothing. The authorized/pending/exhausted legs are unreachable
		// in dist/ and stay covered by exam-setup-panel.authorize.test.tsx.
		await expect(page.getByText("One more step, in MyGarp")).toBeVisible()
		await expect(
			page.getByRole("link", { name: "Continue in MyGarp" }),
		).toBeVisible()
		expect(org.hits("examSetupAuthorize")).toBe(0)
	})
})
