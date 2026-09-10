# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: registration.deferred.spec.ts >> deferred card flow (staged registration) >> a staged register result opens checkout under the staged id — never 'registered'
- Location: e2e/mocked/registration.deferred.spec.ts:139:2

# Error details

```
Test timeout of 90000ms exceeded.
```

```
Error: locator.click: Test timeout of 90000ms exceeded.
Call log:
  - waiting for getByRole('combobox', { name: 'Mobile phone country code' })

```

# Page snapshot

```yaml
- generic [ref=e2]:
  - generic [ref=e4]:
    - banner [ref=e5]:
      - link "FRM" [ref=e6] [cursor=pointer]:
        - /url: https://www.garp.org/
        - img [ref=e7]
      - generic [ref=e8]:
        - button "Switch to dark mode" [ref=e9] [cursor=pointer]:
          - generic [ref=e10]:
            - img
          - generic [ref=e11]:
            - img
        - link "Sign In" [ref=e12] [cursor=pointer]:
          - /url: /Login?startUrl=%2Fregistration%2Ffrm
          - img
          - text: Sign In
    - generic [ref=e14]:
      - main [ref=e15]:
        - generic [ref=e16]:
          - img [ref=e17]
          - generic [ref=e18]:
            - img [ref=e19]
            - heading "Financial Risk Manager (FRM®) Exam Registration" [level=1] [ref=e20]:
              - text: Financial Risk Manager (
              - generic [ref=e21]:
                - text: FRM
                - superscript [ref=e22]: ®
              - text: ) Exam Registration
        - generic [ref=e26]:
          - alert [ref=e27]:
            - generic [ref=e28]:
              - text: Returning candidates registering for the FRM Part II Exam must sign in to continue with registration.
              - link "Sign in" [ref=e29] [cursor=pointer]:
                - /url: /Login?startUrl=%2Fregistration%2Ffrm
          - generic [ref=e30]:
            - generic [ref=e31]:
              - generic [ref=e32]:
                - generic [ref=e33]:
                  - generic [ref=e34]:
                    - img [ref=e35]
                    - text: Individual Details
                  - paragraph [ref=e38]: We will use these details to create your GARP account and to contact you about the exam.
                - generic [ref=e39]:
                  - generic [ref=e40]:
                    - generic [ref=e41]:
                      - text: First name
                      - generic [ref=e42]: "*"
                    - textbox "First name" [ref=e43]: Grace
                  - generic [ref=e44]:
                    - generic [ref=e45]:
                      - text: Last name
                      - generic [ref=e46]: "*"
                    - textbox "Last name" [active] [ref=e47]: Hopper
                  - generic [ref=e48]:
                    - generic [ref=e49]:
                      - text: Email
                      - generic [ref=e50]: "*"
                    - textbox "Email" [ref=e51]: guest@example.org
              - generic [ref=e52]:
                - generic [ref=e54]:
                  - img [ref=e55]
                  - text: Your exam
                - generic [ref=e58]:
                  - generic [ref=e59]:
                    - generic [ref=e60]:
                      - text: Exam part
                      - generic [ref=e61]: "*"
                    - combobox "Exam part" [ref=e62]:
                      - generic: Select exam
                      - generic [ref=e63]:
                        - img
                    - combobox [ref=e64]
                  - generic [ref=e65]:
                    - paragraph [ref=e66]: Part I
                    - generic [ref=e67]:
                      - generic [ref=e68]:
                        - text: Sitting
                        - generic [ref=e69]: "*"
                      - radiogroup [ref=e70]:
                        - generic [ref=e71]:
                          - radio "May 2027 registration · USD 600.00" [ref=e72]
                          - radio
                          - generic [ref=e73]:
                            - generic [ref=e74]: May 2027
                            - generic [ref=e75]: registration · USD 600.00
                        - generic [ref=e76]:
                          - radio "November 2027 registration · USD 600.00" [ref=e77]
                          - radio
                          - generic [ref=e78]:
                            - generic [ref=e79]: November 2027
                            - generic [ref=e80]: registration · USD 600.00
              - generic [ref=e81]:
                - generic [ref=e83]:
                  - img [ref=e84]
                  - text: Payment
                - generic [ref=e86]:
                  - generic [ref=e87]:
                    - text: Payment method
                    - generic [ref=e88]: "*"
                  - radiogroup "Payment type" [ref=e89]:
                    - radio "Card" [ref=e90]:
                      - img [ref=e91]
                      - generic [ref=e93]: Card
                    - radio "Wire transfer" [ref=e94]:
                      - img [ref=e95]
                      - generic [ref=e98]: Wire transfer
                    - radio "ACH" [ref=e99]:
                      - img [ref=e100]
                      - generic [ref=e102]: ACH
              - generic [ref=e103]:
                - generic [ref=e105]:
                  - img [ref=e106]
                  - text: Exam Preparation Assistance
                - generic [ref=e109]:
                  - generic [ref=e110]:
                    - checkbox "I agree to GARP sharing my contact information with its network of third-party Exam Preparation Providers." [ref=e111] [cursor=pointer]
                    - checkbox
                    - generic [ref=e112]: I agree to GARP sharing my contact information with its network of third-party Exam Preparation Providers.
                  - paragraph [ref=e113]:
                    - text: View a list of
                    - link "FRM Exam Preparation Providers" [ref=e114] [cursor=pointer]:
                      - /url: https://www.garp.org/frm/exam-preparation-providers
                    - text: .
              - generic [ref=e115]:
                - generic [ref=e117]:
                  - img [ref=e118]
                  - text: Candidate Acknowledgements
                - generic [ref=e121]:
                  - generic [ref=e122]:
                    - checkbox "I confirm that I have read and agree to the Candidate Responsibility Statement." [ref=e123] [cursor=pointer]
                    - checkbox
                    - generic [ref=e124]:
                      - generic [ref=e125]: "*"
                      - text: I confirm that I have read and agree to the
                      - link "Candidate Responsibility Statement" [ref=e126] [cursor=pointer]:
                        - /url: https://www.garp.org/candidate-responsibility
                      - text: .
                  - generic [ref=e127]:
                    - checkbox "I confirm that I have read and agree to the Exam Policies." [ref=e128] [cursor=pointer]
                    - checkbox
                    - generic [ref=e129]:
                      - generic [ref=e130]: "*"
                      - text: I confirm that I have read and agree to the
                      - link "Exam Policies" [ref=e131] [cursor=pointer]:
                        - /url: https://www.garp.org/frm/exam-policies
                      - text: .
                  - generic [ref=e132]:
                    - checkbox "Yes, I have read GARP’s Privacy Notice, Code of Conduct, Limitation of Liability, Waiver and Release and Refund Policy." [ref=e133] [cursor=pointer]
                    - checkbox
                    - generic [ref=e134]:
                      - generic [ref=e135]: "*"
                      - text: Yes, I have read GARP’s
                      - link "Privacy Notice" [ref=e136] [cursor=pointer]:
                        - /url: https://www.garp.org/privacy-notice
                      - text: ","
                      - link "Code of Conduct" [ref=e137] [cursor=pointer]:
                        - /url: https://www.garp.org/code-of-conduct
                      - text: ","
                      - link "Limitation of Liability" [ref=e138] [cursor=pointer]:
                        - /url: https://www.garp.org/limitation-of-liability
                      - text: ","
                      - link "Waiver and Release" [ref=e139] [cursor=pointer]:
                        - /url: https://www.garp.org/release-and-waiver-policy
                      - text: and Refund Policy.
                  - generic [ref=e140]:
                    - checkbox "I agree to receiving emails from GARP and select third party providers with news, special offers, promotions and future messages that may be of interest to me." [ref=e141] [cursor=pointer]
                    - checkbox
                    - generic [ref=e142]: I agree to receiving emails from GARP and select third party providers with news, special offers, promotions and future messages that may be of interest to me.
            - complementary [ref=e143]:
              - generic [ref=e144]:
                - generic [ref=e145]:
                  - paragraph [ref=e146]: Total
                  - generic [ref=e147]: USD 750.00
                - button "Pay and Register" [ref=e148] [cursor=pointer]
              - generic [ref=e149]:
                - generic [ref=e150]:
                  - generic [ref=e152]:
                    - img [ref=e153]
                    - text: Add to your registration
                  - generic [ref=e160]:
                    - generic [ref=e161]:
                      - paragraph [ref=e162]: Practice Exams
                      - paragraph [ref=e163]: USD 0.00
                    - button "Add" [ref=e164] [cursor=pointer]:
                      - img
                      - text: Add
                - generic [ref=e165]:
                  - generic [ref=e168]:
                    - img [ref=e169]
                    - text: Order summary
                  - generic [ref=e172]:
                    - generic [ref=e173]:
                      - generic [ref=e174]: Exam Fee
                      - generic [ref=e175]: USD 750.00
                    - separator [ref=e176]
                    - generic [ref=e177]:
                      - generic [ref=e178]: Total
                      - generic [ref=e179]: USD 750.00
      - contentinfo [ref=e180]:
        - generic [ref=e181]:
          - img "GARP" [ref=e182]
          - paragraph [ref=e193]: We are a not-for-profit organization and the leading globally recognized membership association for risk managers.
        - generic [ref=e195]:
          - list [ref=e196]:
            - listitem [ref=e197]:
              - link "Important Notices" [ref=e198] [cursor=pointer]:
                - /url: https://www.garp.org/important-notices
            - listitem [ref=e199]:
              - link "Bylaws" [ref=e200] [cursor=pointer]:
                - /url: https://www.garp.org/bylaws
            - listitem [ref=e201]:
              - link "Code of Conduct" [ref=e202] [cursor=pointer]:
                - /url: https://www.garp.org/code-of-conduct
            - listitem [ref=e203]:
              - link "Privacy Notice" [ref=e204] [cursor=pointer]:
                - /url: https://www.garp.org/privacy-notice
            - listitem [ref=e205]:
              - link "Terms of Use" [ref=e206] [cursor=pointer]:
                - /url: https://www.garp.org/terms-of-use
          - paragraph [ref=e207]: © 2026 Global Association of Risk Professionals
  - region "Notifications alt+T"
```

