import { expect, test } from "@playwright/test"

import { accountView } from "@/testing/factories/account"
import { identity } from "@/testing/factories/identity"
import { installMockOrg } from "../support/mock-org"
import { MEMBER } from "../support/identity"

/**
 * Contact Preferences tab: the ContactPreferences GraphQL read renders the
 * cards, and an SMS checkbox toggle posts the UpdateSmsPreferences mutation
 * then refetches the read.
 */

/** GraphQL `data` for the ContactPreferences read (wire-shaped). */
function contactPreferencesData(overrides: {
	smsPromotional: boolean
	smsRegistration: boolean
}) {
	return {
		uiapi: {
			query: {
				Contact: {
					edges: [
						{
							node: {
								Id: MEMBER.contactId,
								Email: { value: "ada@example.com" },
								MobilePhone: { value: "5550001" },
								Mobile_Phone_Code__c: { value: "1" },
								SMS_Promotional_Updates__c: {
									value: overrides.smsPromotional,
								},
								SMS_Registration_Updates__c: {
									value: overrides.smsRegistration,
								},
							},
						},
					],
				},
			},
		},
	}
}

test.describe("contact preferences", () => {
	test("renders from the ContactPreferences payload and saves an SMS toggle", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: { account: accountView() },
			graphql: {
				ContactPreferences: contactPreferencesData({
					smsPromotional: false,
					smsRegistration: true,
				}),
				UpdateSmsPreferences: {
					uiapi: {
						ContactUpdate: {
							success: true,
							Record: {
								SMS_Promotional_Updates__c: { value: true },
								SMS_Registration_Updates__c: { value: true },
							},
						},
					},
				},
			},
		})
		await page.goto("/my-account?tab=contact-preferences")

		await expect(
			page.getByText("Email Preferences", { exact: true }),
		).toBeVisible()
		await expect(page.getByText("ada@example.com")).toBeVisible()
		await expect(page.getByText("+1 5550001")).toBeVisible()

		const registration = page.getByRole("checkbox", {
			name: /time-sensitive information/,
		})
		const promotional = page.getByRole("checkbox", {
			name: /marketing and promotional/,
		})
		await expect(registration).toBeChecked()
		await expect(promotional).not.toBeChecked()
		expect(org.hits("ContactPreferences")).toBe(1)
		expect(org.hits("orders")).toBe(0)

		// The save invalidates + refetches the read — serve the new truth so the
		// checkbox does not visually revert once the optimistic draft clears.
		org.use({
			graphql: {
				ContactPreferences: contactPreferencesData({
					smsPromotional: true,
					smsRegistration: true,
				}),
			},
		})
		await promotional.click()

		await expect.poll(() => org.hits("UpdateSmsPreferences")).toBe(1)
		const call = org.of("UpdateSmsPreferences")[0]
		const body = JSON.parse(call.postData ?? "{}") as {
			variables?: Record<string, unknown>
		}
		expect(body.variables).toMatchObject({
			// On localhost the session resolves via the local-CLI /me fallback,
			// which prefers the payload's identity.contactId over the top-level
			// contactId — so the mutation carries the identity() factory's id.
			contactId: identity().contactId,
			smsPromotional: true,
			smsRegistration: true,
		})
		await expect.poll(() => org.hits("ContactPreferences")).toBe(2)
		await expect(promotional).toBeChecked()
	})
})
