import { expect, test, type Route } from "@playwright/test"

import { accountView, completeness } from "@/testing/factories/account"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { installMockOrg } from "../support/mock-org"

/**
 * Contact Preferences tab: it renders off the composed account payload, and
 * an SMS checkbox toggle posts both consents through the `profile` action,
 * then refetches the account view.
 */

test.describe("contact preferences", () => {
	test("renders from the account payload and saves an SMS toggle through profile", async ({
		page,
	}) => {
		const state = { smsPromotional: false, smsRegistration: true }
		const org = await installMockOrg(page, {
			actions: {
				// Responders, so each read reflects what the write before it stored.
				account: (route: Route) =>
					route.fulfill({
						json: memberPortalEnvelope(
							accountView({
								personal: {
									email: "ada@example.com",
									mobilePhone: "5550001",
									mobilePhoneCode: "United States (+1)",
								},
								preferences: { ...state },
							}),
						),
					}),
				profile: (route: Route) => {
					const body = JSON.parse(route.request().postData() ?? "{}") as {
						values: Record<string, boolean>
					}
					state.smsPromotional = body.values.SMS_Promotional_Updates__c
					state.smsRegistration = body.values.SMS_Registration_Updates__c
					return route.fulfill({
						json: {
							status: "Success",
							statusCode: 200,
							errorMessage: null,
							data: {
								applied: Object.keys(body.values),
								rejected: [],
								completeness: completeness(),
							},
						},
					})
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
		expect(org.hits("account")).toBe(1)
		expect(org.hits("orders")).toBe(0)

		await promotional.click()

		await expect.poll(() => org.hits("profile")).toBe(1)
		expect(JSON.parse(org.of("profile")[0].postData ?? "{}")).toEqual({
			values: {
				SMS_Promotional_Updates__c: true,
				SMS_Registration_Updates__c: true,
			},
		})
		// The save invalidates + refetches the account view, which now carries
		// the new truth — so the checkbox does not revert once the draft clears.
		await expect.poll(() => org.hits("account")).toBe(2)
		await expect(promotional).toBeChecked()
	})
})
