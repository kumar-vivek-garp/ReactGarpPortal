# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: registration.guest.spec.ts >> guest public registration >> renders unprefilled with the byline and sign-in offer, and no back link
- Location: e2e/mocked/registration.guest.spec.ts:39:2

# Error details

```
Error: expect(locator).toBeVisible() failed

Locator: getByText('Your details')
Expected: visible
Timeout: 5000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" with timeout 5000ms
  - waiting for getByText('Your details')

```

```yaml
- banner:
  - link "FRM":
    - /url: https://www.garp.org/
  - button "Switch to dark mode"
  - link "Sign In":
    - /url: /Login?startUrl=%2Fregistration%2Ffrm
- main:
  - heading "Financial Risk Manager (FRM®) Exam Registration" [level=1]:
    - text: Financial Risk Manager (FRM
    - superscript: ®
    - text: ) Exam Registration
  - alert:
    - text: Returning candidates registering for the FRM Part II Exam must sign in to continue with registration.
    - link "Sign in":
      - /url: /Login?startUrl=%2Fregistration%2Ffrm
  - text: Individual Details
  - paragraph: We will use these details to create your GARP account and to contact you about the exam.
  - text: First name
  - textbox "First name"
  - text: Last name
  - textbox "Last name"
  - text: Email
  - textbox "Email"
  - text: Your exam Exam part
  - combobox "Exam part": Select exam
  - paragraph: Part I
  - text: Sitting
  - radiogroup:
    - radio "May 2027 registration · USD 600.00"
    - text: May 2027 registration · USD 600.00
    - radio "November 2027 registration · USD 600.00"
    - text: November 2027 registration · USD 600.00
  - text: Payment Payment method
  - radiogroup "Payment type":
    - radio "Card"
    - radio "Wire transfer"
    - radio "ACH"
  - text: Exam Preparation Assistance
  - checkbox "I agree to GARP sharing my contact information with its network of third-party Exam Preparation Providers."
  - text: I agree to GARP sharing my contact information with its network of third-party Exam Preparation Providers.
  - paragraph:
    - text: View a list of
    - link "FRM Exam Preparation Providers":
      - /url: https://www.garp.org/frm/exam-preparation-providers
    - text: .
  - text: Candidate Acknowledgements
  - checkbox "I confirm that I have read and agree to the Candidate Responsibility Statement."
  - text: I confirm that I have read and agree to the
  - link "Candidate Responsibility Statement":
    - /url: https://www.garp.org/candidate-responsibility
  - text: .
  - checkbox "I confirm that I have read and agree to the Exam Policies."
  - text: I confirm that I have read and agree to the
  - link "Exam Policies":
    - /url: https://www.garp.org/frm/exam-policies
  - text: .
  - checkbox "Yes, I have read GARP’s Privacy Notice, Code of Conduct, Limitation of Liability, Waiver and Release and Refund Policy."
  - text: Yes, I have read GARP’s
  - link "Privacy Notice":
    - /url: https://www.garp.org/privacy-notice
  - text: ","
  - link "Code of Conduct":
    - /url: https://www.garp.org/code-of-conduct
  - text: ","
  - link "Limitation of Liability":
    - /url: https://www.garp.org/limitation-of-liability
  - text: ","
  - link "Waiver and Release":
    - /url: https://www.garp.org/release-and-waiver-policy
  - text: and Refund Policy.
  - checkbox "I agree to receiving emails from GARP and select third party providers with news, special offers, promotions and future messages that may be of interest to me."
  - text: I agree to receiving emails from GARP and select third party providers with news, special offers, promotions and future messages that may be of interest to me.
  - complementary:
    - paragraph: Total
    - text: USD 600.00
    - button "Pay and Register"
    - text: Add to your registration
    - paragraph: Practice Exams
    - paragraph: USD 0.00
    - button "Add"
    - text: Order summary Exam Fee USD 600.00
    - separator
    - text: Total USD 600.00
- contentinfo:
  - img "GARP"
  - paragraph: We are a not-for-profit organization and the leading globally recognized membership association for risk managers.
  - list:
    - listitem:
      - link "Important Notices":
        - /url: https://www.garp.org/important-notices
    - listitem:
      - link "Bylaws":
        - /url: https://www.garp.org/bylaws
    - listitem:
      - link "Code of Conduct":
        - /url: https://www.garp.org/code-of-conduct
    - listitem:
      - link "Privacy Notice":
        - /url: https://www.garp.org/privacy-notice
    - listitem:
      - link "Terms of Use":
        - /url: https://www.garp.org/terms-of-use
  - paragraph: © 2026 Global Association of Risk Professionals
- region "Notifications alt+T"
```

