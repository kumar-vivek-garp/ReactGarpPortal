# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: study-materials-purchase.spec.ts >> study material purchase >> a printed book holds Pay until street, city and country are there
- Location: e2e/mocked/study-materials-purchase.spec.ts:76:2

# Error details

```
Error: expect(locator).toBeDisabled() failed

Locator:  getByRole('button', { name: 'Continue to Payment' })
Expected: disabled
Received: enabled
Timeout:  5000ms

Call log:
  - Expect "toBeDisabled" with timeout 5000ms
  - waiting for getByRole('button', { name: 'Continue to Payment' })
    12 × locator resolved to <button type="submit" data-size="lg" data-slot="button" data-variant="default" class="inline-flex cursor-pointer items-center justify-center gap-2 rounded-xl text-sm font-extrabold whitespace-nowrap transition-[color,background-color,border-color,box-shadow,opacity] outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive…>Continue to Payment</button>
       - unexpected value "enabled"

```

```yaml
- button "Continue to Payment"
```

# Test source

```ts
  1   | import { expect, test } from "@playwright/test"
  2   | 
  3   | import {
  4   | 	materialPurchaseResult,
  5   | 	materialQuote,
  6   | 	materialShipTo,
  7   | 	orderCheckoutResult,
  8   | } from "@/testing/factories/study-material-purchase"
  9   | import { installMockOrg, refuse, refuseWith } from "../support/mock-org"
  10  | import { programsListData } from "../support/payloads"
  11  | 
  12  | /**
  13  |  * Buying one study material: the quote renders its totals, a printed book
  14  |  * needs an address before Pay arms, Pay raises the order then opens the
  15  |  * hosted checkout with both return addresses and leaves, the deferred flow's
  16  |  * staged id pays the same way, the service's "not available" 404 is a state,
  17  |  * the cancel leg is acknowledged, and a checkout that will not open after
  18  |  * the order was written points at the order rather than re-arming Pay.
  19  |  */
  20  | 
  21  | // RELATIVE checkoutUrl on purpose: the redirect must stay on the static e2e
  22  | // server so the landing can be asserted.
  23  | const CHECKOUT = orderCheckoutResult({ checkoutUrl: "/e2e-checkout-stub" })
  24  | 
  25  | function baseActions(): Record<string, unknown> {
  26  | 	return {
  27  | 		programs: programsListData(),
  28  | 		materialQuote: materialQuote(),
  29  | 		materialPurchase: materialPurchaseResult(),
  30  | 		orderCheckout: CHECKOUT,
  31  | 	}
  32  | }
  33  | 
  34  | test.describe("study material purchase", () => {
  35  | 	test("the quote renders item, shipping and total for a printed book", async ({
  36  | 		page,
  37  | 	}) => {
  38  | 		const org = await installMockOrg(page, { actions: baseActions() })
  39  | 		await page.goto("/study-materials/purchase/SCRH")
  40  | 
  41  | 		await expect(
  42  | 			page.getByRole("heading", { name: "Complete your purchase", level: 1 }),
  43  | 		).toBeVisible()
  44  | 		await expect(page.getByRole("heading", { name: "2026 SCR Book" })).toBeVisible()
  45  | 		// The item price reads on the item card and in the rail; the total in
  46  | 		// the sticky bar and in the rail.
  47  | 		await expect(page.getByText("USD 100.00", { exact: true })).toHaveCount(2)
  48  | 		await expect(page.getByText("USD 15.00", { exact: true })).toBeVisible()
  49  | 		await expect(page.getByText("USD 115.00", { exact: true })).toHaveCount(2)
  50  | 		await expect(page.getByText(/Tax is calculated/)).toBeVisible()
  51  | 		await expect(page.getByRole("button", { name: "Continue to Payment" })).toBeEnabled()
  52  | 		await expect.poll(() => org.hits("materialQuote")).toBe(1)
  53  | 		expect(org.of("materialQuote")[0].url).toContain("productCode=SCRH")
  54  | 	})
  55  | 
  56  | 	test("something that is not posted asks for no address", async ({ page }) => {
  57  | 		await installMockOrg(page, {
  58  | 			actions: {
  59  | 				...baseActions(),
  60  | 				materialQuote: materialQuote({
  61  | 					title: "FRM Practice Exam",
  62  | 					isShippable: false,
  63  | 					shipping: null,
  64  | 					total: 100,
  65  | 					shipTo: null,
  66  | 				}),
  67  | 			},
  68  | 		})
  69  | 		await page.goto("/study-materials/purchase/FRMPE")
  70  | 
  71  | 		await expect(page.getByRole("button", { name: "Continue to Payment" })).toBeEnabled()
  72  | 		await expect(page.getByText("Shipping")).toHaveCount(0)
  73  | 		await expect(page.getByLabel(/Street address/)).toHaveCount(0)
  74  | 	})
  75  | 
  76  | 	test("a printed book holds Pay until street, city and country are there", async ({
  77  | 		page,
  78  | 	}) => {
  79  | 		await installMockOrg(page, {
  80  | 			actions: {
  81  | 				...baseActions(),
  82  | 				materialQuote: materialQuote({ shipTo: materialShipTo({ street: null }) }),
  83  | 			},
  84  | 		})
  85  | 		await page.goto("/study-materials/purchase/SCRH")
  86  | 
  87  | 		const pay = page.getByRole("button", { name: "Continue to Payment" })
> 88  | 		await expect(pay).toBeDisabled()
      |                     ^ Error: expect(locator).toBeDisabled() failed
  89  | 		await expect(
  90  | 			page.getByText("A street, city and country are needed to post a book."),
  91  | 		).toBeVisible()
  92  | 
  93  | 		await page.getByLabel(/Street address/).fill("5 Harbour Road")
  94  | 		await expect(pay).toBeEnabled()
  95  | 	})
  96  | 
  97  | 	test("Pay raises the order, opens checkout with both return URLs, and leaves", async ({
  98  | 		page,
  99  | 		baseURL,
  100 | 	}) => {
  101 | 		const org = await installMockOrg(page, { actions: baseActions() })
  102 | 		await page.goto("/study-materials/purchase/SCRH")
  103 | 		await page.getByLabel(/City/).fill("Hoboken")
  104 | 
  105 | 		await page.getByRole("button", { name: "Continue to Payment" }).click()
  106 | 
  107 | 		// The handoff leaves the app for the (stubbed) hosted checkout page.
  108 | 		await page.waitForURL("**/e2e-checkout-stub")
  109 | 
  110 | 		expect(org.hits("materialPurchase")).toBe(1)
  111 | 		const purchase = JSON.parse(org.of("materialPurchase")[0].postData ?? "{}") as {
  112 | 			productCode?: string
  113 | 			shipTo?: { city?: string; country?: string }
  114 | 		}
  115 | 		expect(purchase.productCode).toBe("SCRH")
  116 | 		expect(purchase.shipTo).toMatchObject({ city: "Hoboken", country: "United States" })
  117 | 
  118 | 		await expect.poll(() => org.hits("orderCheckout")).toBe(1)
  119 | 		const checkout = JSON.parse(org.of("orderCheckout")[0].postData ?? "{}") as {
  120 | 			orderId?: string
  121 | 			successUrl?: string
  122 | 			cancelUrl?: string
  123 | 		}
  124 | 		expect(checkout.orderId).toBe("006PUR00000000001")
  125 | 		// The base path is "" in the static build — exact, not contains.
  126 | 		expect(checkout.successUrl).toBe(`${baseURL}/study-materials?purchased=1`)
  127 | 		expect(checkout.cancelUrl).toBe(
  128 | 			`${baseURL}/study-materials/purchase/SCRH?checkout_cancelled=1`,
  129 | 		)
  130 | 	})
  131 | 
  132 | 	test("the deferred flow's staged id pays through the same checkout", async ({
  133 | 		page,
  134 | 	}) => {
  135 | 		const org = await installMockOrg(page, {
  136 | 			actions: {
  137 | 				...baseActions(),
  138 | 				materialPurchase: materialPurchaseResult({
  139 | 					orderId: null,
  140 | 					orderNumber: null,
  141 | 					stagedId: "a0H000000000001",
  142 | 					registrationRef: "REG-0001",
  143 | 				}),
  144 | 			},
  145 | 		})
  146 | 		await page.goto("/study-materials/purchase/SCRH")
  147 | 
  148 | 		await page.getByRole("button", { name: "Continue to Payment" }).click()
  149 | 		await page.waitForURL("**/e2e-checkout-stub")
  150 | 
  151 | 		const checkout = JSON.parse(org.of("orderCheckout")[0].postData ?? "{}") as {
  152 | 			orderId?: string
  153 | 		}
  154 | 		expect(checkout.orderId).toBe("a0H000000000001")
  155 | 	})
  156 | 
  157 | 	test("the service's 404 reads as not available, with a way back and no write", async ({
  158 | 		page,
  159 | 	}) => {
  160 | 		const org = await installMockOrg(page, {
  161 | 			actions: {
  162 | 				...baseActions(),
  163 | 				materialQuote: refuseWith(
  164 | 					404,
  165 | 					"This item is not available to purchase.",
  166 | 					materialQuote({
  167 | 						statusCode: 404,
  168 | 						statusMessage: "This item is not available to purchase.",
  169 | 						isShippable: false,
  170 | 						shippableCountries: [],
  171 | 					}),
  172 | 				),
  173 | 			},
  174 | 		})
  175 | 		await page.goto("/study-materials/purchase/FRMBP")
  176 | 
  177 | 		await expect(
  178 | 			page.getByRole("heading", { name: "This item is not available to purchase" }),
  179 | 		).toBeVisible()
  180 | 		await expect(
  181 | 			page.getByRole("main").getByRole("link", { name: "Study Materials" }).first(),
  182 | 		).toBeVisible()
  183 | 		await expect(page.getByRole("button", { name: /Continue to Payment/ })).toHaveCount(0)
  184 | 		expect(org.hits("materialPurchase")).toBe(0)
  185 | 	})
  186 | 
  187 | 	test("the cancel leg is acknowledged and the form stays ready", async ({ page }) => {
  188 | 		const org = await installMockOrg(page, { actions: baseActions() })
```