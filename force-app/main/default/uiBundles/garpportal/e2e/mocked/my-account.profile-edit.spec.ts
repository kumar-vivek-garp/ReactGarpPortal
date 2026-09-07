import { expect, test } from "@playwright/test"

import { accountOptionsView } from "@/testing/factories/account-options"
import { completeness } from "@/testing/factories/account"
import {
	accountViewFromPersonalInfo,
	billingCompanyGraphql,
	personalInfoEditData,
} from "@/testing/factories/personal-info"
import { installMockOrg, type MockOrgOptions } from "../support/mock-org"

function body(postData: string | null): Record<string, unknown> {
	return JSON.parse(postData ?? "{}") as Record<string, unknown>
}

/**
 * The Personal Information edit dialog on the account-information tab: it
 * hydrates from the composed account payload the tab already holds (plus the
 * one billing-company read), prefills, cancels cleanly, and saves through the
 * `profile` (changed identity fields only) then `addresses` actions.
 */

const EDIT_DATA = personalInfoEditData({
	billing: { ...personalInfoEditData().billing, company: "Analytical Engines" },
})

function baseOptions(): MockOrgOptions {
	return {
		actions: {
			account: accountViewFromPersonalInfo(EDIT_DATA),
			options: accountOptionsView(),
			expertise: {
				statusCode: 200,
				statusMessage: null,
				values: {},
				options: {},
				labels: {},
			},
			profile: { applied: ["FirstName"], rejected: [], completeness: completeness() },
			addresses: {
				statusMessage: "Success",
				statusCode: 200,
				appliedBillingToMailing: false,
			},
		},
		graphql: { BillingCompany: billingCompanyGraphql(EDIT_DATA) },
	}
}

test.describe("personal information edit dialog", () => {
	test("opens prefilled from the account payload and cancels without saving", async ({
		page,
	}) => {
		const org = await installMockOrg(page, baseOptions())
		await page.goto("/my-account")

		await page.getByRole("button", { name: "Edit Profile" }).click()

		const dialog = page.getByRole("dialog")
		await expect(dialog).toBeVisible()
		await expect(
			dialog.getByRole("heading", { name: "Edit Personal Information" }),
		).toBeVisible()

		await expect(dialog.getByRole("textbox", { name: "First name" })).toHaveValue(
			"Ada",
		)
		await expect(dialog.getByRole("textbox", { name: "Last name" })).toHaveValue(
			"Lovelace",
		)
		await expect(dialog.getByRole("textbox", { name: "Email" })).toHaveValue(
			"ada@example.org",
		)
		// The billing company comes from its own read, never blanked.
		await expect(
			dialog.getByRole("textbox", { name: "Company" }).first(),
		).toHaveValue("Analytical Engines")
		// Same-as-billing is the server's verdict: the factory's differing
		// mailing address arrives unchecked.
		await expect(
			dialog.getByRole("checkbox", { name: /same as billing/ }),
		).not.toBeChecked()

		// Opening added no account read — the tab's own payload is reused —
		// and exactly one billing-company read.
		expect(org.hits("account")).toBe(1)
		expect(org.hits("options")).toBe(1)
		expect(org.hits("BillingCompany")).toBe(1)

		await page.keyboard.press("Escape")
		await expect(page.getByRole("dialog")).toHaveCount(0)
		expect(org.hits("profile")).toBe(0)
		expect(org.hits("addresses")).toBe(0)
	})

	test("saving posts the changed field to profile, then addresses, and closes", async ({
		page,
	}) => {
		const org = await installMockOrg(page, baseOptions())
		await page.goto("/my-account")

		await page.getByRole("button", { name: "Edit Profile" }).click()
		const dialog = page.getByRole("dialog")
		const firstName = dialog.getByRole("textbox", { name: "First name" })
		await expect(firstName).toHaveValue("Ada")

		await firstName.fill("Grace")
		await dialog.getByRole("button", { name: "Save" }).click()

		await expect(page.getByText("Personal information saved")).toBeVisible()
		await expect(page.getByRole("dialog")).toHaveCount(0)

		expect(org.hits("profile")).toBe(1)
		expect(body(org.of("profile")[0].postData)).toEqual({
			values: { FirstName: "Grace" },
		})

		expect(org.hits("addresses")).toBe(1)
		expect(body(org.of("addresses")[0].postData)).toMatchObject({
			isBillingAndMailingAddressSame: false,
			billingAddress: { city: "Hoboken", company: "Analytical Engines" },
			mailingAddress: { city: "Boston", street1: "2 Ship St" },
		})
		// The save invalidates the account view, which refetches once.
		await expect.poll(() => org.hits("account")).toBe(2)
	})
})
