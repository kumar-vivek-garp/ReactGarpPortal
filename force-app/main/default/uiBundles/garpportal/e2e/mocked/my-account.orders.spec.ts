import { expect, test } from "@playwright/test"

import { accountView } from "@/testing/factories/account"
import { portalOrder } from "@/testing/factories/orders"
import { installMockOrg, type MockOrgOptions } from "../support/mock-org"

/**
 * Order History journeys: the list, the detail page, and the pay/cancel
 * affordances. `payOrder` never charges — 201 means a zero-value order was
 * closed server-side (stay in-app), 200 means "ready for Stripe" and the
 * hook does a full `window.location.assign` handoff (asserted as URL +
 * session cookie, since the static e2e server has no real checkout).
 */

const UNPAID = portalOrder() // id 006xx1 / INV-0001 / FRM Part I Exam / canPay
const PAID = portalOrder({
	id: "006xx2",
	invoiceNumber: "INV-0002",
	description: "GARP Annual Membership",
	orderDate: "2025-11-02",
	amount: 150,
	stage: "Closed Won",
	paymentStatus: "Paid",
	paymentMethod: "Credit Card",
	isPaid: true,
	isClosed: true,
	canPay: false,
})

/** `orderDetail` envelope data — PortalResult + the order row. */
function orderDetailData(order: ReturnType<typeof portalOrder> | null) {
	return { statusCode: 200, statusMessage: null, order }
}

function baseOptions(): MockOrgOptions {
	return {
		actions: {
			account: accountView(),
			orders: { unpaidOrders: [UNPAID], paidOrders: [PAID] },
			orderDetail: orderDetailData(UNPAID),
		},
	}
}

test.describe("order history list", () => {
	test("renders both buckets and opens the detail from a row", async ({
		page,
	}) => {
		const org = await installMockOrg(page, baseOptions())
		await page.goto("/my-account?tab=order-history")

		// ^-anchored: the accessible names carry counts, and a bare
		// "Paid Purchases" substring-matches "Unpaid Purchases (1)" too.
		await expect(
			page.getByRole("heading", { name: /^Unpaid Purchases/ }),
		).toBeVisible()
		await expect(
			page.getByRole("heading", { name: /^Paid Purchases/ }),
		).toBeVisible()
		await expect(page.getByText("INV-0001")).toBeVisible()
		await expect(page.getByText("INV-0002")).toBeVisible()
		await expect(page.getByText("USD 750.00")).toBeVisible()

		await page
			.getByRole("link", { name: "View order FRM Part I Exam" })
			.click()

		// Rows navigate by Opportunity Id, not invoice number.
		await expect(page).toHaveURL(/\/my-account\/orders\/006xx1$/)
		await expect(
			page.getByRole("heading", { name: "FRM Part I Exam" }),
		).toBeVisible()
		await expect.poll(() => org.hits("orderDetail")).toBe(1)
		expect(org.of("orderDetail")[0].url).toContain("orderNumber=006xx1")
	})
})

test.describe("order detail", () => {
	test("an unpaid order shows full fields plus Pay and Cancel", async ({
		page,
	}) => {
		const org = await installMockOrg(page, baseOptions())
		await page.goto("/my-account/orders/INV-0001")

		await expect(
			page.getByRole("heading", { name: "FRM Part I Exam" }),
		).toBeVisible()
		await expect(page.getByText("Payment due")).toBeVisible()
		await expect(page.getByText("Invoice Number")).toBeVisible()
		await expect(page.getByText("INV-0001").first()).toBeVisible()
		await expect(page.getByText("Order ID")).toBeVisible()
		await expect(page.getByText("006xx1")).toBeVisible()
		await expect(page.getByRole("button", { name: "Pay Order" })).toBeVisible()
		await expect(
			page.getByRole("button", { name: "Cancel Order" }),
		).toBeVisible()
		await expect(
			page.getByRole("button", { name: "Download Order" }),
		).toBeVisible()

		// The route param travels to Apex verbatim (invoice or Opportunity Id).
		expect(org.of("orderDetail")[0].url).toContain("orderNumber=INV-0001")
	})

	test("a paid, closed order offers no Pay or Cancel", async ({ page }) => {
		await installMockOrg(page, {
			actions: { ...baseOptions().actions, orderDetail: orderDetailData(PAID) },
		})
		await page.goto("/my-account/orders/INV-0002")

		await expect(
			page.getByRole("heading", { name: "GARP Annual Membership" }),
		).toBeVisible()
		await expect(page.getByText("Credit Card").first()).toBeVisible()
		await expect(page.getByRole("button", { name: "Pay Order" })).toHaveCount(0)
		await expect(
			page.getByRole("button", { name: "Cancel Order" }),
		).toHaveCount(0)
		await expect(
			page.getByRole("button", { name: "Download Order" }),
		).toBeVisible()
	})
})

test.describe("pay and cancel", () => {
	test("Pay Order on a zero-value close (201) returns to Order History", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				...baseOptions().actions,
				payOrder: { statusCode: 201, statusMessage: "Order closed" },
			},
		})
		await page.goto("/my-account/orders/006xx1")

		await page.getByRole("button", { name: "Pay Order" }).click()

		await expect(page).toHaveURL(/\/my-account\?tab=order-history/)
		await expect(
			page.getByRole("heading", { name: "Unpaid Purchases" }),
		).toBeVisible()
		expect(org.hits("payOrder")).toBe(1)
		expect(org.of("payOrder")[0].postData).toBe('{"orderId":"006xx1"}')
	})

	test("Pay Order ready-for-checkout (200) hands off to Stripe with the session cookie", async ({
		page,
		context,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				...baseOptions().actions,
				payOrder: { statusCode: 200, statusMessage: null },
			},
		})
		await page.goto("/my-account/orders/006xx1")

		await page.getByRole("button", { name: "Pay Order" }).click()

		// usePayOrder assigns window.location to the hosted-checkout path; the
		// static e2e server rewrites it back to the SPA, so the observable
		// contract is the handoff URL plus the legacy session cookie.
		await expect(page).toHaveURL(/\/stripe_checkout\?regType=orders&id=006xx1/)
		expect(org.hits("payOrder")).toBe(1)
		expect(org.of("payOrder")[0].postData).toBe('{"orderId":"006xx1"}')
		const cookies = await context.cookies()
		const session = cookies.find(
			(cookie) => cookie.name === "garp-checkout-session-token",
		)
		expect(session?.value).toBe("orders%3A006xx1")
	})

	test("Cancel Order posts cancelOrder and returns to Order History", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				...baseOptions().actions,
				cancelOrder: { statusCode: 200, statusMessage: null },
			},
		})
		await page.goto("/my-account/orders/006xx1")

		await page.getByRole("button", { name: "Cancel Order" }).click()

		await expect(page.getByText("Order cancelled")).toBeVisible()
		await expect(page).toHaveURL(/\/my-account\?tab=order-history/)
		expect(org.hits("cancelOrder")).toBe(1)
		expect(org.of("cancelOrder")[0].postData).toBe('{"orderId":"006xx1"}')
	})
})
