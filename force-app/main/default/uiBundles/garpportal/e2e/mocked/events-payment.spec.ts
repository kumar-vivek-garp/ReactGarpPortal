import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { CheckoutResult } from "@/api/registration/exam-types"
import {
	eventContact,
	eventLoad,
	eventRates,
	eventRegisterResult,
} from "@/testing/factories/event"
import {
	accountViewFromPersonalInfo,
	billingCompanyGraphql,
	personalInfoEditData,
} from "@/testing/factories/personal-info"
import { installMockOrg, type MockOrgOptions } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * The paid event legs: register → confirm dialog → shared `/checkout` handoff
 * with both return addresses in the body, the cancelled-checkout return that
 * rolls the staged order back exactly once, and the payment-success return
 * that renders confirmation without ever re-posting a registration.
 */

function alertBarIdle(): AlertBarView {
	return {
		statusMessage: "No alerts found",
		statusCode: 200,
		examType: null,
		examPart: null,
		alertStatus: null,
		deadline: null,
		orderId: null,
		route: null,
	}
}

function memberBaseline(): Pick<MockOrgOptions, "actions" | "graphql"> {
	const profile = personalInfoEditData()
	return {
		actions: {
			programs: programsListData(),
			alertBar: alertBarIdle(),
			account: accountViewFromPersonalInfo(profile),
		},
		graphql: { BillingCompany: billingCompanyGraphql(profile) },
	}
}

test.describe("paid event registration", () => {
	test("register answers isFree:false, checkout gets both return URLs, and the browser leaves for the hosted page", async ({
		page,
	}) => {
		// RELATIVE checkoutUrl on purpose: the redirect must stay on the static
		// e2e server so the landing can be asserted.
		const checkout: CheckoutResult = { checkoutUrl: "/e2e-checkout-stub" }
		const org = await installMockOrg(page, {
			...memberBaseline(),
			examreg: {
				"event/info": eventLoad({
					isAuthenticated: true,
					contact: eventContact(),
					rates: eventRates({ amountDue: 150, memberAmount: 150 }),
				}),
				"event/register": eventRegisterResult({
					isFree: false,
					orderId: "801",
					orderNumber: "ON-801",
					amountDue: 150,
				}),
				checkout,
			},
		})
		await page.goto("/events/event/E1/register")

		await expect(page.getByText("Contact details")).toBeVisible()
		await page.getByRole("checkbox", { name: /GARP Privacy Notice/ }).click()

		// A paid submit is staged behind the confirm dialog — the figure gets
		// one more look before the unretryable write.
		const submit = page.getByRole("button", { name: "Continue to Payment" })
		await expect(submit).toBeEnabled()
		await submit.click()
		const dialog = page.getByRole("dialog")
		await expect(
			dialog.getByRole("heading", { name: "Confirm your registration" }),
		).toBeVisible()
		expect(org.hits("event/register")).toBe(0)

		await dialog.getByRole("button", { name: "Confirm and Pay" }).click()

		// The handoff leaves the app for the (stubbed) hosted checkout page.
		await page.waitForURL("**/e2e-checkout-stub")

		expect(org.hits("event/register")).toBe(1)
		await expect.poll(() => org.hits("checkout")).toBe(1)
		const body = JSON.parse(org.of("checkout")[0].postData ?? "{}") as {
			orderId?: string
			successUrl?: string
			cancelUrl?: string
		}
		expect(body.orderId).toBe("801")
		// Success returns to the SAME route carrying stripe_return/oid/on…
		expect(body.successUrl).toContain(
			"/events/event/E1/register?stripe_return=1&oid=801&on=ON-801",
		)
		// …and — unlike the exam flow — cancel is not bare: it carries the oid
		// the rollback depends on.
		expect(body.cancelUrl).toContain(
			"/events/event/E1/register?checkout_cancelled=1&oid=801",
		)
	})

	test("a cancelled checkout return rolls the order back exactly once and offers a restart", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			...memberBaseline(),
			examreg: {
				"event/info": eventLoad({
					isAuthenticated: true,
					contact: eventContact(),
				}),
				"event/rollback": {},
			},
		})
		await page.goto("/events/event/E1/register?checkout_cancelled=1&oid=801")

		await expect(
			page.getByRole("heading", { name: "Registration not completed" }),
		).toBeVisible()
		await expect(
			page.getByText(/nothing was charged and no place was held/),
		).toBeVisible()
		// The way back in is a full reload of the route, post-rollback.
		await expect(page.getByRole("link", { name: "Start again" })).toBeVisible()
		// The form never renders behind the cancelled leg.
		await expect(
			page.getByRole("checkbox", { name: /GARP Privacy Notice/ }),
		).toHaveCount(0)

		// Fired on mount, exactly once (prod build has no StrictMode double
		// effect, and the panel's ref guards the replay regardless), with the
		// oid coerced back to a string and the cancelled-checkout reason.
		await expect.poll(() => org.hits("event/rollback")).toBe(1)
		const body: unknown = JSON.parse(
			org.of("event/rollback")[0].postData ?? "{}",
		)
		expect(body).toEqual({ orderId: "801", reason: "Checkout cancelled" })
		await page.waitForTimeout(250)
		expect(org.hits("event/rollback")).toBe(1)
	})

	test("a payment return renders the confirmation without re-posting a registration", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			...memberBaseline(),
			examreg: {
				"event/info": eventLoad({
					isAuthenticated: true,
					contact: eventContact(),
				}),
			},
		})
		// `on` is purely numeric on purpose — the router JSON-parses search
		// values, and the schema must coerce it back rather than drop it.
		await page.goto("/events/event/E1/register?stripe_return=1&oid=801&on=1234")

		await expect(
			page.getByRole("heading", { name: "Payment received" }),
		).toBeVisible()
		// `exact` matters: the sidebar's "(GARP ID 123456)" substring-matches.
		await expect(page.getByText("1234", { exact: true })).toBeVisible()

		// The order is already charged; nothing may write or roll back here.
		expect(org.hits("event/register")).toBe(0)
		expect(org.hits("event/rollback")).toBe(0)
		expect(org.hits("checkout")).toBe(0)
	})
})