# Test source

```ts
  1   | import { expect, test } from "@playwright/test"
  2   | 
  3   | import {
  4   | 	examLoad,
  5   | 	verifyCustomerResult,
  6   | 	feesResult,
  7   | } from "@/testing/factories/exam"
  8   | import { installMockOrg } from "../support/mock-org"
  9   | 
  10  | /**
  11  |  * The GUEST public form at /registration/frm: nothing prefilled (the identity
  12  |  * fields exist and are empty), the programme byline and the sign-in offer are
  13  |  * shown up front, no back link promises a "back" that would hit the login
  14  |  * wall, `verifyCustomer` fires once on email blur with a TRIMMED body, and a
  15  |  * `mustSignIn` answer is met with an honest sign-in link — register never
  16  |  * fires.
  17  |  */
  18  | 
  19  | function parse(postData: string | null): Record<string, any> {
  20  | 	return JSON.parse(postData ?? "{}")
  21  | }
  22  | 
  23  | /** Fill the three identity fields (with untrimmed names) and blur the email. */
  24  | async function fillIdentity(page: import("@playwright/test").Page) {
  25  | 	await page
  26  | 		.getByRole("textbox", { name: "First name" })
  27  | 		.fill(" Ada ")
  28  | 	await page
  29  | 		.getByRole("textbox", { name: "Last name" })
  30  | 		.fill(" Lovelace ")
  31  | 	await page
  32  | 		.getByRole("textbox", { name: "Email", exact: true })
  33  | 		.fill("ada@example.org")
  34  | 	// Blur the email — the identity check runs here, not on submit.
  35  | 	await page.getByRole("textbox", { name: "Email", exact: true }).blur()
  36  | }
  37  | 
  38  | test.describe("guest public registration", () => {
  39  | 	test("renders unprefilled with the byline and sign-in offer, and no back link", async ({
  40  | 		page,
  41  | 	}) => {
  42  | 		const org = await installMockOrg(page, {
  43  | 			identity: "guest",
  44  | 			examreg: { info: examLoad(), fees: feesResult(600) },
  45  | 		})
  46  | 
  47  | 		await page.goto("/registration/frm")
  48  | 
  49  | 		// The page's only h1 names the certification in full.
  50  | 		await expect(
  51  | 			page.getByRole("heading", { level: 1, name: /Financial Risk Manager/ }),
  52  | 		).toBeVisible()
  53  | 
  54  | 		// FRM's guest byline, with a live sign-in link beside it.
  55  | 		await expect(
  56  | 			page.getByText(/Returning candidates registering for the FRM Part II/),
  57  | 		).toBeVisible()
  58  | 		const offer = page.getByRole("link", { name: "Sign in", exact: true })
  59  | 		await expect(offer).toBeVisible()
  60  | 		expect(await offer.getAttribute("href")).toContain("/Login")
  61  | 
  62  | 		// Guest-shaped details card: the identity fields are PRESENT and EMPTY.
> 63  | 		await expect(page.getByText("Your details")).toBeVisible()
      |                                                ^ Error: expect(locator).toBeVisible() failed
  64  | 		await expect(page.getByRole("textbox", { name: "First name" })).toHaveValue(
  65  | 			"",
  66  | 		)
  67  | 		await expect(page.getByRole("textbox", { name: "Last name" })).toHaveValue(
  68  | 			"",
  69  | 		)
  70  | 		await expect(
  71  | 			page.getByRole("textbox", { name: "Email", exact: true }),
  72  | 		).toHaveValue("")
  73  | 		await expect(
  74  | 			page.getByRole("textbox", { name: "Mobile phone", exact: true }),
  75  | 		).toHaveValue("")
  76  | 
  77  | 		// No back affordance: every in-app parent is behind the session guard.
  78  | 		const main = page.getByRole("main")
  79  | 		await expect(main.getByRole("link", { name: /^Back/ })).toHaveCount(0)
  80  | 		await expect(main.getByRole("button", { name: /^Back/ })).toHaveCount(0)
  81  | 
  82  | 		// Nothing was checked yet — no email has blurred.
  83  | 		expect(org.hits("verifyCustomer")).toBe(0)
  84  | 	})
  85  | 
  86  | 	test("verifyCustomer fires ONCE on email blur, with the trimmed body", async ({
  87  | 		page,
  88  | 	}) => {
  89  | 		const org = await installMockOrg(page, {
  90  | 			identity: "guest",
  91  | 			examreg: {
  92  | 				info: examLoad(),
  93  | 				fees: feesResult(600),
  94  | 				verifyCustomer: verifyCustomerResult({ isExistingCustomer: true }),
  95  | 			},
  96  | 		})
  97  | 
  98  | 		await page.goto("/registration/frm")
  99  | 		await expect(
  100 | 			page.getByRole("textbox", { name: "First name" }),
  101 | 		).toBeVisible()
  102 | 
  103 | 		await fillIdentity(page)
  104 | 
  105 | 		await expect.poll(() => org.hits("verifyCustomer")).toBe(1)
  106 | 		const body = parse(org.of("verifyCustomer")[0].postData)
  107 | 		// The typed values carried spaces; the wire body must not.
  108 | 		expect(body).toEqual({
  109 | 			type: "frm",
  110 | 			courseCode: null,
  111 | 			email: "ada@example.org",
  112 | 			firstName: "Ada",
  113 | 			lastName: "Lovelace",
  114 | 		})
  115 | 
  116 | 		// Re-blurring the SAME address is not a second identity call — the
  117 | 		// answer doubles as the registration's session.
  118 | 		await page.getByRole("textbox", { name: "Email", exact: true }).focus()
  119 | 		await page.getByRole("textbox", { name: "Email", exact: true }).blur()
  120 | 		await page.waitForTimeout(300)
  121 | 		expect(org.hits("verifyCustomer")).toBe(1)
  122 | 
  123 | 		// A found record that may proceed is said calmly, not as a block.
  124 | 		await expect(page.getByText("We found your record")).toBeVisible()
  125 | 	})
  126 | 
  127 | 	test("mustSignIn gets an honest sign-in link and register never fires", async ({
  128 | 		page,
  129 | 	}) => {
  130 | 		const org = await installMockOrg(page, {
  131 | 			identity: "guest",
  132 | 			examreg: {
  133 | 				info: examLoad(),
  134 | 				fees: feesResult(600),
  135 | 				verifyCustomer: verifyCustomerResult({ mustSignIn: true }),
  136 | 			},
  137 | 		})
  138 | 
  139 | 		await page.goto("/registration/frm")
  140 | 		await expect(
  141 | 			page.getByRole("textbox", { name: "First name" }),
  142 | 		).toBeVisible()
  143 | 
  144 | 		await fillIdentity(page)
  145 | 
  146 | 		// The binding answer, before the rest of the form was filled in.
  147 | 		await expect(page.getByText("You already have an account")).toBeVisible()
  148 | 		const rescue = page.getByRole("link", {
  149 | 			name: "Sign in and start again",
  150 | 		})
  151 | 		await expect(rescue).toBeVisible()
  152 | 		// A REAL link, carrying the way back to this form after sign-in.
  153 | 		const href = await rescue.getAttribute("href")
  154 | 		expect(href).toContain("/Login")
  155 | 		expect(href).toContain("startUrl=")
  156 | 
  157 | 		expect(org.hits("register")).toBe(0)
  158 | 	})
  159 | })
  160 | 
```