import { expect, test, type Route } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { examRegisterResult, verifyCustomerResult } from "@/testing/factories/exam"
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
 * The MEMBER membership form at /membership/register, and the route twins
 * around it: a member on the public address is bounced here with the query
 * intact, a guest on this address is bounced to the public twin the same
 * way. Then the wire-transfer journey: address card, processing fee, no
 * auto-renew (no card to renew against), the staged confirm, and the
 * module's contract in order with `payOrder` exactly once — the register
 * body carrying `type: "mem"` and none of what an exam would send.
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

/** Mailing mirrors billing so the loader derives same-as-billing = true. */
const PROFILE = personalInfoEditData({
	mailing: portalAddressFields(),
	sameAsBilling: true,
})

function parse(postData: string | null): Record<string, any> {
	return JSON.parse(postData ?? "{}")
}

async function priceCart(route: Route) {
	const body = parse(route.request().postData())
	await route.fulfill({
		json: memberPortalEnvelope(
			membershipFeesResult({
				riskNet: body.riskNetSelected === true,
				offline: Boolean(body.paymentType) && body.paymentType !== "Stripe",
			}),
		),
	})
}

function memberOptions(): MockOrgOptions {
	return {
		actions: {
			alertBar: NO_ALERT,
			account: accountViewFromPersonalInfo(PROFILE),
		},
		graphql: { BillingCompany: billingCompanyGraphql(PROFILE) },
		examreg: {
			info: membershipLoad({
				isAuthenticated: true,
				contact: { id: "003-member" },
			}),
			fees: priceCart,
			verifyCustomer: verifyCustomerResult(),
			verifyAddress: {
				billingValid: true,
				billingAllowed: true,
				shippingValid: true,
				shippingAllowed: true,
				message: null,
			},
			// A membership order: no attempt, no programme contract.
			register: examRegisterResult({ registrationId: null, contractId: null }),
			payOrder: { completed: true },
			// A wire order's real answer: the order exists, no payment yet.
			paymentStatus: { isOrderFound: true, isPaymentFound: false },
		},
	}
}

test.describe("membership route twins", () => {
	test("a member on the public address lands on /membership/register with the query intact", async ({
		page,
	}) => {
		await installMockOrg(page, memberOptions())

		await page.goto(
			"/registration/membership?track_cta=PortalMembershipPage&regCode=TEAM24",
		)

		await expect(page).toHaveURL(
			/\/membership\/register\?(?=.*track_cta=PortalMembershipPage)(?=.*regCode=TEAM24)/,
		)
		await expect(
			page.getByRole("heading", { level: 1, name: /Member Registration/ }),
		).toBeVisible()
	})

	test("a guest on the member address is handed to the public twin, query intact", async ({
		page,
	}) => {
		await installMockOrg(page, {
			identity: "guest",
			examreg: { info: membershipLoad(), fees: priceCart },
		})

		await page.goto("/membership/register?regCode=TEAM24&track_cta=PortalGatedContent")

		await expect(page).toHaveURL(
			/\/registration\/membership\?(?=.*regCode=TEAM24)(?=.*track_cta=PortalGatedContent)/,
		)
		await expect(page.getByRole("textbox", { name: "First name" })).toHaveValue("")
	})
})

test.describe("member membership registration", () => {
	test("wire-transfer journey: member-shaped, no auto-renew, ordered call sequence, payOrder once", async ({
		page,
	}) => {
		test.slow()
		const org = await installMockOrg(page, memberOptions())

		await page.goto("/membership/register?track_cta=PortalMembershipPage")

		await expect(
			page.getByRole("heading", { level: 1, name: /Member Registration/ }),
		).toBeVisible()
		// Member-shaped: name/email from the record; phone stays.
		await expect(page.getByRole("textbox", { name: "First name" })).toHaveCount(0)
		await expect(
			page.getByRole("textbox", { name: "Mobile phone", exact: true }),
		).toHaveValue("5551234")
		// Back goes to Membership Benefits, not the programmes list. Scoped to
		// the form: the sidebar carries links by the same names.
		const main = page.getByRole("main")
		await expect(main.getByRole("link", { name: "Membership" })).toBeVisible()
		await expect(main.getByRole("link", { name: "Programs" })).toHaveCount(0)
		await expect(page.getByRole("combobox", { name: "Exam part" })).toHaveCount(0)

		// Priced with nothing chosen, then the offline method adds its fee.
		await expect(page.getByText("USD 195.00").first()).toBeVisible()
		await page.getByRole("radio", { name: "Wire transfer" }).click()
		await expect(page.getByText("Billing & shipping")).toBeVisible()
		await expect(page.getByText("Processing Fee")).toBeVisible()
		await expect(page.getByText("USD 245.00").first()).toBeVisible()
		await expect(
			page.getByRole("checkbox", { name: /Membership Automatic Renewal/ }),
		).toHaveCount(0)

		// Submit STAGES: the dialog opens and nothing has been written.
		const submit = page.getByRole("button", { name: "Submit Order" })
		await expect(submit).toBeEnabled()
		await submit.click()
		const dialog = page.getByRole("dialog")
		await expect(dialog.getByText("Confirm your registration")).toBeVisible()
		expect(org.hits("verifyCustomer")).toBe(0)
		expect(org.hits("register")).toBe(0)

		await dialog.getByRole("button", { name: "Submit Order" }).click()

		await expect(page.getByText("Your order has been submitted")).toBeVisible()
		await expect(page.getByText("ORD-1001")).toBeVisible()
		await page.getByRole("button", { name: "Skip for now" }).click()
		await expect(page.getByRole("link", { name: "Go to dashboard" })).toBeVisible()

		const WRITE_KEYS = new Set([
			"verifyCustomer",
			"verifyAddress",
			"register",
			"payOrder",
			"paymentStatus",
		])
		expect(
			org.calls
				.filter((call) => call.kind === "examreg" && WRITE_KEYS.has(call.key))
				.map((call) => call.key),
		).toEqual(["verifyCustomer", "verifyAddress", "register", "payOrder", "paymentStatus"])
		expect(org.hits("payOrder")).toBe(1)

		// The member path's identity call carries the tag; nothing else does.
		expect(parse(org.of("verifyCustomer")[0].postData).tracking).toEqual({
			trackCta: "PortalMembershipPage",
		})

		const registerBody = parse(org.of("register")[0].postData)
		expect(registerBody.type).toBe("mem")
		expect(registerBody.sessionId).toBe("S-1")
		expect(registerBody.paymentType).toBe("Wire Transfer")
		expect(registerBody.riskNetSelected).toBe(false)
		expect(registerBody.membershipSelected).toBe(false)
		expect(registerBody.autoRenew).toBe(false)
		expect(registerBody.selection).toEqual({ partSelected: null, part1: null, part2: null })
		expect(registerBody.materials).toEqual([])
		expect(registerBody.personal).toBeNull()
		expect(registerBody).not.toHaveProperty("tracking")
		expect(registerBody.consent.examPolicy).toBe(false)
		expect(registerBody.billingAddress.country).toBe("United States")
	})
})
