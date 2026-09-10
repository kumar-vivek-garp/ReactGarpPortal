# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: registration.member.spec.ts >> member exam registration >> wire-transfer journey: staged confirm, ordered call sequence, payOrder once
- Location: e2e/mocked/registration.member.spec.ts:88:2

# Error details

```
Error: expect(locator).toBeVisible() failed

Locator: getByText('Contact details')
Expected: visible
Timeout: 5000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" with timeout 5000ms
  - waiting for getByText('Contact details')

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
    - text: Add to your registration
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
- region "Notifications alt+T"
```

# Test source

```ts
  29  |  *
  30  |  * `payOrder` is the not-idempotent call — the final assertion that it was
  31  |  * hit exactly once IS the point of this spec.
  32  |  */
  33  | 
  34  | /** No floating alert over the form's sticky bar. */
  35  | const NO_ALERT = {
  36  | 	statusMessage: null,
  37  | 	statusCode: 200,
  38  | 	examType: null,
  39  | 	examPart: null,
  40  | 	alertStatus: null,
  41  | 	deadline: null,
  42  | 	orderId: null,
  43  | 	route: null,
  44  | } satisfies AlertBarView
  45  | 
  46  | /**
  47  |  * The factory's default country carries no payment permissions, which would
  48  |  * leave every tile disabled — this journey needs wire (and the country's own
  49  |  * province/postal rules, so the prefilled billing address validates).
  50  |  */
  51  | const UNITED_STATES: RegistrationCountry = {
  52  | 	id: "cc-us",
  53  | 	name: "United States",
  54  | 	countryCode: "United States",
  55  | 	phoneCode: "1",
  56  | 	creditCardAllowed: true,
  57  | 	wireAllowed: true,
  58  | 	achAllowed: true,
  59  | 	provinces: [{ name: "NJ" }, { name: "NY" }],
  60  | 	provinceRequired: true,
  61  | 	postalCodeRequired: true,
  62  | }
  63  | 
  64  | function memberExamLoad() {
  65  | 	return examLoad({
  66  | 		isAuthenticated: true,
  67  | 		contact: { id: "003-member" },
  68  | 		countries: [UNITED_STATES],
  69  | 	})
  70  | }
  71  | 
  72  | /**
  73  |  * The member's own record, served as the composed account payload the
  74  |  * registration panel hydrates from.
  75  |  * Mailing mirrors billing on purpose: the loader DERIVES same-as-billing by
  76  |  * comparing the two, so differing addresses would mount the shipping card.
  77  |  */
  78  | const PROFILE = personalInfoEditData({
  79  | 	mailing: portalAddressFields(),
  80  | 	sameAsBilling: true,
  81  | })
  82  | 
  83  | function parse(postData: string | null): Record<string, any> {
  84  | 	return JSON.parse(postData ?? "{}")
  85  | }
  86  | 
  87  | test.describe("member exam registration", () => {
  88  | 	test("wire-transfer journey: staged confirm, ordered call sequence, payOrder once", async ({
  89  | 		page,
  90  | 	}) => {
  91  | 		test.slow()
  92  | 
  93  | 		const org = await installMockOrg(page, {
  94  | 			actions: {
  95  | 				programs: programsListData(),
  96  | 				alertBar: NO_ALERT,
  97  | 				account: accountViewFromPersonalInfo(PROFILE),
  98  | 			},
  99  | 			graphql: { BillingCompany: billingCompanyGraphql(PROFILE) },
  100 | 			examreg: {
  101 | 				info: memberExamLoad(),
  102 | 				fees: feesResult(750),
  103 | 				verifyCustomer: verifyCustomerResult(),
  104 | 				verifyAddress: {
  105 | 					billingValid: true,
  106 | 					billingAllowed: true,
  107 | 					shippingValid: true,
  108 | 					shippingAllowed: true,
  109 | 					message: null,
  110 | 				},
  111 | 				register: examRegisterResult(),
  112 | 				payOrder: { completed: true },
  113 | 				// A wire order's real answer: the order exists, and no payment is recorded
  114 | 			// yet — finance settles it days later. The poll accepts that first time.
  115 | 			paymentStatus: { isOrderFound: true, isPaymentFound: false },
  116 | 			},
  117 | 		})
  118 | 
  119 | 		await page.goto("/programs/frm/register")
  120 | 
  121 | 		// The programme's own h1, through the mega-menu heading.
  122 | 		await expect(
  123 | 			page.getByRole("heading", { level: 1, name: /Financial Risk Manager/ }),
  124 | 		).toBeVisible()
  125 | 
  126 | 		// Member-shaped details card: name/email come from the record, so their
  127 | 		// controls are gone — the phone stays, prefilled, because exam-day
  128 | 		// messages go to it.
> 129 | 		await expect(page.getByText("Contact details")).toBeVisible()
      |                                                   ^ Error: expect(locator).toBeVisible() failed
  130 | 		await expect(page.getByRole("textbox", { name: "First name" })).toHaveCount(0)
  131 | 		await expect(page.getByRole("textbox", { name: "Last name" })).toHaveCount(0)
  132 | 		await expect(
  133 | 			page.getByRole("textbox", { name: "Email", exact: true }),
  134 | 		).toHaveCount(0)
  135 | 		await expect(
  136 | 			page.getByRole("textbox", { name: "Mobile phone", exact: true }),
  137 | 		).toHaveValue("5551234")
  138 | 
  139 | 		// Pick the exam: part, then site. The sitting auto-resolves to the
  140 | 		// earliest (May 2027 / rate-1a), so only the exam centre is a choice.
  141 | 		await page.getByRole("combobox", { name: "Exam part" }).click()
  142 | 		await page
  143 | 			.getByRole("option", { name: "FRM Exam Part I", exact: true })
  144 | 			.click()
  145 | 		await page.getByRole("combobox", { name: "Where you will sit" }).click()
  146 | 		await page.getByRole("option", { name: "Boston" }).click()
  147 | 
  148 | 		// The debounced pricing settles on the FULL selection...
  149 | 		await expect
  150 | 			.poll(() =>
  151 | 				org.of("fees").some((call) => {
  152 | 					const body = parse(call.postData)
  153 | 					return (
  154 | 						body.selection?.part1?.rateId === "rate-1a" &&
  155 | 						body.selection?.part1?.siteId === "site-a1"
  156 | 					)
  157 | 				}),
  158 | 			)
  159 | 			.toBe(true)
  160 | 		// ...and the priced total reaches the bar (AnimatedAmount settles there).
  161 | 		await expect(page.getByText("USD 750.00").first()).toBeVisible()
  162 | 
  163 | 		// Offline payment: the Wire Transfer tile, which raises the address card
  164 | 		// (prefilled from the member's record) and relabels submit.
  165 | 		await page.getByRole("radio", { name: "Wire transfer" }).click()
  166 | 		await expect(page.getByText("Billing & shipping")).toBeVisible()
  167 | 		await expect(
  168 | 			page.getByRole("textbox", { name: "Street address", exact: true }),
  169 | 		).toHaveValue("1 Main St")
  170 | 
  171 | 		// Wait for the re-price under the new payment type to settle, then prove
  172 | 		// the 400ms debounce: a burst of keystrokes into a priced field buys ONE
  173 | 		// fees call, not one per character.
  174 | 		await expect
  175 | 			.poll(() =>
  176 | 				org
  177 | 					.of("fees")
  178 | 					.some((call) => parse(call.postData).paymentType === "Wire Transfer"),
  179 | 			)
  180 | 			.toBe(true)
  181 | 		await page.waitForTimeout(700)
  182 | 		const baseline = org.hits("fees")
  183 | 		const city = page.getByRole("textbox", { name: "City", exact: true })
  184 | 		await city.click()
  185 | 		await page.keyboard.press("End")
  186 | 		await city.pressSequentially("town", { delay: 40 })
  187 | 		await expect(city).toHaveValue("Hobokentown")
  188 | 		await expect.poll(() => org.hits("fees")).toBe(baseline + 1)
  189 | 		await page.waitForTimeout(700)
  190 | 		expect(org.hits("fees")).toBe(baseline + 1)
  191 | 
  192 | 		// Submit stays closed until the required consents are in.
  193 | 		const submit = page.getByRole("button", { name: "Submit Order" })
  194 | 		await expect(submit).toBeDisabled()
  195 | 		await page
  196 | 			.getByRole("checkbox", { name: /Candidate Responsibility/ })
  197 | 			.click()
  198 | 		await page.getByRole("checkbox", { name: /Exam Policies/ }).click()
  199 | 		await expect(submit).toBeEnabled()
  200 | 
  201 | 		// Submit STAGES: the dialog opens with the figures and NOTHING has been
  202 | 		// written yet — no identity call, no order.
  203 | 		await submit.click()
  204 | 		const dialog = page.getByRole("dialog")
  205 | 		await expect(dialog.getByText("Confirm your registration")).toBeVisible()
  206 | 		await expect(dialog.getByText("An invoice will be raised")).toBeVisible()
  207 | 		expect(org.hits("verifyCustomer")).toBe(0)
  208 | 		expect(org.hits("register")).toBe(0)
  209 | 
  210 | 		// Confirm fires the whole sequence.
  211 | 		await dialog.getByRole("button", { name: "Submit Order" }).click()
  212 | 
  213 | 		// The invoiced outcome, with the order number given prominence.
  214 | 		await expect(page.getByText("Your order has been submitted")).toBeVisible()
  215 | 		await expect(page.getByText("ORD-1001")).toBeVisible()
  216 | 		// Member outcome offers the in-portal destinations.
  217 | 		// The optional survey stands between the outcome and its actions —
  218 | 		// shown after every successful registration, wire included.
  219 | 		await expect(
  220 | 			page.getByRole("heading", { name: /Help us tailor your/ }),
  221 | 		).toBeVisible()
  222 | 		await page.getByRole("button", { name: "Skip for now" }).click()
  223 | 		await expect(
  224 | 			page.getByRole("link", { name: "Go to dashboard" }),
  225 | 		).toBeVisible()
  226 | 
  227 | 		// THE contract: the four writes in order — verify, address check (wire
  228 | 		// collects an address), register, the one payOrder, then the poll.
  229 | 		const WRITE_KEYS = new Set([
```