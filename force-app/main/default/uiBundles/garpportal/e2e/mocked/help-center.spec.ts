import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { CaseSummary } from "@/api/help-center"
import { installMockOrg } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * Help Center journeys: the two tabs render with the case count on the pill,
 * the submit-a-case form posts the real `submitCase` body (trimmed) and lands
 * the member on My Requests where the refreshed list carries the new case,
 * and the requests tab renders the cases payload as rows.
 */

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

const OPEN_CASE: CaseSummary = {
	id: "500x1",
	caseNumber: "00001001",
	subject: "Exam voucher not applied",
	status: "New",
	createdDate: "2026-08-30T10:00:00.000Z",
}

const CLOSED_CASE: CaseSummary = {
	id: "500x2",
	caseNumber: "00000990",
	subject: "Update billing country",
	status: "Closed",
	createdDate: "2026-07-01T09:00:00.000Z",
}

const SUBMITTED_CASE: CaseSummary = {
	id: "500x3",
	caseNumber: "00001002",
	subject: "Certificate reprint",
	status: "New",
	createdDate: "2026-09-04T08:00:00.000Z",
}

function baseActions() {
	return {
		programs: programsListData(),
		alertBar: NO_ALERT,
		cases: [OPEN_CASE, CLOSED_CASE],
	}
}

test.describe("help center", () => {
	test("tabs render; Get Help is the default and the pill counts the cases", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: baseActions() })
		await page.goto("/help-center")

		await expect(
			page.getByRole("heading", { name: "Help Center", level: 1 }),
		).toBeVisible()

		// Get Help is selected by default and carries the case form.
		await expect(
			page.getByRole("tab", { name: "Get Help" }),
		).toHaveAttribute("aria-selected", "true")
		await expect(
			page.getByText("Open a support case", { exact: true }),
		).toBeVisible()
		await expect(page.getByRole("button", { name: "Submit" })).toBeVisible()

		// The requests pill counts the prefetched cases.
		await expect(
			page.getByRole("tab", { name: /My Requests/ }),
		).toContainText("2")

		// Switching tabs renders the cases payload as rows.
		await page.getByRole("tab", { name: /My Requests/ }).click()
		await expect(page).toHaveURL(/tab=requests/)
		await expect(page.getByText("00001001")).toBeVisible()
		await expect(page.getByText("Exam voucher not applied")).toBeVisible()
		await expect(page.getByText("00000990")).toBeVisible()
		await expect(page.getByText("Update billing country")).toBeVisible()
	})

	test("submit-a-case posts the trimmed body and lands on the refreshed requests list", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: { ...baseActions(), submitCase: SUBMITTED_CASE },
		})
		await page.goto("/help-center")

		await page
			.getByRole("textbox", { name: "Subject" })
			.fill("  Certificate reprint  ")
		await page
			.getByRole("textbox", { name: "Description" })
			.fill("  My FRM certificate arrived damaged — please reissue.  ")

		// The confirmed list the requests tab will show after the submit.
		org.use({
			actions: { cases: [SUBMITTED_CASE, OPEN_CASE, CLOSED_CASE] },
		})

		await page.getByRole("button", { name: "Submit" }).click()

		// The wire body is TRIMMED — the api layer owns that, not the form.
		await expect.poll(() => org.hits("submitCase")).toBe(1)
		expect(JSON.parse(org.of("submitCase")[0].postData ?? "{}")).toEqual({
			subject: "Certificate reprint",
			description: "My FRM certificate arrived damaged — please reissue.",
		})

		// The one explicit confirmation is the toast...
		await expect(
			page.getByText(/Thank you for your submission/),
		).toBeVisible()
		// ...and the member lands on My Requests, where the refreshed list
		// carries the new case with its number and status.
		await expect(page).toHaveURL(/tab=requests/)
		await expect(page.getByText("00001002")).toBeVisible()
		await expect(page.getByText("Certificate reprint")).toBeVisible()
		// The invalidation refetched the list rather than trusting the cache.
		expect(org.hits("cases")).toBeGreaterThanOrEqual(2)
	})
})