# Test source

```ts
  51  | 	countryCode: "United States",
  52  | 	phoneCode: "1",
  53  | 	creditCardAllowed: true,
  54  | 	wireAllowed: true,
  55  | 	achAllowed: true,
  56  | 	provinces: [{ name: "NJ" }, { name: "NY" }],
  57  | 	provinceRequired: true,
  58  | 	postalCodeRequired: true,
  59  | }
  60  | 
  61  | const STAGED_ID = "a0H000000000001"
  62  | 
  63  | /** `demographics` is one key for GET (picklists) and POST (save). */
  64  | async function demographicsResponder(route: Route) {
  65  | 	await route.fulfill({
  66  | 		json: memberPortalEnvelope(
  67  | 			route.request().method() === "POST"
  68  | 				? { saved: true, rejected: [] }
  69  | 				: demographicsOptions(),
  70  | 		),
  71  | 	})
  72  | }
  73  | 
  74  | function guestDeferredOptions(): MockOrgOptions {
  75  | 	return {
  76  | 		identity: "guest",
  77  | 		actions: { programs: programsListData(), alertBar: NO_ALERT },
  78  | 		examreg: {
  79  | 			info: examLoad({ countries: [UNITED_STATES] }),
  80  | 			fees: feesResult(750),
  81  | 			options: { companies: [], schools: [] },
  82  | 			verifyCustomer: verifyCustomerResult({ contactId: null, accountId: null }),
  83  | 			register: stagedRegisterResult({ stagedId: STAGED_ID }),
  84  | 			checkout: { checkoutUrl: "/e2e-checkout-stub", stagedId: STAGED_ID },
  85  | 			payOrder: {},
  86  | 			rollback: {},
  87  | 			demographics: demographicsResponder,
  88  | 		},
  89  | 	}
  90  | }
  91  | 
  92  | function parse(postData: string | null): Record<string, any> {
  93  | 	return JSON.parse(postData ?? "{}")
  94  | }
  95  | 
  96  | /** The payload the candidate submitted before pressing Back on Stripe. */
  97  | function bankedPayload() {
  98  | 	return examRegisterRequest({
  99  | 		customer: examCustomer({
  100 | 			firstName: "Resumed",
  101 | 			lastName: "Candidate",
  102 | 			email: "resumed@example.org",
  103 | 			mobilePhoneCode: "United States (+1)",
  104 | 			mobilePhone: "5551234",
  105 | 		}),
  106 | 		selection: {
  107 | 			partSelected: "FRM Exam Part I",
  108 | 			part1: { rateId: "rate-1a", siteId: "site-a2" },
  109 | 			part2: null,
  110 | 		},
  111 | 		materials: ["SM-GEN"],
  112 | 		paymentType: "Stripe",
  113 | 		billingAddress: {
  114 | 			company: "",
  115 | 			street1: "",
  116 | 			street2: "",
  117 | 			street3: "",
  118 | 			city: "",
  119 | 			province: "",
  120 | 			postalCode: "",
  121 | 			country: "United States",
  122 | 			phone: "",
  123 | 		},
  124 | 		shippingAddress: {
  125 | 			company: "",
  126 | 			street1: "",
  127 | 			street2: "",
  128 | 			street3: "",
  129 | 			city: "",
  130 | 			province: "",
  131 | 			postalCode: "",
  132 | 			country: "United States",
  133 | 			phone: "",
  134 | 		},
  135 | 	})
  136 | }
  137 | 
  138 | test.describe("deferred card flow (staged registration)", () => {
  139 | 	test("a staged register result opens checkout under the staged id — never 'registered'", async ({
  140 | 		page,
  141 | 	}) => {
  142 | 		test.slow()
  143 | 		const org = await installMockOrg(page, guestDeferredOptions())
  144 | 		await page.goto("/registration/frm")
  145 | 
  146 | 		await page.getByLabel(/Email/).fill("guest@example.org")
  147 | 		await page.getByLabel(/First name/).fill("Grace")
  148 | 		await page.getByLabel(/Last name/).fill("Hopper")
  149 | 		await page
  150 | 			.getByRole("combobox", { name: "Mobile phone country code" })
> 151 | 			.click()
      |     ^ Error: locator.click: Test timeout of 90000ms exceeded.
  152 | 		await page.getByRole("option", { name: /United States/ }).click()
  153 | 		await page.getByRole("textbox", { name: /^Mobile phone/ }).fill("5551234")
  154 | 		await page.getByRole("combobox", { name: "Location" }).click()
  155 | 		await page.getByRole("option", { name: "United States" }).click()
  156 | 
  157 | 		await page.getByRole("combobox", { name: "Exam part" }).click()
  158 | 		await page.getByRole("option", { name: "FRM Exam Part I", exact: true }).click()
  159 | 		await page.getByRole("combobox", { name: "Where you will sit" }).click()
  160 | 		await page.getByRole("option", { name: "Boston" }).click()
  161 | 		await page.getByRole("radio", { name: "Card", exact: true }).click()
  162 | 		await page.getByRole("checkbox", { name: /Candidate Responsibility/ }).click()
  163 | 		await page.getByRole("checkbox", { name: /Exam Policies/ }).click()
  164 | 
  165 | 		const submit = page.getByRole("button", { name: "Pay and Register" })
  166 | 		await expect(submit).toBeEnabled()
  167 | 		await submit.click()
  168 | 		await page
  169 | 			.getByRole("dialog")
  170 | 			.getByRole("button", { name: "Pay and Register" })
  171 | 			.click()
  172 | 
  173 | 		// Off to the provider — not a "You're registered" screen.
  174 | 		await expect(page).toHaveURL(/\/e2e-checkout-stub$/)
  175 | 		expect(org.hits("checkout")).toBe(1)
  176 | 		const checkoutBody = parse(org.of("checkout")[0].postData)
  177 | 		expect(checkoutBody.orderId).toBe(STAGED_ID)
  178 | 		expect(String(checkoutBody.successUrl)).toContain(
  179 | 			`/registration/frm?stripe_return=1&oid=${STAGED_ID}`,
  180 | 		)
  181 | 		expect(org.hits("payOrder")).toBe(0)
  182 | 		expect(org.hits("rollback")).toBe(0)
  183 | 	})
  184 | 
  185 | 	test("Stripe's cancel leg for a STAGED checkout restores the form, rolls nothing back, and the retry reuses the row", async ({
  186 | 		page,
  187 | 	}) => {
  188 | 		test.slow()
  189 | 		const org = await installMockOrg(page, {
  190 | 			...guestDeferredOptions(),
  191 | 			examreg: {
  192 | 				...guestDeferredOptions().examreg,
  193 | 				resume: resumeResult({ stagedId: STAGED_ID, payload: bankedPayload() }),
  194 | 			},
  195 | 		})
  196 | 
  197 | 		// The server appends `resume` to the cancel URL itself, so both arrive.
  198 | 		await page.goto(
  199 | 			`/registration/frm?checkout_cancelled=1&oid=${STAGED_ID}&resume=${STAGED_ID}`,
  200 | 		)
  201 | 
  202 | 		// Restored, not cancelled: what was typed and chosen is back.
  203 | 		await expect(page.getByLabel(/Email/)).toHaveValue("resumed@example.org")
  204 | 		await expect(page.getByLabel(/First name/)).toHaveValue("Resumed")
  205 | 		await expect(page.getByRole("combobox", { name: "Exam part" })).toContainText(
  206 | 			"FRM Exam Part I",
  207 | 		)
  208 | 		await expect(
  209 | 			page.getByRole("combobox", { name: "Where you will sit" }),
  210 | 		).toContainText("Chicago")
  211 | 		await expect(page.getByRole("button", { name: "Remove" })).toHaveCount(1)
  212 | 		await expect(
  213 | 			page.getByRole("heading", { name: "Payment was not completed" }),
  214 | 		).toHaveCount(0)
  215 | 		expect(org.hits("resume")).toBe(1)
  216 | 		expect(org.hits("rollback")).toBe(0)
  217 | 
  218 | 		// Submitting again: the register body names the row it came from.
  219 | 		const submit = page.getByRole("button", { name: "Pay and Register" })
  220 | 		await expect(submit).toBeEnabled()
  221 | 		await submit.click()
  222 | 		await page
  223 | 			.getByRole("dialog")
  224 | 			.getByRole("button", { name: "Pay and Register" })
  225 | 			.click()
  226 | 		await expect(page).toHaveURL(/\/e2e-checkout-stub$/)
  227 | 		expect(org.hits("register")).toBe(1)
  228 | 		expect(parse(org.of("register")[0].postData).resumeStagedId).toBe(STAGED_ID)
  229 | 	})
  230 | 
  231 | 	test("a plain cancelled checkout (an ORDER) rolls back exactly once and offers a restart", async ({
  232 | 		page,
  233 | 	}) => {
  234 | 		const org = await installMockOrg(page, guestDeferredOptions())
  235 | 		await page.goto("/registration/frm?checkout_cancelled=1&oid=801")
  236 | 
  237 | 		await expect(
  238 | 			page.getByRole("heading", { name: "Payment was not completed" }),
  239 | 		).toBeVisible()
  240 | 		await expect(page.getByRole("link", { name: "Start again" })).toBeVisible()
  241 | 		await expect(page.getByLabel(/Email/)).toHaveCount(0)
  242 | 
  243 | 		await expect.poll(() => org.hits("rollback")).toBe(1)
  244 | 		expect(parse(org.of("rollback")[0].postData)).toEqual({
  245 | 			orderId: "801",
  246 | 			reason: "Checkout cancelled",
  247 | 		})
  248 | 		await page.waitForTimeout(250)
  249 | 		expect(org.hits("rollback")).toBe(1)
  250 | 		expect(org.hits("info")).toBe(0)
  251 | 	})
```