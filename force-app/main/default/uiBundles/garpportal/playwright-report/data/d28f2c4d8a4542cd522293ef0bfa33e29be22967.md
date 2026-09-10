# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: registration.membership.member.spec.ts >> member membership registration >> wire-transfer journey: member-shaped, no auto-renew, ordered call sequence, payOrder once
- Location: e2e/mocked/registration.membership.member.spec.ts:127:2

# Error details

```
Error: expect(locator).toHaveValue(expected) failed

Locator: getByRole('textbox', { name: 'Mobile phone', exact: true })
Expected: "5551234"
Timeout: 5000ms
Error: element(s) not found

Call log:
  - Expect "toHaveValue" with timeout 5000ms
  - waiting for getByRole('textbox', { name: 'Mobile phone', exact: true })

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
    - radio "Card"
    - radio "Wire transfer"
    - radio "ACH"
  - text: Candidate Acknowledgements
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
- region "Notifications alt+T"
```

# Test source

```ts
  42  | 	sameAsBilling: true,
  43  | })
  44  | 
  45  | function parse(postData: string | null): Record<string, any> {
  46  | 	return JSON.parse(postData ?? "{}")
  47  | }
  48  | 
  49  | async function priceCart(route: Route) {
  50  | 	const body = parse(route.request().postData())
  51  | 	await route.fulfill({
  52  | 		json: memberPortalEnvelope(
  53  | 			membershipFeesResult({
  54  | 				riskNet: body.riskNetSelected === true,
  55  | 				offline: Boolean(body.paymentType) && body.paymentType !== "Stripe",
  56  | 			}),
  57  | 		),
  58  | 	})
  59  | }
  60  | 
  61  | function memberOptions(): MockOrgOptions {
  62  | 	return {
  63  | 		actions: {
  64  | 			alertBar: NO_ALERT,
  65  | 			account: accountViewFromPersonalInfo(PROFILE),
  66  | 		},
  67  | 		graphql: { BillingCompany: billingCompanyGraphql(PROFILE) },
  68  | 		examreg: {
  69  | 			info: membershipLoad({
  70  | 				isAuthenticated: true,
  71  | 				contact: { id: "003-member" },
  72  | 			}),
  73  | 			fees: priceCart,
  74  | 			verifyCustomer: verifyCustomerResult(),
  75  | 			verifyAddress: {
  76  | 				billingValid: true,
  77  | 				billingAllowed: true,
  78  | 				shippingValid: true,
  79  | 				shippingAllowed: true,
  80  | 				message: null,
  81  | 			},
  82  | 			// A membership order: no attempt, no programme contract.
  83  | 			register: examRegisterResult({ registrationId: null, contractId: null }),
  84  | 			payOrder: { completed: true },
  85  | 			// A wire order's real answer: the order exists, no payment yet.
  86  | 			paymentStatus: { isOrderFound: true, isPaymentFound: false },
  87  | 		},
  88  | 	}
  89  | }
  90  | 
  91  | test.describe("membership route twins", () => {
  92  | 	test("a member on the public address lands on /membership/register with the query intact", async ({
  93  | 		page,
  94  | 	}) => {
  95  | 		await installMockOrg(page, memberOptions())
  96  | 
  97  | 		await page.goto(
  98  | 			"/registration/membership?track_cta=PortalMembershipPage&regCode=TEAM24",
  99  | 		)
  100 | 
  101 | 		await expect(page).toHaveURL(
  102 | 			/\/membership\/register\?(?=.*track_cta=PortalMembershipPage)(?=.*regCode=TEAM24)/,
  103 | 		)
  104 | 		await expect(
  105 | 			page.getByRole("heading", { level: 1, name: /Member Registration/ }),
  106 | 		).toBeVisible()
  107 | 	})
  108 | 
  109 | 	test("a guest on the member address is handed to the public twin, query intact", async ({
  110 | 		page,
  111 | 	}) => {
  112 | 		await installMockOrg(page, {
  113 | 			identity: "guest",
  114 | 			examreg: { info: membershipLoad(), fees: priceCart },
  115 | 		})
  116 | 
  117 | 		await page.goto("/membership/register?regCode=TEAM24&track_cta=PortalGatedContent")
  118 | 
  119 | 		await expect(page).toHaveURL(
  120 | 			/\/registration\/membership\?(?=.*regCode=TEAM24)(?=.*track_cta=PortalGatedContent)/,
  121 | 		)
  122 | 		await expect(page.getByRole("textbox", { name: "First name" })).toHaveValue("")
  123 | 	})
  124 | })
  125 | 
  126 | test.describe("member membership registration", () => {
  127 | 	test("wire-transfer journey: member-shaped, no auto-renew, ordered call sequence, payOrder once", async ({
  128 | 		page,
  129 | 	}) => {
  130 | 		test.slow()
  131 | 		const org = await installMockOrg(page, memberOptions())
  132 | 
  133 | 		await page.goto("/membership/register?track_cta=PortalMembershipPage")
  134 | 
  135 | 		await expect(
  136 | 			page.getByRole("heading", { level: 1, name: /Member Registration/ }),
  137 | 		).toBeVisible()
  138 | 		// Member-shaped: name/email from the record; phone stays.
  139 | 		await expect(page.getByRole("textbox", { name: "First name" })).toHaveCount(0)
  140 | 		await expect(
  141 | 			page.getByRole("textbox", { name: "Mobile phone", exact: true }),
> 142 | 		).toHaveValue("5551234")
      |     ^ Error: expect(locator).toHaveValue(expected) failed
  143 | 		// Back goes to Membership Benefits, not the programmes list. Scoped to
  144 | 		// the form: the sidebar carries links by the same names.
  145 | 		const main = page.getByRole("main")
  146 | 		await expect(main.getByRole("link", { name: "Membership" })).toBeVisible()
  147 | 		await expect(main.getByRole("link", { name: "Programs" })).toHaveCount(0)
  148 | 		await expect(page.getByRole("combobox", { name: "Exam part" })).toHaveCount(0)
  149 | 
  150 | 		// Priced with nothing chosen, then the offline method adds its fee.
  151 | 		await expect(page.getByText("USD 195.00").first()).toBeVisible()
  152 | 		await page.getByRole("radio", { name: "Wire transfer" }).click()
  153 | 		await expect(page.getByText("Billing & shipping")).toBeVisible()
  154 | 		await expect(page.getByText("Processing Fee")).toBeVisible()
  155 | 		await expect(page.getByText("USD 245.00").first()).toBeVisible()
  156 | 		await expect(
  157 | 			page.getByRole("checkbox", { name: /Membership Automatic Renewal/ }),
  158 | 		).toHaveCount(0)
  159 | 
  160 | 		// Submit STAGES: the dialog opens and nothing has been written.
  161 | 		const submit = page.getByRole("button", { name: "Submit Order" })
  162 | 		await expect(submit).toBeEnabled()
  163 | 		await submit.click()
  164 | 		const dialog = page.getByRole("dialog")
  165 | 		await expect(dialog.getByText("Confirm your registration")).toBeVisible()
  166 | 		expect(org.hits("verifyCustomer")).toBe(0)
  167 | 		expect(org.hits("register")).toBe(0)
  168 | 
  169 | 		await dialog.getByRole("button", { name: "Submit Order" }).click()
  170 | 
  171 | 		await expect(page.getByText("Your order has been submitted")).toBeVisible()
  172 | 		await expect(page.getByText("ORD-1001")).toBeVisible()
  173 | 		await page.getByRole("button", { name: "Skip for now" }).click()
  174 | 		await expect(page.getByRole("link", { name: "Go to dashboard" })).toBeVisible()
  175 | 
  176 | 		const WRITE_KEYS = new Set([
  177 | 			"verifyCustomer",
  178 | 			"verifyAddress",
  179 | 			"register",
  180 | 			"payOrder",
  181 | 			"paymentStatus",
  182 | 		])
  183 | 		expect(
  184 | 			org.calls
  185 | 				.filter((call) => call.kind === "examreg" && WRITE_KEYS.has(call.key))
  186 | 				.map((call) => call.key),
  187 | 		).toEqual(["verifyCustomer", "verifyAddress", "register", "payOrder", "paymentStatus"])
  188 | 		expect(org.hits("payOrder")).toBe(1)
  189 | 
  190 | 		// The member path's identity call carries the tag; nothing else does.
  191 | 		expect(parse(org.of("verifyCustomer")[0].postData).tracking).toEqual({
  192 | 			trackCta: "PortalMembershipPage",
  193 | 		})
  194 | 
  195 | 		const registerBody = parse(org.of("register")[0].postData)
  196 | 		expect(registerBody.type).toBe("mem")
  197 | 		expect(registerBody.sessionId).toBe("S-1")
  198 | 		expect(registerBody.paymentType).toBe("Wire Transfer")
  199 | 		expect(registerBody.riskNetSelected).toBe(false)
  200 | 		expect(registerBody.membershipSelected).toBe(false)
  201 | 		expect(registerBody.autoRenew).toBe(false)
  202 | 		expect(registerBody.selection).toEqual({ partSelected: null, part1: null, part2: null })
  203 | 		expect(registerBody.materials).toEqual([])
  204 | 		expect(registerBody.personal).toBeNull()
  205 | 		expect(registerBody).not.toHaveProperty("tracking")
  206 | 		expect(registerBody.consent.examPolicy).toBe(false)
  207 | 		expect(registerBody.billingAddress.country).toBe("United States")
  208 | 	})
  209 | })
  210 | 
```