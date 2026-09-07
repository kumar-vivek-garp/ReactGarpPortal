import { expect, test } from "@playwright/test"

import {
	materialPurchaseResult,
	materialQuote,
	materialShipTo,
	orderCheckoutResult,
} from "@/testing/factories/study-material-purchase"
import { installMockOrg, refuse, refuseWith } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * Buying one study material: the quote renders its totals, a printed book
 * needs an address before Pay arms, Pay raises the order then opens the
 * hosted checkout with both return addresses and leaves, the deferred flow's
 * staged id pays the same way, the service's "not available" 404 is a state,
 * the cancel leg is acknowledged, and a checkout that will not open after
 * the order was written points at the order rather than re-arming Pay.
 */

// RELATIVE checkoutUrl on purpose: the redirect must stay on the static e2e
// server so the landing can be asserted.
const CHECKOUT = orderCheckoutResult({ checkoutUrl: "/e2e-checkout-stub" })

function baseActions(): Record<string, unknown> {
	return {
		programs: programsListData(),
		materialQuote: materialQuote(),
		materialPurchase: materialPurchaseResult(),
		orderCheckout: CHECKOUT,
	}
}

test.describe("study material purchase", () => {
	test("the quote renders item, shipping and total for a printed book", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: baseActions() })
		await page.goto("/study-materials/purchase/SCRH")

		await expect(
			page.getByRole("heading", { name: "Complete your purchase", level: 1 }),
		).toBeVisible()
		await expect(page.getByRole("heading", { name: "2026 SCR Book" })).toBeVisible()
		// The item price reads on the item card and in the rail; the total in
		// the sticky bar and in the rail.
		await expect(page.getByText("$100.00", { exact: true })).toHaveCount(2)
		await expect(page.getByText("$15.00", { exact: true })).toBeVisible()
		await expect(page.getByText("$115.00", { exact: true })).toHaveCount(2)
		await expect(page.getByText(/Tax is calculated/)).toBeVisible()
		await expect(page.getByRole("button", { name: "Continue to Payment" })).toBeEnabled()
		await expect.poll(() => org.hits("materialQuote")).toBe(1)
		expect(org.of("materialQuote")[0].url).toContain("productCode=SCRH")
	})

	test("something that is not posted asks for no address", async ({ page }) => {
		await installMockOrg(page, {
			actions: {
				...baseActions(),
				materialQuote: materialQuote({
					title: "FRM Practice Exam",
					isShippable: false,
					shipping: null,
					total: 100,
					shipTo: null,
				}),
			},
		})
		await page.goto("/study-materials/purchase/FRMPE")

		await expect(page.getByRole("button", { name: "Continue to Payment" })).toBeEnabled()
		await expect(page.getByText("Shipping")).toHaveCount(0)
		await expect(page.getByLabel(/Street address/)).toHaveCount(0)
	})

	test("a printed book holds Pay until street, city and country are there", async ({
		page,
	}) => {
		await installMockOrg(page, {
			actions: {
				...baseActions(),
				materialQuote: materialQuote({ shipTo: materialShipTo({ street: null }) }),
			},
		})
		await page.goto("/study-materials/purchase/SCRH")

		const pay = page.getByRole("button", { name: "Continue to Payment" })
		await expect(pay).toBeDisabled()
		await expect(
			page.getByText("A street, city and country are needed to post a book."),
		).toBeVisible()

		await page.getByLabel(/Street address/).fill("5 Harbour Road")
		await expect(pay).toBeEnabled()
	})

	test("Pay raises the order, opens checkout with both return URLs, and leaves", async ({
		page,
		baseURL,
	}) => {
		const org = await installMockOrg(page, { actions: baseActions() })
		await page.goto("/study-materials/purchase/SCRH")
		await page.getByLabel(/City/).fill("Hoboken")

		await page.getByRole("button", { name: "Continue to Payment" }).click()

		// The handoff leaves the app for the (stubbed) hosted checkout page.
		await page.waitForURL("**/e2e-checkout-stub")

		expect(org.hits("materialPurchase")).toBe(1)
		const purchase = JSON.parse(org.of("materialPurchase")[0].postData ?? "{}") as {
			productCode?: string
			shipTo?: { city?: string; country?: string }
		}
		expect(purchase.productCode).toBe("SCRH")
		expect(purchase.shipTo).toMatchObject({ city: "Hoboken", country: "United States" })

		await expect.poll(() => org.hits("orderCheckout")).toBe(1)
		const checkout = JSON.parse(org.of("orderCheckout")[0].postData ?? "{}") as {
			orderId?: string
			successUrl?: string
			cancelUrl?: string
		}
		expect(checkout.orderId).toBe("006PUR00000000001")
		// The base path is "" in the static build — exact, not contains.
		expect(checkout.successUrl).toBe(`${baseURL}/study-materials?purchased=1`)
		expect(checkout.cancelUrl).toBe(
			`${baseURL}/study-materials/purchase/SCRH?checkout_cancelled=1`,
		)
	})

	test("the deferred flow's staged id pays through the same checkout", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				...baseActions(),
				materialPurchase: materialPurchaseResult({
					orderId: null,
					orderNumber: null,
					stagedId: "a0H000000000001",
					registrationRef: "REG-0001",
				}),
			},
		})
		await page.goto("/study-materials/purchase/SCRH")

		await page.getByRole("button", { name: "Continue to Payment" }).click()
		await page.waitForURL("**/e2e-checkout-stub")

		const checkout = JSON.parse(org.of("orderCheckout")[0].postData ?? "{}") as {
			orderId?: string
		}
		expect(checkout.orderId).toBe("a0H000000000001")
	})

	test("the service's 404 reads as not available, with a way back and no write", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				...baseActions(),
				materialQuote: refuseWith(
					404,
					"This item is not available to purchase.",
					materialQuote({
						statusCode: 404,
						statusMessage: "This item is not available to purchase.",
						isShippable: false,
						shippableCountries: [],
					}),
				),
			},
		})
		await page.goto("/study-materials/purchase/FRMBP")

		await expect(
			page.getByRole("heading", { name: "This item is not available to purchase" }),
		).toBeVisible()
		await expect(
			page.getByRole("main").getByRole("link", { name: "Study Materials" }).first(),
		).toBeVisible()
		await expect(page.getByRole("button", { name: /Continue to Payment/ })).toHaveCount(0)
		expect(org.hits("materialPurchase")).toBe(0)
	})

	test("the cancel leg is acknowledged and the form stays ready", async ({ page }) => {
		const org = await installMockOrg(page, { actions: baseActions() })
		// Purely numeric on purpose — the router JSON-parses search values.
		await page.goto("/study-materials/purchase/SCRH?checkout_cancelled=1")

		await expect(page.getByText("Payment cancelled")).toBeVisible()
		await expect(page.getByText(/Nothing has been charged/)).toBeVisible()
		await expect(page.getByRole("button", { name: "Continue to Payment" })).toBeEnabled()
		expect(org.hits("materialPurchase")).toBe(0)
		expect(org.hits("orderCheckout")).toBe(0)
	})

	test("a checkout that will not open after the order was written points at the order, once", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				...baseActions(),
				orderCheckout: refuse(501, "Open Order not found"),
			},
		})
		await page.goto("/study-materials/purchase/SCRH")

		await page.getByRole("button", { name: "Continue to Payment" }).click()

		await expect(page.getByRole("link", { name: "View order" })).toHaveAttribute(
			"href",
			"/my-account/orders/INV-0009",
		)
		await expect(page.getByText(/Order History/)).toBeVisible()
		await expect(page.getByRole("button", { name: /Continue to Payment/ })).toHaveCount(0)
		// No automatic retry of the non-idempotent write.
		await page.waitForTimeout(250)
		expect(org.hits("materialPurchase")).toBe(1)
	})
})
