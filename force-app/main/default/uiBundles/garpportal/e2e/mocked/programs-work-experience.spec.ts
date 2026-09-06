import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import {
	cvView,
	experienceFormView,
} from "@/testing/factories/work-experience"
import { installMockOrg } from "../support/mock-org"
import { dashboardActionSet } from "../support/payloads"

/**
 * Work Experience journeys: the CV panel renders its three steps from `cv`,
 * and Add experience opens the dialog whose blank form and picklists come
 * from the real `cvExperience` action.
 */

/** No floating alert over the page (see programs.spec.ts). */
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

function cvActions(): Record<string, unknown> {
	return {
		...dashboardActionSet(),
		alertBar: NO_ALERT,
		cv: cvView(),
		cvExperience: experienceFormView(),
	}
}

test.describe("work experience", () => {
	test("the CV panel renders the logged role, address, and submit step", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: cvActions() })
		await page.goto("/programs/frm/work-experience")

		await expect(page.getByText("Work Experience")).toBeVisible()
		await expect(page.getByText("In progress")).toBeVisible()

		// The logged role from the factory's in-progress CV.
		await expect(page.getByText("Risk Analyst")).toBeVisible()
		await expect(page.getByText(/Abrdn plc/)).toBeVisible()

		// The delivery address already on file collapses step 2 to a summary.
		await expect(page.getByText("Added", { exact: true })).toBeVisible()

		// Still editable, so the add control is offered.
		await expect(
			page.getByRole("button", { name: "Add experience" }),
		).toBeVisible()

		expect(org.hits("cv")).toBe(1)
		expect(org.of("cv")[0].url).toContain("programType=FRM")
	})

	test("Add experience opens the dialog blank, seeded by cvExperience", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: cvActions() })
		await page.goto("/programs/frm/work-experience")

		await page.getByRole("button", { name: "Add experience" }).click()

		const dialog = page.getByRole("dialog")
		await expect(dialog).toBeVisible()
		await expect(
			dialog.getByRole("heading", { name: "Add experience" }),
		).toBeVisible()

		// The Add form is the blank row — nothing prefilled from the saved one.
		await expect(dialog.getByLabel("Organisation")).toHaveValue("")
		await expect(dialog.getByLabel("Job title")).toHaveValue("")

		// The picklists came from the server, not a hard-coded list.
		await dialog.getByRole("combobox", { name: "Job function" }).click()
		await expect(
			page.getByRole("option", { name: "Risk Management" }),
		).toBeVisible()
		await expect(
			page.getByRole("option", { name: "Education/Training" }),
		).toBeVisible()
		await page.keyboard.press("Escape")

		// The blank form fetched the picklists WITHOUT an experienceId — a
		// blank id is what makes Apex answer the Add shape.
		await expect.poll(() => org.hits("cvExperience")).toBeGreaterThanOrEqual(1)
		const call = org.of("cvExperience")[0]
		expect(call.url).toContain("programType=FRM")
		expect(call.url).not.toContain("experienceId")
	})
})
