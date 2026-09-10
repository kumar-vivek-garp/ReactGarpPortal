# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: registration.membership.stripe.spec.ts >> membership stripe leg >> auto-renew rides register, and checkout returns to /membership/register
- Location: e2e/mocked/registration.membership.stripe.spec.ts:98:2

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
  - link "Membership":
    - /url: /membership?tab=benefits
  - heading "Member Registration" [level=1]
  - paragraph: Total
  - text: USD 195.00
  - button "Pay and Register"
  - text: Exclusive Offer for Members (optional)
  - paragraph: Risk.net
  - paragraph: GARP-Risk.net Content Hub — One Hub. Three Resources.
  - paragraph: "Participating members will be given 12 months of online access to a content hub containing three resources: 80+ Books, nine Journals, and a hand-picked selection of in-depth news and analysis each week."
  - paragraph:
    - text: To learn more about how Risk.net will use your data, please refer to their
    - link "privacy policy":
      - /url: https://www.infopro-digital.com/privacy-policy/
    - text: .
  - paragraph: USD 100.00 for 12 months
  - button "Add"
  - text: Payment Payment method
  - radiogroup "Payment type":
    - radio "Card" [checked]
    - radio "Wire transfer"
    - radio "ACH"
  - paragraph: You will be taken to our payment provider to complete checkout.
  - text: Automatic Renewal
  - 'checkbox "Enrol in Membership Automatic Renewal: your GARP Individual Membership renews each year at the then-current rate using your saved payment method, until you cancel. You can cancel any time from your account." [checked]'
  - text: "Enrol in Membership Automatic Renewal: your GARP Individual Membership renews each year at the then-current rate using your saved payment method, until you cancel. You can cancel any time from your account. Candidate Acknowledgements"
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
    - text: Order summary Individual Membership USD 195.00
    - separator
    - text: Total USD 195.00
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
  21  |  * The membership CARD leg. The auto-renew consent is offered on a card
  22  |  * order (unticked), rides `register` as `autoRenew`, and the checkout hands
  23  |  * off with a successUrl that returns to THIS route — `/membership/register`,
  24  |  * not `/programs/…`. Coming back cold with all-numeric params shows the
  25  |  * confirmation with no form and no writes, on BOTH twins: the public route's
  26  |  * guard must not bounce a member's payment return either.
  27  |  */
  28  | 
  29  | const NO_ALERT = {
  30  | 	statusMessage: null,
  31  | 	statusCode: 200,
  32  | 	examType: null,
  33  | 	examPart: null,
  34  | 	alertStatus: null,
  35  | 	deadline: null,
  36  | 	orderId: null,
  37  | 	route: null,
  38  | } satisfies AlertBarView
  39  | 
  40  | const PROFILE = personalInfoEditData({
  41  | 	mailing: portalAddressFields(),
  42  | 	sameAsBilling: true,
  43  | })
  44  | 
  45  | const WRITE_KEYS = [
  46  | 	"verifyCustomer",
  47  | 	"verifyAddress",
  48  | 	"register",
  49  | 	"checkout",
  50  | 	"payOrder",
  51  | 	"paymentStatus",
  52  | ] as const
  53  | 
  54  | function parse(postData: string | null): Record<string, any> {
  55  | 	return JSON.parse(postData ?? "{}")
  56  | }
  57  | 
  58  | async function priceCart(route: Route) {
  59  | 	const body = parse(route.request().postData())
  60  | 	await route.fulfill({
  61  | 		json: memberPortalEnvelope(
  62  | 			membershipFeesResult({ riskNet: body.riskNetSelected === true }),
  63  | 		),
  64  | 	})
  65  | }
  66  | 
  67  | function stripeOptions(): MockOrgOptions {
  68  | 	return {
  69  | 		actions: {
  70  | 			alertBar: NO_ALERT,
  71  | 			account: accountViewFromPersonalInfo(PROFILE),
  72  | 			options: accountOptionsView(),
  73  | 		},
  74  | 		graphql: { BillingCompany: billingCompanyGraphql(PROFILE) },
  75  | 		examreg: {
  76  | 			info: membershipLoad({
  77  | 				isAuthenticated: true,
  78  | 				contact: { id: "003-member" },
  79  | 			}),
  80  | 			fees: priceCart,
  81  | 			verifyCustomer: verifyCustomerResult(),
  82  | 			register: examRegisterResult({ registrationId: null, contractId: null }),
  83  | 			// Relative on purpose: keeps the handoff on the static e2e server.
  84  | 			checkout: { checkoutUrl: "/e2e-checkout-stub", orderId: "801-order" },
  85  | 			payOrder: { completed: true },
  86  | 			paymentStatus: {
  87  | 				isOrderFound: true,
  88  | 				isPaymentFound: true,
  89  | 				isPaymentSuccess: true,
  90  | 			},
  91  | 			demographics: demographicsOptions(),
  92  | 			options: { companies: [], schools: [] },
  93  | 		},
  94  | 	}
  95  | }
  96  | 
  97  | test.describe("membership stripe leg", () => {
  98  | 	test("auto-renew rides register, and checkout returns to /membership/register", async ({
  99  | 		page,
  100 | 	}) => {
  101 | 		test.slow()
  102 | 		const org = await installMockOrg(page, stripeOptions())
  103 | 		await page.goto("/membership/register")
  104 | 
  105 | 		await expect(page.getByText("USD 195.00").first()).toBeVisible()
  106 | 		await page.getByRole("radio", { name: "Card", exact: true }).click()
  107 | 		await expect(page.getByText("Billing & shipping")).toHaveCount(0)
  108 | 
  109 | 		const consent = page.getByRole("checkbox", {
  110 | 			name: /Membership Automatic Renewal/,
  111 | 		})
  112 | 		await expect(consent).not.toBeChecked()
  113 | 		await consent.click()
  114 | 
  115 | 		const submit = page.getByRole("button", { name: "Pay and Register" })
  116 | 		await expect(submit).toBeEnabled()
  117 | 		await submit.click()
  118 | 		const dialog = page.getByRole("dialog")
  119 | 		await expect(
  120 | 			dialog.getByText("You will be taken to our payment provider to pay."),
> 121 | 		).toBeVisible()
      |     ^ Error: expect(locator).toBeVisible() failed
  122 | 		expect(org.hits("register")).toBe(0)
  123 | 		await dialog.getByRole("button", { name: "Pay and Register" }).click()
  124 | 
  125 | 		await expect(page).toHaveURL(/\/e2e-checkout-stub$/)
  126 | 
  127 | 		expect(parse(org.of("register")[0].postData)).toMatchObject({
  128 | 			type: "mem",
  129 | 			autoRenew: true,
  130 | 			paymentType: "Stripe",
  131 | 			riskNetSelected: false,
  132 | 		})
  133 | 
  134 | 		const checkoutBody = parse(org.of("checkout")[0].postData)
  135 | 		expect(checkoutBody.orderId).toBe("801-order")
  136 | 		const successUrl = String(checkoutBody.successUrl)
  137 | 		expect(successUrl).toContain("/membership/register?")
  138 | 		expect(successUrl).toContain("stripe_return=1")
  139 | 		expect(successUrl).toContain("oid=801-order")
  140 | 		expect(successUrl).not.toContain("/programs/")
  141 | 		expect(String(checkoutBody.cancelUrl)).toContain(
  142 | 			"/membership/register?checkout_cancelled=1&oid=801-order",
  143 | 		)
  144 | 
  145 | 		expect(
  146 | 			org.calls
  147 | 				.filter(
  148 | 					(call) =>
  149 | 						call.kind === "examreg" &&
  150 | 						(WRITE_KEYS as readonly string[]).includes(call.key),
  151 | 				)
  152 | 				.map((call) => call.key),
  153 | 		).toEqual(["verifyCustomer", "register", "checkout"])
  154 | 		expect(org.hits("verifyAddress")).toBe(0)
  155 | 		expect(org.hits("payOrder")).toBe(0)
  156 | 	})
  157 | 
  158 | 	test("payment-return cold load on the member twin: confirmation, zero writes, numeric params", async ({
  159 | 		page,
  160 | 	}) => {
  161 | 		const org = await installMockOrg(page, stripeOptions())
  162 | 
  163 | 		await page.goto("/membership/register?stripe_return=1&oid=801&on=1234")
  164 | 
  165 | 		await expect(page.getByText("Thank you — payment received")).toBeVisible()
  166 | 		await expect(page.getByText("1234", { exact: true })).toBeVisible()
  167 | 		await expect(page.getByRole("button", { name: "Pay and Register" })).toHaveCount(0)
  168 | 
  169 | 		expect(parse(org.of("paymentStatus")[0].postData)).toEqual({ orderId: "801" })
  170 | 		for (const key of WRITE_KEYS) {
  171 | 			expect(org.hits(key)).toBe(key === "paymentStatus" ? 1 : 0)
  172 | 		}
  173 | 		expect(org.hits("fees")).toBe(0)
  174 | 		expect(org.hits("info")).toBe(0)
  175 | 	})
  176 | 
  177 | 	test("a MEMBER's payment return on the public twin is not bounced", async ({
  178 | 		page,
  179 | 	}) => {
  180 | 		const org = await installMockOrg(page, stripeOptions())
  181 | 
  182 | 		await page.goto("/registration/membership?stripe_return=1&oid=801&on=1234")
  183 | 
  184 | 		// The guard suppresses its redirect on a payment return — the order
  185 | 		// behind this URL is already charged and the params must survive.
  186 | 		await expect(page).toHaveURL(/\/registration\/membership\?/)
  187 | 		await expect(page.getByText("Thank you — payment received")).toBeVisible()
  188 | 		await expect(page.getByText("1234", { exact: true })).toBeVisible()
  189 | 		for (const key of WRITE_KEYS) {
  190 | 			expect(org.hits(key)).toBe(key === "paymentStatus" ? 1 : 0)
  191 | 		}
  192 | 	})
  193 | })
  194 | 
```