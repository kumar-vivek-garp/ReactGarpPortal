import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { RegistrationCountry } from "@/api/registration/exam-types"
import { accountOptionsView } from "@/testing/factories/account-options"
import {
	examLoad,
	examRegisterResult,
	feesResult,
	verifyCustomerResult,
} from "@/testing/factories/exam"
import { demographicsOptions } from "@/testing/factories/exam-payment"
import {
	accountViewFromPersonalInfo,
	billingCompanyGraphql,
	personalInfoEditData,
	portalAddressFields,
} from "@/testing/factories/personal-info"
import { installMockOrg, type MockOrgOptions } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * The Stripe (billed card) leg. Three sacred properties, each its own test:
 *
 * 1. The checkout POST carries an honest return contract — a successUrl the
 *    provider can come back to (`stripe_return=1&oid` on the register page,
 *    NO order number: the status poll answers with it) and a cancelUrl that
 *    carries `checkout_cancelled=1&oid` so the page can roll the order back
 *    — and a relative checkoutUrl actually navigates the browser away. No
 *    verifyAddress (card orders collect the address at Stripe), no payOrder,
 *    no paymentStatus.
 * 2. Coming back to the successUrl POLLS paymentStatus before confirming,
 *    then shows the optional survey before the closing copy — without a
 *    second register and without payOrder ever firing.
 * 3. A COLD payment-return load (fresh page, no React state, all-numeric
 *    params that arrive as JSON numbers) shows the confirmation before any
 *    form, and the status poll is the ONLY call it makes — the order behind
 *    it is already charged.
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

/** Card must actually be permitted, or the Stripe tile renders disabled. */
const UNITED_STATES: RegistrationCountry = {
	id: "cc-us",
	name: "United States",
	countryCode: "United States",
	phoneCode: "1",
	creditCardAllowed: true,
	wireAllowed: true,
	achAllowed: true,
	provinces: [{ name: "NJ" }, { name: "NY" }],
	provinceRequired: true,
	postalCodeRequired: true,
}

/** Mailing mirrors billing so the loader derives same-as-billing = true. */
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

function stripeOptions(): MockOrgOptions {
	return {
		actions: {
			programs: programsListData(),
			alertBar: NO_ALERT,
			account: accountViewFromPersonalInfo(PROFILE),
			// The member survey's picklists.
			options: accountOptionsView(),
		},
		graphql: { BillingCompany: billingCompanyGraphql(PROFILE) },
		examreg: {
			info: examLoad({
				isAuthenticated: true,
				contact: { id: "003-member" },
				countries: [UNITED_STATES],
			}),
			fees: feesResult(750),
			verifyCustomer: verifyCustomerResult(),
			register: examRegisterResult(),
			// Relative on purpose: keeps the handoff on the static e2e server.
			checkout: { checkoutUrl: "/e2e-checkout-stub", orderId: "801-order" },
			payOrder: { completed: true },
			// The order's own answer on the return leg — no order number here, so
			// the cold-load test can prove the legacy `on` param still renders.
			paymentStatus: {
				isOrderFound: true,
				isPaymentFound: true,
				isPaymentSuccess: true,
			},
			// The guest survey's own picklists; the `options` lists are hints.
			demographics: demographicsOptions(),
			options: { companies: [], schools: [] },
		},
	}
}

function parse(postData: string | null): Record<string, any> {
	return JSON.parse(postData ?? "{}")
}

