# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: registration.stripe.spec.ts >> stripe checkout leg >> card order hands off with honest success/cancel URLs, then the return confirms without re-writing
- Location: e2e/mocked/registration.stripe.spec.ts:122:2

# Error details

```
Error: expect(locator).toBeVisible() failed

Locator: getByRole('dialog').getByText('You will be taken to our payment provider to pay.')
Expected: visible
Timeout: 5000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" with timeout 5000ms
  - waiting for getByRole('dialog').getByText('You will be taken to our payment provider to pay.')

```

```yaml
- banner:
  - link "GARP":
    - /url: https://www.garp.org/
    - img "GARP"
  - navigation "Primary":
    - button "FRM"
    - button "SCR"
    - button "Risk & AI"
    - button "Membership"
    - button "Insights & Events"
    - button "About Us"
  - button "Switch to dark mode"
  - button "Sign Out"
- complementary:
  - link "Ada Lovelace (GARP ID 123456)":
    - /url: /my-account?tab=account-information
  - navigation:
    - link "Dashboard":
      - /url: /dashboard
    - link "Programs":
      - /url: /programs
    - link "CPD Credits":
      - /url: /cpd
    - link "Study Materials":
      - /url: /study-materials
    - link "Membership Benefits":
      - /url: /membership
    - link "Events":
      - /url: /events
    - link "Help Center":
      - /url: /help-center
- button "Expand sidebar (⌘/Ctrl + B)"
- main:
  - link "Programs":
    - /url: /programs
  - heading "Financial Risk Manager (FRM®) Exam Registration" [level=1]:
    - text: Financial Risk Manager (FRM
    - superscript: ®
    - text: ) Exam Registration
  - paragraph: Total
  - text: USD 750.00
  - button "Pay and Register"
  - text: Your exam Exam part
  - combobox "Exam part": FRM Exam Part I
  - paragraph: Part I
  - text: Sitting
  - radiogroup:
    - radio "May 2027 registration · USD 600.00" [checked]
    - text: May 2027 registration · USD 600.00
    - radio "November 2027 registration · USD 600.00"
    - text: November 2027 registration · USD 600.00
  - text: Where you will sit
  - combobox "Where you will sit": Boston
  - text: Payment Payment method
  - radiogroup "Payment type":
    - radio "Card" [checked]
    - radio "Wire transfer"
    - radio "ACH"
  - paragraph: You will be taken to our payment provider to complete checkout.
  - text: Exam Preparation Assistance
  - checkbox "I agree to GARP sharing my contact information with its network of third-party Exam Preparation Providers."
  - text: I agree to GARP sharing my contact information with its network of third-party Exam Preparation Providers.
  - paragraph:
    - text: View a list of
    - link "FRM Exam Preparation Providers":
      - /url: https://www.garp.org/frm/exam-preparation-providers
    - text: .
  - text: Candidate Acknowledgements
  - checkbox "I confirm that I have read and agree to the Candidate Responsibility Statement." [checked]
  - text: I confirm that I have read and agree to the
  - link "Candidate Responsibility Statement":
    - /url: https://www.garp.org/candidate-responsibility
  - text: .
  - checkbox "I confirm that I have read and agree to the Exam Policies." [checked]
  - text: I confirm that I have read and agree to the
  - link "Exam Policies":
    - /url: https://www.garp.org/frm/exam-policies
  - text: .
  - checkbox "Yes, I have read GARP’s Privacy Notice, Code of Conduct, Limitation of Liability, Waiver and Release and Refund Policy." [invalid]
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
  - alert: Please confirm you have read our policies.
  - complementary:
    - text: Add to your registration
    - paragraph: Part I Books
    - paragraph: USD 0.00
    - button "Add"
    - paragraph: Practice Exams
    - paragraph: USD 0.00
    - button "Add"
    - text: Order summary Exam Fee USD 750.00
    - separator
    - text: Total USD 750.00
- contentinfo:
  - img "GARP — Global Association of Risk Professionals"
  - paragraph: We are a not-for-profit organization and the leading globally recognized membership association for risk managers.
  - button "Site map"
  - link "Contact Us":
    - /url: https://www.garp.org/about/contact-us
  - button "WeChat":
    - img
  - link "Facebook":
    - /url: https://www.facebook.com/GARPRisk
    - img
  - link "X":
    - /url: https://x.com/GARP_Risk
    - img
  - link "LinkedIn":
    - /url: https://www.linkedin.com/company/global-association-of-risk-professionals
    - img
  - button "Xiaohongshu":
    - img
  - link "Instagram":
    - /url: https://www.instagram.com/garp_risk/
    - img
  - link "Weibo":
    - /url: https://passport.weibo.com/visitor/visitor?entry=miniblog&a=enter&url=https%3A%2F%2Fweibo.com%2Fgarpfrm&domain=weibo.com&ua=Mozilla%2F5.0&_rand=1727725587146
    - img
  - link "YouTube":
    - /url: https://www.youtube.com/user/GARPvideo
    - img
  - navigation "Site map":
    - heading "FRM" [level=3]
    - list:
      - listitem:
        - link "Overview":
          - /url: https://www.garp.org/frm
      - listitem:
        - link "Program and Exams":
          - /url: https://www.garp.org/frm/program-exams
      - listitem:
        - link "Fees and Payments":
          - /url: https://www.garp.org/frm/fees-payments
      - listitem:
        - link "Exam Logistics":
          - /url: https://www.garp.org/frm/exam-logistics
      - listitem:
        - link "Exam Policies":
          - /url: https://www.garp.org/frm/exam-policies
      - listitem:
        - link "Study Materials":
          - /url: https://www.garp.org/frm/study-materials
      - listitem:
        - link "FAQs":
          - /url: https://www.garp.org/frm/frequently-asked-questions
      - listitem:
        - link "Continuing Professional Development (CPD)":
          - /url: https://www.garp.org/cpd
    - heading "Events" [level=3]
    - list:
      - listitem:
        - link "Chapter Meetings":
          - /url: https://www.garp.org/events/all?type=chapter_meeting
      - listitem:
        - link "Webcasts":
          - /url: https://www.garp.org/webcasts
      - listitem:
        - link "Risk Events":
          - /url: https://www.garp.org/events
    - heading "SCR" [level=3]
    - list:
      - listitem:
        - link "Overview":
          - /url: https://www.garp.org/scr
      - listitem:
        - link "Program and Exam":
          - /url: https://www.garp.org/scr/program-exam
      - listitem:
        - link "Fees and Payments":
          - /url: https://www.garp.org/scr/fees-payments
      - listitem:
        - link "Exam Logistics":
          - /url: https://www.garp.org/scr/exam-logistics
      - listitem:
        - link "Exam Policies":
          - /url: https://www.garp.org/scr/exam-policies
      - listitem:
        - link "Study Materials":
          - /url: https://www.garp.org/scr/study-materials
      - listitem:
        - link "FAQs":
          - /url: https://www.garp.org/scr/frequently-asked-questions
      - listitem:
        - link "Continuing Professional Development (CPD)":
          - /url: https://www.garp.org/cpd
    - heading "Additional Education" [level=3]
    - list:
      - listitem:
        - link "Foundations of Financial Risk (FFR)":
          - /url: https://www.garp.org/courses/foundations-of-financial-risk
      - listitem:
        - link "Financial Risk and Regulation (FRR)":
          - /url: https://www.garp.org/courses/financial-risk-and-regulation
    - heading "RAI" [level=3]
    - list:
      - listitem:
        - link "Overview":
          - /url: https://www.garp.org/rai
      - listitem:
        - link "Program and Exam":
          - /url: https://www.garp.org/rai/program-exam
      - listitem:
        - link "Fees and Payments":
          - /url: https://www.garp.org/rai/fees-payments
      - listitem:
        - link "Exam Logistics":
          - /url: https://www.garp.org/rai/exam-logistics
      - listitem:
        - link "Exam Policies":
          - /url: https://www.garp.org/rai/exam-policies
      - listitem:
        - link "Study Materials":
          - /url: https://www.garp.org/rai/study-materials
      - listitem:
        - link "FAQs":
          - /url: https://www.garp.org/rai/frequently-asked-questions
      - listitem:
        - link "Continuing Professional Development (CPD)":
          - /url: https://www.garp.org/cpd
    - heading "Membership" [level=3]
    - list:
      - listitem:
        - link "Membership Overview":
          - /url: https://www.garp.org/membership
      - listitem:
        - link "Professional Chapters":
          - /url: https://www.garp.org/membership/professional-chapters
      - listitem:
        - link "Volunteer Opportunities":
          - /url: https://www.garp.org/membership/volunteer
      - listitem:
        - link "Certification/Certificate Holder Directory":
          - /url: https://www.garp.org/certificate-holder-directory
      - listitem:
        - link "Career Center":
          - /url: https://www.garp.org/membership/risk-career-center
    - heading "Industry Engagement" [level=3]
    - list:
      - listitem:
        - link "GARP for Students":
          - /url: https://www.garp.org/students
      - listitem:
        - link "University Outreach":
          - /url: https://www.garp.org/about/university-outreach
      - listitem:
        - link "Corporate Outreach":
          - /url: https://www.garp.org/about/corporate-outreach
      - listitem:
        - link "Buy Side Risk Managers Forum":
          - /url: https://www.garp.org/about/buy-side-risk-managers-forum
      - listitem:
        - link "GARP Benchmarking Initiative":
          - /url: https://www.garp.org/garp-benchmarking-initiative
    - heading "Resources" [level=3]
    - list:
      - listitem:
        - link "Risk Intelligence":
          - /url: https://www.garp.org/risk-intelligence
      - listitem:
        - link "Podcasts":
          - /url: https://www.garp.org/podcasts
      - listitem:
        - link "White Papers":
          - /url: https://www.garp.org/white-papers
    - heading "About Us" [level=3]
    - list:
      - listitem:
        - link "About GARP":
          - /url: https://www.garp.org/about
      - listitem:
        - link "Board of Trustees":
          - /url: https://www.garp.org/about/board-of-trustees
      - listitem:
        - link "GARP Risk Institute":
          - /url: https://www.garp.org/sustainability-climate-risk
      - listitem:
        - link "Press Room":
          - /url: https://www.garp.org/about/press-room
      - listitem:
        - link "Careers at GARP":
          - /url: https://www.garp.org/about/careers-at-garp
      - listitem:
        - link "Contact Us":
          - /url: https://www.garp.org/about/contact-us
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
  - button "Back to top"
- region "Notifications alt+T"
```

