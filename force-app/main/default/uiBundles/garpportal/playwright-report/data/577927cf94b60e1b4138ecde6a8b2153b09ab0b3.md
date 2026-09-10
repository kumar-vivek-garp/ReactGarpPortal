# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: affiliate.spec.ts >> affiliate sign-up >> guest journey: verify on blur, trimmed register body, payOrder once, guest-safe outcome
- Location: e2e/mocked/affiliate.spec.ts:32:2

# Error details

```
Error: expect(locator).toBeDisabled() failed

Locator:  getByRole('button', { name: 'Register', exact: true })
Expected: disabled
Received: enabled
Timeout:  5000ms

Call log:
  - Expect "toBeDisabled" with timeout 5000ms
  - waiting for getByRole('button', { name: 'Register', exact: true })
    14 × locator resolved to <button type="submit" data-size="lg" data-slot="button" data-variant="default" class="inline-flex cursor-pointer items-center justify-center gap-2 rounded-xl text-sm font-extrabold whitespace-nowrap transition-[color,background-color,border-color,box-shadow,opacity] outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive…>Register</button>
       - unexpected value "enabled"

```

```yaml
- button "Register"
```

# Test source

```ts
  1   | import { expect, test } from "@playwright/test"
  2   | 
  3   | import {
  4   | 	affiliateLoad,
  5   | 	affiliateRegisterResult,
  6   | } from "@/testing/factories/affiliate"
  7   | import { verifyCustomerResult } from "@/testing/factories/exam"
  8   | import { installMockOrg } from "../support/mock-org"
  9   | 
  10  | /**
  11  |  * The guest Affiliate sign-up at /registration/affiliate — this app's
  12  |  * "Create Account". One full journey: fill → identity check on email blur →
  13  |  * submit (no confirm dialog; the order is free) → the register body carries
  14  |  * TRIMMED names and the COLLAPSED consent → the zero-total order is closed by
  15  |  * exactly one payOrder → the outcome offers only guest-safe destinations.
  16  |  */
  17  | 
  18  | function parse(postData: string | null): Record<string, any> {
  19  | 	return JSON.parse(postData ?? "{}")
  20  | }
  21  | 
  22  | async function chooseOption(
  23  | 	page: import("@playwright/test").Page,
  24  | 	comboboxName: string | RegExp,
  25  | 	optionName: string | RegExp,
  26  | ) {
  27  | 	await page.getByRole("combobox", { name: comboboxName }).click()
  28  | 	await page.getByRole("option", { name: optionName }).click()
  29  | }
  30  | 
  31  | test.describe("affiliate sign-up", () => {
  32  | 	test("guest journey: verify on blur, trimmed register body, payOrder once, guest-safe outcome", async ({
  33  | 		page,
  34  | 	}) => {
  35  | 		test.slow()
  36  | 		const org = await installMockOrg(page, {
  37  | 			identity: "guest",
  38  | 			examreg: {
  39  | 				info: affiliateLoad(),
  40  | 				verifyCustomer: verifyCustomerResult(),
  41  | 				register: affiliateRegisterResult(),
  42  | 				payOrder: { completed: true },
  43  | 			},
  44  | 		})
  45  | 
  46  | 		await page.goto("/registration/affiliate")
  47  | 
  48  | 		// The page's only heading, and the fixed price beside the commitment.
  49  | 		await expect(
  50  | 			page.getByRole("heading", {
  51  | 				level: 1,
  52  | 				name: "Affiliate Membership Registration",
  53  | 			}),
  54  | 		).toBeVisible()
  55  | 		// The bar's fixed total (the rail repeats "Free" in its own rows).
  56  | 		await expect(
  57  | 			page.getByText("Free", { exact: true }).first(),
  58  | 		).toBeVisible()
  59  | 
  60  | 		const submit = page.getByRole("button", { name: "Register", exact: true })
> 61  | 		await expect(submit).toBeDisabled()
      |                        ^ Error: expect(locator).toBeDisabled() failed
  62  | 
  63  | 		// Names first (they travel with the identity check), then the email —
  64  | 		// typed with surrounding spaces so the trim is proven on the wire.
  65  | 		await page.getByRole("textbox", { name: "First name" }).fill(" Ada ")
  66  | 		await page.getByRole("textbox", { name: "Last name" }).fill(" Lovelace ")
  67  | 		const email = page.getByRole("textbox", { name: "Email address" })
  68  | 		await email.fill("ada@garp.org")
  69  | 		await email.blur()
  70  | 
  71  | 		// The blur check fires once, already trimmed, typed for this programme.
  72  | 		await expect.poll(() => org.hits("verifyCustomer")).toBe(1)
  73  | 		expect(parse(org.of("verifyCustomer")[0].postData)).toEqual({
  74  | 			type: "affiliate",
  75  | 			email: "ada@garp.org",
  76  | 			firstName: "Ada",
  77  | 			lastName: "Lovelace",
  78  | 		})
  79  | 
  80  | 		await chooseOption(page, "Location", "United States")
  81  | 		await chooseOption(page, "Mobile phone country code", "United States (+1)")
  82  | 		await page
  83  | 			.getByRole("textbox", { name: "Mobile phone", exact: true })
  84  | 			.fill("5551234")
  85  | 
  86  | 		// US carries no compliance tag, so submitting IS the consent — the
  87  | 		// button opens once the fields are in, with no ticks to find.
  88  | 		await expect(submit).toBeEnabled()
  89  | 		await submit.click()
  90  | 
  91  | 		// The outcome replaces the form.
  92  | 		await expect(
  93  | 			page.getByText(/You.re an Affiliate Member/),
  94  | 		).toBeVisible()
  95  | 
  96  | 		// The register body: session quoted back, ids from the verify answer,
  97  | 		// trimmed names, composite phone code, and the consent COLLAPSED to the
  98  | 		// single boolean the server stores.
  99  | 		expect(org.hits("register")).toBe(1)
  100 | 		expect(parse(org.of("register")[0].postData)).toEqual({
  101 | 			type: "affiliate",
  102 | 			sessionId: "S-1",
  103 | 			customer: {
  104 | 				contactId: "003-verified",
  105 | 				accountId: "001-verified",
  106 | 				leadId: null,
  107 | 				firstName: "Ada",
  108 | 				lastName: "Lovelace",
  109 | 				email: "ada@garp.org",
  110 | 				mobilePhoneCode: "United States (+1)",
  111 | 				mobilePhone: "5551234",
  112 | 				smsPromotionalUpdates: false,
  113 | 			},
  114 | 			billingAddress: { country: "United States" },
  115 | 			billingAndShippingSame: true,
  116 | 			consent: { privacyPolicy: true },
  117 | 		})
  118 | 
  119 | 		// The zero-total order is settled by exactly one payOrder — the call is
  120 | 		// not idempotent, and the blur session meant no second verify either.
  121 | 		expect(org.hits("payOrder")).toBe(1)
  122 | 		expect(parse(org.of("payOrder")[0].postData)).toEqual({
  123 | 			orderId: "801-aff",
  124 | 		})
  125 | 		expect(org.hits("verifyCustomer")).toBe(1)
  126 | 		expect(
  127 | 			org.calls
  128 | 				.filter(
  129 | 					(call) =>
  130 | 						call.kind === "examreg" &&
  131 | 						["verifyCustomer", "register", "payOrder"].includes(call.key),
  132 | 				)
  133 | 				.map((call) => call.key),
  134 | 		).toEqual(["verifyCustomer", "register", "payOrder"])
  135 | 
  136 | 		// Guest-safe destinations only: garp.org, and a sign-in to the account
  137 | 		// this registration just created. Nothing points into the walled portal.
  138 | 		const exit = page.getByRole("link", { name: /Back to GARP\.org/ })
  139 | 		await expect(exit).toBeVisible()
  140 | 		expect(await exit.getAttribute("href")).toBe("https://www.garp.org")
  141 | 		const signIn = page.getByRole("link", { name: "Sign in", exact: true })
  142 | 		await expect(signIn).toBeVisible()
  143 | 		expect(await signIn.getAttribute("href")).toContain("/Login")
  144 | 		await expect(
  145 | 			page.getByRole("link", { name: "Go to dashboard" }),
  146 | 		).toHaveCount(0)
  147 | 	})
  148 | 
  149 | 	test("a mustSignIn email is told before the form is finished, with a real way in", async ({
  150 | 		page,
  151 | 	}) => {
  152 | 		const org = await installMockOrg(page, {
  153 | 			identity: "guest",
  154 | 			examreg: {
  155 | 				info: affiliateLoad(),
  156 | 				verifyCustomer: verifyCustomerResult({ mustSignIn: true }),
  157 | 			},
  158 | 		})
  159 | 
  160 | 		await page.goto("/registration/affiliate")
  161 | 		await page.getByRole("textbox", { name: "First name" }).fill("Ada")
```