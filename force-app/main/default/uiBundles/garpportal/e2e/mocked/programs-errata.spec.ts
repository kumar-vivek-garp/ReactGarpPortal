import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { ErrataFormView, ErrataSubmitResult } from "@/api/errata"
import { installMockOrg } from "../support/mock-org"
import { dashboardActionSet } from "../support/payloads"

/**
 * Curriculum errata journeys: the form renders its dependent cascade from
 * `errataForm`, and a filled report posts through the real `submitErrata`
 * action with the inverted studyMaterial/book body Apex triages on.
 */

/** No floating alert over the form (see programs.spec.ts). */
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

/**
 * `GET errataForm?programType=frm` — the dependent picklist. Map key =
 * study material, values = the books inside it. Not in payloads.ts because
 * only this module reads it.
 */
const ERRATA_FORM_DATA = {
	statusMessage: null,
	statusCode: 200,
	errataPicklistOption: {
		Books: [
			"Book 1: Foundations of Risk Management",
			"Book 2: Quantitative Analysis",
		],
		"Practice Exams": ["2026 FRM Practice Exam"],
	},
} satisfies ErrataFormView

const SUBMIT_RESULT = {
	statusMessage: null,
	statusCode: 200,
	errataId: "a0X000000000001AAA",
} satisfies ErrataSubmitResult

function errataActions(): Record<string, unknown> {
	return {
		...dashboardActionSet(),
		alertBar: NO_ALERT,
		errataForm: ERRATA_FORM_DATA,
		submitErrata: SUBMIT_RESULT,
	}
}

test.describe("errata", () => {
	test("the report form renders the sheet card and the cascade's materials", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: errataActions() })
		await page.goto("/programs/frm/errata")

		await expect(page.getByText("Curriculum errata")).toBeVisible()
		// FRM has a published sheet, so the check-first card offers it.
		await expect(
			page.getByRole("heading", { name: "Check the published sheet first" }),
		).toBeVisible()
		await expect(
			page.getByRole("link", { name: /Download FRM errata/ }),
		).toBeVisible()

		await expect(
			page.getByRole("heading", { name: "Report an error" }),
		).toBeVisible()

		// The book select waits on a material; its hint says so.
		await expect(
			page.getByText("Choose a study material first."),
		).toBeVisible()

		expect(org.hits("errataForm")).toBe(1)
		expect(org.of("errataForm")[0].url).toContain("programType=frm")
	})

	test("filling the cascade and submitting posts the inverted submitErrata body", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: errataActions() })
		await page.goto("/programs/frm/errata")

		await page
			.getByRole("combobox", { name: /What study material/ })
			.click()
		await page.getByRole("option", { name: "Books", exact: true }).click()

		await page.getByRole("combobox", { name: /What book/ }).click()
		await page
			.getByRole("option", { name: "Book 2: Quantitative Analysis" })
			.click()

		await page
			.getByLabel(/What page was the error on/)
			.fill("184")
		await page
			.getByLabel(/Describe the problem/)
			.fill("Formula 3.2 transposes the variance terms.")
		// Correction stays blank — the only optional field travels as null.

		await page.getByRole("button", { name: "Submit report" }).click()

		// The form swaps to the receipt, not a toast.
		await expect(
			page.getByText("Thanks — your report has been sent"),
		).toBeVisible()
		await expect.poll(() => org.hits("submitErrata")).toBe(1)

		const call = org.of("submitErrata")[0]
		expect(call.method).toBe("POST")
		// The inversion Apex triages on: the map KEY travels as
		// `studyMaterial`, the dependent value as `book` — and programType is
		// upper-cased on the way out.
		expect(JSON.parse(call.postData ?? "{}")).toEqual({
			programType: "FRM",
			studyMaterial: "Books",
			book: "Book 2: Quantitative Analysis",
			pageNumber: "184",
			errorDescription: "Formula 3.2 transposes the variance terms.",
			correction: null,
		})

		// No file was chosen, so the second call of the pair never fires.
		expect(org.hits("attachErrataFile")).toBe(0)
	})
})