# Test source

```ts
  54  | 	id: "cc-us",
  55  | 	name: "United States",
  56  | 	countryCode: "United States",
  57  | 	phoneCode: "1",
  58  | 	creditCardAllowed: true,
  59  | 	wireAllowed: true,
  60  | 	achAllowed: true,
  61  | 	provinces: [{ name: "NJ" }, { name: "NY" }],
  62  | 	provinceRequired: true,
  63  | 	postalCodeRequired: true,
  64  | }
  65  | 
  66  | /** Mailing mirrors billing so the loader derives same-as-billing = true. */
  67  | const PROFILE = personalInfoEditData({
  68  | 	mailing: portalAddressFields(),
  69  | 	sameAsBilling: true,
  70  | })
  71  | 
  72  | const WRITE_KEYS = [
  73  | 	"verifyCustomer",
  74  | 	"verifyAddress",
  75  | 	"register",
  76  | 	"checkout",
  77  | 	"payOrder",
  78  | 	"paymentStatus",
  79  | ] as const
  80  | 
  81  | function stripeOptions(): MockOrgOptions {
  82  | 	return {
  83  | 		actions: {
  84  | 			programs: programsListData(),
  85  | 			alertBar: NO_ALERT,
  86  | 			account: accountViewFromPersonalInfo(PROFILE),
  87  | 			// The member survey's picklists.
  88  | 			options: accountOptionsView(),
  89  | 		},
  90  | 		graphql: { BillingCompany: billingCompanyGraphql(PROFILE) },
  91  | 		examreg: {
  92  | 			info: examLoad({
  93  | 				isAuthenticated: true,
  94  | 				contact: { id: "003-member" },
  95  | 				countries: [UNITED_STATES],
  96  | 			}),
  97  | 			fees: feesResult(750),
  98  | 			verifyCustomer: verifyCustomerResult(),
  99  | 			register: examRegisterResult(),
  100 | 			// Relative on purpose: keeps the handoff on the static e2e server.
  101 | 			checkout: { checkoutUrl: "/e2e-checkout-stub", orderId: "801-order" },
  102 | 			payOrder: { completed: true },
  103 | 			// The order's own answer on the return leg — no order number here, so
  104 | 			// the cold-load test can prove the legacy `on` param still renders.
  105 | 			paymentStatus: {
  106 | 				isOrderFound: true,
  107 | 				isPaymentFound: true,
  108 | 				isPaymentSuccess: true,
  109 | 			},
  110 | 			// The guest survey's own picklists; the `options` lists are hints.
  111 | 			demographics: demographicsOptions(),
  112 | 			options: { companies: [], schools: [] },
  113 | 		},
  114 | 	}
  115 | }
  116 | 
  117 | function parse(postData: string | null): Record<string, any> {
  118 | 	return JSON.parse(postData ?? "{}")
  119 | }
  120 | 
  121 | test.describe("stripe checkout leg", () => {
  122 | 	test("card order hands off with honest success/cancel URLs, then the return confirms without re-writing", async ({
  123 | 		page,
  124 | 	}) => {
  125 | 		test.slow()
  126 | 		const org = await installMockOrg(page, stripeOptions())
  127 | 		await page.goto("/programs/frm/register")
  128 | 
  129 | 		// Complete the exam choice; the member record covers everything else.
  130 | 		await page.getByRole("combobox", { name: "Exam part" }).click()
  131 | 		await page
  132 | 			.getByRole("option", { name: "FRM Exam Part I", exact: true })
  133 | 			.click()
  134 | 		await page.getByRole("combobox", { name: "Where you will sit" }).click()
  135 | 		await page.getByRole("option", { name: "Boston" }).click()
  136 | 
  137 | 		// Card payment: no address card mounts — Stripe collects it — and the
  138 | 		// submit relabels to the card wording.
  139 | 		await page.getByRole("radio", { name: "Card", exact: true }).click()
  140 | 		await expect(page.getByText("Billing & shipping")).toHaveCount(0)
  141 | 
  142 | 		await page
  143 | 			.getByRole("checkbox", { name: /Candidate Responsibility/ })
  144 | 			.click()
  145 | 		await page.getByRole("checkbox", { name: /Exam Policies/ }).click()
  146 | 
  147 | 		const submit = page.getByRole("button", { name: "Pay and Register" })
  148 | 		await expect(submit).toBeEnabled()
  149 | 		await submit.click()
  150 | 
  151 | 		const dialog = page.getByRole("dialog")
  152 | 		await expect(
  153 | 			dialog.getByText("You will be taken to our payment provider to pay."),
> 154 | 		).toBeVisible()
      |     ^ Error: expect(locator).toBeVisible() failed
  155 | 		expect(org.hits("register")).toBe(0)
  156 | 		await dialog.getByRole("button", { name: "Pay and Register" }).click()
  157 | 
  158 | 		// The relative checkoutUrl navigates the real browser to the stub.
  159 | 		await expect(page).toHaveURL(/\/e2e-checkout-stub$/)
  160 | 
  161 | 		// The checkout body's return contract.
  162 | 		expect(org.hits("checkout")).toBe(1)
  163 | 		const checkoutBody = parse(org.of("checkout")[0].postData)
  164 | 		expect(checkoutBody.orderId).toBe("801-order")
  165 | 		const successUrl = String(checkoutBody.successUrl)
  166 | 		expect(successUrl).toContain("/programs/frm/register?")
  167 | 		expect(successUrl).toContain("stripe_return=1")
  168 | 		expect(successUrl).toContain("oid=801-order")
  169 | 		// The order NUMBER does not travel — the status poll answers with it.
  170 | 		expect(successUrl).not.toContain("on=")
  171 | 		// Cancel carries the oid the rollback depends on.
  172 | 		expect(String(checkoutBody.cancelUrl)).toContain(
  173 | 			"/programs/frm/register?checkout_cancelled=1&oid=801-order",
  174 | 		)
  175 | 
  176 | 		// Card sequence: verify → register → checkout. No verifyAddress (Stripe
  177 | 		// owns the address), and the money calls NEVER fire from this side.
  178 | 		expect(
  179 | 			org.calls
  180 | 				.filter(
  181 | 					(call) =>
  182 | 						call.kind === "examreg" &&
  183 | 						(WRITE_KEYS as readonly string[]).includes(call.key),
  184 | 				)
  185 | 				.map((call) => call.key),
  186 | 		).toEqual(["verifyCustomer", "register", "checkout"])
  187 | 		expect(org.hits("payOrder")).toBe(0)
  188 | 
  189 | 		// The provider comes back to the successUrl it was handed. The order
  190 | 		// number arrives from the poll, not the URL.
  191 | 		org.use({
  192 | 			examreg: {
  193 | 				paymentStatus: {
  194 | 					isOrderFound: true,
  195 | 					isPaymentFound: true,
  196 | 					isPaymentSuccess: true,
  197 | 					orderNumber: "ORD-1001",
  198 | 				},
  199 | 			},
  200 | 		})
  201 | 		await page.goto(successUrl)
  202 | 		await expect(page.getByText("Thank you — payment received")).toBeVisible()
  203 | 		await expect(page.getByText("ORD-1001")).toBeVisible()
  204 | 		expect(parse(org.of("paymentStatus")[0].postData)).toEqual({
  205 | 			orderId: "801-order",
  206 | 		})
  207 | 
  208 | 		// The survey stands between the confirmation and the actions; Skip is a
  209 | 		// first-class way past it, and saves nothing.
  210 | 		await expect(
  211 | 			page.getByRole("heading", { name: /Help us tailor your/ }),
  212 | 		).toBeVisible()
  213 | 		await expect(page.getByRole("link", { name: "Go to dashboard" })).toHaveCount(0)
  214 | 		await page.getByRole("button", { name: "Skip for now" }).click()
  215 | 		await expect(page.getByRole("link", { name: "Go to dashboard" })).toBeVisible()
  216 | 		expect(org.hits("profile")).toBe(0)
  217 | 
  218 | 		// Nothing was written twice: still one register, still zero payOrder.
  219 | 		expect(org.hits("register")).toBe(1)
  220 | 		expect(org.hits("payOrder")).toBe(0)
  221 | 	})
  222 | 
  223 | 	test("payment-return cold load: confirmation before ANY form, zero write calls, numeric params survive", async ({
  224 | 		page,
  225 | 	}) => {
  226 | 		const org = await installMockOrg(page, stripeOptions())
  227 | 
  228 | 		// Fresh page load with no React state — and `oid`/`on` all-numeric, so
  229 | 		// the router JSON-parses them into numbers before the schema coerces
  230 | 		// them back. The order behind this URL is already charged.
  231 | 		await page.goto("/programs/frm/register?stripe_return=1&oid=801&on=1234")
  232 | 
  233 | 		await expect(page.getByText("Thank you — payment received")).toBeVisible()
  234 | 		// The numeric order number renders as itself, not `undefined`.
  235 | 		await expect(page.getByText("1234", { exact: true })).toBeVisible()
  236 | 
  237 | 		// No form behind the confirmation to invite a second registration.
  238 | 		await expect(page.getByRole("combobox", { name: "Exam part" })).toHaveCount(0)
  239 | 		await expect(
  240 | 			page.getByRole("button", { name: "Pay and Register" }),
  241 | 		).toHaveCount(0)
  242 | 
  243 | 		// The poll on the numeric id (coerced back to a string) is the ONLY
  244 | 		// registration call. Zero writes — and no pricing or form load either,
  245 | 		// because the form never mounted.
  246 | 		expect(parse(org.of("paymentStatus")[0].postData)).toEqual({ orderId: "801" })
  247 | 		for (const key of WRITE_KEYS) {
  248 | 			expect(org.hits(key)).toBe(key === "paymentStatus" ? 1 : 0)
  249 | 		}
  250 | 		expect(org.hits("fees")).toBe(0)
  251 | 		expect(org.hits("info")).toBe(0)
  252 | 	})
  253 | 
  254 | 	test("a GUEST's payment return is not bounced off the public route", async ({
```