test.describe("stripe checkout leg", () => {
	test("card order hands off with honest success/cancel URLs, then the return confirms without re-writing", async ({
		page,
	}) => {
		test.slow()
		const org = await installMockOrg(page, stripeOptions())
		await page.goto("/programs/frm/register")

		// Complete the exam choice; the member record covers everything else.
		await page.getByRole("combobox", { name: "Exam part" }).click()
		await page
			.getByRole("option", { name: "FRM Exam Part I", exact: true })
			.click()
		await page.getByRole("combobox", { name: "Where you will sit" }).click()
		await page.getByRole("option", { name: "Boston" }).click()

		// Card payment: no address card mounts — Stripe collects it — and the
		// submit relabels to the card wording.
		await page.getByRole("radio", { name: "Card", exact: true }).click()
		await expect(page.getByText("Billing & shipping")).toHaveCount(0)

		await page
			.getByRole("checkbox", { name: /Candidate Responsibility/ })
			.click()
		await page.getByRole("checkbox", { name: /Exam Policies/ }).click()

		const submit = page.getByRole("button", { name: "Pay and Register" })
		await expect(submit).toBeEnabled()
		await submit.click()

		const dialog = page.getByRole("dialog")
		await expect(
			dialog.getByText("You will be taken to our payment provider to pay."),
		).toBeVisible()
		expect(org.hits("register")).toBe(0)
		await dialog.getByRole("button", { name: "Pay and Register" }).click()

		// The relative checkoutUrl navigates the real browser to the stub.
		await expect(page).toHaveURL(/\/e2e-checkout-stub$/)

		// The checkout body's return contract.
		expect(org.hits("checkout")).toBe(1)
		const checkoutBody = parse(org.of("checkout")[0].postData)
		expect(checkoutBody.orderId).toBe("801-order")
		const successUrl = String(checkoutBody.successUrl)
		expect(successUrl).toContain("/programs/frm/register?")
		expect(successUrl).toContain("stripe_return=1")
		expect(successUrl).toContain("oid=801-order")
		// The order NUMBER does not travel — the status poll answers with it.
		expect(successUrl).not.toContain("on=")
		// Cancel carries the oid the rollback depends on.
		expect(String(checkoutBody.cancelUrl)).toContain(
			"/programs/frm/register?checkout_cancelled=1&oid=801-order",
		)

		// Card sequence: verify → register → checkout. No verifyAddress (Stripe
		// owns the address), and the money calls NEVER fire from this side.
		expect(
			org.calls
				.filter(
					(call) =>
						call.kind === "examreg" &&
						(WRITE_KEYS as readonly string[]).includes(call.key),
				)
				.map((call) => call.key),
		).toEqual(["verifyCustomer", "register", "checkout"])
		expect(org.hits("payOrder")).toBe(0)

		// The provider comes back to the successUrl it was handed. The order
		// number arrives from the poll, not the URL.
		org.use({
			examreg: {
				paymentStatus: {
					isOrderFound: true,
					isPaymentFound: true,
					isPaymentSuccess: true,
					orderNumber: "ORD-1001",
				},
			},
		})
		await page.goto(successUrl)
		await expect(page.getByText("Thank you — payment received")).toBeVisible()
		await expect(page.getByText("ORD-1001")).toBeVisible()
		expect(parse(org.of("paymentStatus")[0].postData)).toEqual({
			orderId: "801-order",
		})

		// The survey stands between the confirmation and the actions; Skip is a
		// first-class way past it, and saves nothing.
		await expect(
			page.getByRole("heading", { name: /Help us tailor your/ }),
		).toBeVisible()
		await expect(page.getByRole("link", { name: "Go to dashboard" })).toHaveCount(0)
		await page.getByRole("button", { name: "Skip for now" }).click()
		await expect(page.getByRole("link", { name: "Go to dashboard" })).toBeVisible()
		expect(org.hits("profile")).toBe(0)

		// Nothing was written twice: still one register, still zero payOrder.
		expect(org.hits("register")).toBe(1)
		expect(org.hits("payOrder")).toBe(0)
	})

	test("payment-return cold load: confirmation before ANY form, zero write calls, numeric params survive", async ({
		page,
	}) => {
		const org = await installMockOrg(page, stripeOptions())

		// Fresh page load with no React state — and `oid`/`on` all-numeric, so
		// the router JSON-parses them into numbers before the schema coerces
		// them back. The order behind this URL is already charged.
		await page.goto("/programs/frm/register?stripe_return=1&oid=801&on=1234")

		await expect(page.getByText("Thank you — payment received")).toBeVisible()
		// The numeric order number renders as itself, not `undefined`.
		await expect(page.getByText("1234", { exact: true })).toBeVisible()

		// No form behind the confirmation to invite a second registration.
		await expect(page.getByRole("combobox", { name: "Exam part" })).toHaveCount(0)
		await expect(
			page.getByRole("button", { name: "Pay and Register" }),
		).toHaveCount(0)

		// The poll on the numeric id (coerced back to a string) is the ONLY
		// registration call. Zero writes — and no pricing or form load either,
		// because the form never mounted.
		expect(parse(org.of("paymentStatus")[0].postData)).toEqual({ orderId: "801" })
		for (const key of WRITE_KEYS) {
			expect(org.hits(key)).toBe(key === "paymentStatus" ? 1 : 0)
		}
		expect(org.hits("fees")).toBe(0)
		expect(org.hits("info")).toBe(0)
	})

	test("a GUEST's payment return is not bounced off the public route", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			...stripeOptions(),
			identity: "guest",
			graphql: {},
		})

		await page.goto("/registration/frm?stripe_return=1&oid=801&on=1234")

		// The guard suppresses its redirect on a payment return: same address,
		// confirmation rendered, with GUEST-safe destinations only.
		await expect(page).toHaveURL(/\/registration\/frm\?/)
		await expect(page.getByText("Thank you — payment received")).toBeVisible()
		// The guest survey reads the registration module's own picklists, and
		// Skip gives way to the outcome's actions.
		await page.getByRole("button", { name: "Skip for now" }).click()
		expect(org.hits("demographics")).toBe(1)
		// The outcome's own "Sign in" — the public chrome carries "Sign In" too.
		await expect(
			page.getByRole("link", { name: "Sign in", exact: true }),
		).toBeVisible()
		await expect(
			page.getByRole("link", { name: "Go to dashboard" }),
		).toHaveCount(0)
		for (const key of WRITE_KEYS) {
			expect(org.hits(key)).toBe(key === "paymentStatus" ? 1 : 0)
		}
	})
})
