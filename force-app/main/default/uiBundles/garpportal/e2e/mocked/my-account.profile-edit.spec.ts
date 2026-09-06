import { expect, test } from "@playwright/test"

import { accountView } from "@/testing/factories/account"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { personalInfoGraphqlResolvers } from "@/testing/factories/personal-info-graphql"
import type { CountryOption } from "@/api/personal-info/types"
import { installMockOrg, type MockOrgOptions } from "../support/mock-org"

/**
 * The Personal Information edit dialog on the account-information tab:
 * lazy GraphQL hydrate on open, prefill, clean cancel, and the
 * SavePersonalInfo mutation body.
 */

const EDIT_DATA = personalInfoEditData() // Ada Lovelace, 003-member/001-member
const COUNTRIES: CountryOption[] = [
	{ label: "United States", value: "United States", phoneCode: "+1" },
	{ label: "United Kingdom", value: "United Kingdom", phoneCode: "+44" },
]

function baseOptions(): MockOrgOptions {
	// The factory resolvers are written for MSW (they return `{ data }`);
	// the mock org wants the GraphQL `data` object itself — unwrap once here.
	const resolvers = personalInfoGraphqlResolvers(EDIT_DATA, COUNTRIES)
	return {
		actions: {
			account: accountView(),
			expertise: {
				statusCode: 200,
				statusMessage: null,
				values: {},
				options: {},
				labels: {},
			},
		},
		graphql: {
			PersonalInfoEditContact: resolvers.PersonalInfoEditContact().data,
			PersonalInfoCountries: resolvers.PersonalInfoCountries().data,
			SavePersonalInfo: {
				uiapi: {
					AccountUpdate: { success: true },
					ContactUpdate: { success: true },
				},
			},
		},
	}
}

test.describe("personal information edit dialog", () => {
	test("opens prefilled from the GraphQL contact and cancels without saving", async ({
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

		// The hydrate reads fire on open, not on tab mount.
		await expect.poll(() => org.hits("PersonalInfoEditContact")).toBe(1)
		await expect.poll(() => org.hits("PersonalInfoCountries")).toBe(1)

		await expect(dialog.getByRole("textbox", { name: "First name" })).toHaveValue(
			"Ada",
		)
		await expect(dialog.getByRole("textbox", { name: "Last name" })).toHaveValue(
			"Lovelace",
		)
		await expect(dialog.getByRole("textbox", { name: "Email" })).toHaveValue(
			"ada@example.org",
		)
		// sameAsBilling is DERIVED by the loader (addressesMatch), not read off
		// the wire — the factory's differing mailing address arrives unchecked.
		await expect(
			dialog.getByRole("checkbox", { name: /same as billing/ }),
		).not.toBeChecked()

		await page.keyboard.press("Escape")
		await expect(page.getByRole("dialog")).toHaveCount(0)
		expect(org.hits("SavePersonalInfo")).toBe(0)
	})

	test("saving posts SavePersonalInfo with the edited variables and closes", async ({
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

		expect(org.hits("SavePersonalInfo")).toBe(1)
		const body = JSON.parse(org.of("SavePersonalInfo")[0].postData ?? "{}") as {
			variables?: Record<string, unknown>
		}
		expect(body.variables).toMatchObject({
			firstName: "Grace",
			lastName: "Lovelace",
			email: "ada@example.org",
			// contactId comes from the account identity; accountId from the hydrate.
			contactId: "003xx0000001",
			accountId: "001-member",
			billingCity: "Hoboken",
			// sameAsBilling arrives false (derived, addresses differ), so the
			// mailing block ships as typed rather than copied from billing.
			mailingCity: "Boston",
			mailingStreet: "2 Ship St",
		})
	})
})
