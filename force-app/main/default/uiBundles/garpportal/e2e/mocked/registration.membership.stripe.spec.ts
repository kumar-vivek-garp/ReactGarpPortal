import { expect, test, type Route } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import { accountOptionsView } from "@/testing/factories/account-options"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { examRegisterResult, verifyCustomerResult } from "@/testing/factories/exam"
import { demographicsOptions } from "@/testing/factories/exam-payment"
import {
	membershipFeesResult,
	membershipLoad,
} from "@/testing/factories/membership-registration"
import {
	accountViewFromPersonalInfo,
	billingCompanyGraphql,
	personalInfoEditData,
	portalAddressFields,
} from "@/testing/factories/personal-info"
import { installMockOrg, type MockOrgOptions } from "../support/mock-org"

/**
 * The membership CARD leg. The auto-renew consent is offered on a card
 * order (unticked), rides `register` as `autoRenew`, and the checkout hands
 * off with a successUrl that returns to THIS route — `/membership/register`,
 * not `/programs/…`. Coming back cold with all-numeric params shows the
 * confirmation with no form and no writes, on BOTH twins: the public route's
 * guard must not bounce a member's payment return either.
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

const PROFILE = personalInfoEditData({
	mailing: portalAddressFields(),
	sameAsBilling: true,
})

const WRITE_KEYS = [
	"verifyCustomer",
	"verifyAddress",
	"register",
	"checkout",
	"payOrder",
	"paymentStatus",
] as const

function parse(postData: string | null): Record<string, any> {
	return JSON.parse(postData ?? "{}")
}

async function priceCart(route: Route) {
	const body = parse(route.request().postData())
	await route.fulfill({
		json: memberPortalEnvelope(
			membershipFeesResult({ riskNet: body.riskNetSelected === true }),
		),
	})
}

function stripeOptions(): MockOrgOptions {
	return {
		actions: {
			alertBar: NO_ALERT,
			account: accountViewFromPersonalInfo(PROFILE),
			options: accountOptionsView(),
		},
		graphql: { BillingCompany: billingCompanyGraphql(PROFILE) },
		examreg: {
			info: membershipLoad({
				isAuthenticated: true,
				contact: { id: "003-member" },
			}),
			fees: priceCart,
			verifyCustomer: verifyCustomerResult(),
			register: examRegisterResult({ registrationId: null, contractId: null }),
			// Relative on purpose: keeps the handoff on the static e2e server.
			checkout: { checkoutUrl: "/e2e-checkout-stub", orderId: "801-order" },
			payOrder: { completed: true },
			paymentStatus: {
				isOrderFound: true,
				isPaymentFound: true,
				isPaymentSuccess: true,
			},
			demographics: demographicsOptions(),
			options: { companies: [], schools: [] },
		},
	}
}

test.describe("membership stripe leg", () => {
	test("auto-renew rides register, and checkout returns to /membership/register", async ({
		page,
	}) => {
		test.slow()
		const org = await installMockOrg(page, stripeOptions())
		await page.goto("/membership/register")

		await expect(page.getByText("$195.00").first()).toBeVisible()
		await page.getByRole("radio", { name: "Card", exact: true }).click()
		await expect(page.getByText("Billing & shipping")).toHaveCount(0)

		const consent = page.getByRole("checkbox", {
			name: /Membership Automatic Renewal/,
		})
		await expect(consent).not.toBeChecked()
		await consent.click()

		const submit = page.getByRole("button", { name: "Pay and Register" })
		await expect(submit).toBeEnabled()
		await submit.click()
		const dialog = page.getByRole("dialog")
		await expect(
			dialog.getByText("You will be taken to our payment provider to pay."),
		).toBeVisible()
		expect(org.hits("register")).toBe(0)
		await dialog.getByRole("button", { name: "Pay and Register" }).click()

		await expect(page).toHaveURL(/\/e2e-checkout-stub$/)

		expect(parse(org.of("register")[0].postData)).toMatchObject({
			type: "mem",
			autoRenew: true,
			paymentType: "Stripe",
			riskNetSelected: false,
		})

		const checkoutBody = parse(org.of("checkout")[0].postData)
		expect(checkoutBody.orderId).toBe("801-order")
		const successUrl = String(checkoutBody.successUrl)
		expect(successUrl).toContain("/membership/register?")
		expect(successUrl).toContain("stripe_return=1")
		expect(successUrl).toContain("oid=801-order")
		expect(successUrl).not.toContain("/programs/")
		expect(String(checkoutBody.cancelUrl)).toContain(
			"/membership/register?checkout_cancelled=1&oid=801-order",
		)

		expect(
			org.calls
				.filter(
					(call) =>
						call.kind === "examreg" &&
						(WRITE_KEYS as readonly string[]).includes(call.key),
				)
				.map((call) => call.key),
		).toEqual(["verifyCustomer", "register", "checkout"])
		expect(org.hits("verifyAddress")).toBe(0)
		expect(org.hits("payOrder")).toBe(0)
	})

	test("payment-return cold load on the member twin: confirmation, zero writes, numeric params", async ({
		page,
	}) => {
		const org = await installMockOrg(page, stripeOptions())

		await page.goto("/membership/register?stripe_return=1&oid=801&on=1234")

		await expect(page.getByText("Thank you — payment received")).toBeVisible()
		await expect(page.getByText("1234", { exact: true })).toBeVisible()
		await expect(page.getByRole("button", { name: "Pay and Register" })).toHaveCount(0)

		expect(parse(org.of("paymentStatus")[0].postData)).toEqual({ orderId: "801" })
		for (const key of WRITE_KEYS) {
			expect(org.hits(key)).toBe(key === "paymentStatus" ? 1 : 0)
		}
		expect(org.hits("fees")).toBe(0)
		expect(org.hits("info")).toBe(0)
	})

	test("a MEMBER's payment return on the public twin is not bounced", async ({
		page,
	}) => {
		const org = await installMockOrg(page, stripeOptions())

		await page.goto("/registration/membership?stripe_return=1&oid=801&on=1234")

		// The guard suppresses its redirect on a payment return — the order
		// behind this URL is already charged and the params must survive.
		await expect(page).toHaveURL(/\/registration\/membership\?/)
		await expect(page.getByText("Thank you — payment received")).toBeVisible()
		await expect(page.getByText("1234", { exact: true })).toBeVisible()
		for (const key of WRITE_KEYS) {
			expect(org.hits(key)).toBe(key === "paymentStatus" ? 1 : 0)
		}
	})
})
