# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: programs-exam-setup.spec.ts >> exam setup >> a fee-bearing change is written, then priced exactly once
- Location: e2e/mocked/programs-exam-setup.spec.ts:138:2

# Error details

```
Error: expect(locator).toBeVisible() failed

Locator: getByText('$250.00').first()
Expected: visible
Timeout: 5000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" with timeout 5000ms
  - waiting for getByText('$250.00').first()

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
  - link "FRM":
    - /url: /programs/frm
  - heading "Financial Risk Manager (FRM®) Exam Setup" [level=1]:
    - text: Financial Risk Manager (FRM
    - superscript: ®
    - text: ) Exam Setup
  - heading "There's a fee for this change" [level=2]
  - paragraph: Your exam change is saved but not yet confirmed. Complete the payment to finish it.
  - term: FRM Part I from May 2026 to November 2026 Standard exam administration change fee
  - definition: USD 250.00
  - term: Total
  - definition: USD 250.00
  - link "Pay Fees":
    - /url: https://garp--devjuly25a.sandbox.my.site.com/Login?start=myprograms/setup/feescheckout/a0M999
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
  58  | function examSetupActions(
  59  | 	overrides: Record<string, unknown> = {},
  60  | ): Record<string, unknown> {
  61  | 	return {
  62  | 		...dashboardActionSet(),
  63  | 		alertBar: NO_ALERT,
  64  | 		examSetup: examSetupView(),
  65  | 		examSetupId: examSetupSaveResult(),
  66  | 		examSetupFees: FEES_VIEW,
  67  | 		...overrides,
  68  | 	}
  69  | }
  70  | 
  71  | const SAVE = "Save exam setup"
  72  | 
  73  | /** The form is interactive once the sitting tiles have rendered. */
  74  | async function ready(page: import("@playwright/test").Page) {
  75  | 	await expect(page.getByRole("radio", { name: /May 2026/ })).toBeVisible()
  76  | }
  77  | 
  78  | test.describe("exam setup", () => {
  79  | 	test("opens with the current sitting selected and read out in the bar", async ({
  80  | 		page,
  81  | 	}) => {
  82  | 		const org = await installMockOrg(page, { actions: examSetupActions() })
  83  | 		await page.goto("/programs/frm/exam-setup")
  84  | 		await ready(page)
  85  | 
  86  | 		await expect(
  87  | 			page.getByRole("heading", { level: 1, name: /Financial Risk Manager.*Exam Setup/ }),
  88  | 		).toBeVisible()
  89  | 		await expect(page.getByRole("radio", { name: /May 2026/ })).toBeChecked()
  90  | 		await expect(
  91  | 			page.getByRole("combobox", { name: /Where do you plan to sit/ }),
  92  | 		).toContainText("London")
  93  | 		await expect(page.getByText("May 2026 · London")).toBeVisible()
  94  | 		expect(org.hits("examSetup")).toBe(1)
  95  | 	})
  96  | 
  97  | 	test("saves through examSetupId with the exact body Apex reads", async ({
  98  | 		page,
  99  | 	}) => {
  100 | 		const org = await installMockOrg(page, { actions: examSetupActions() })
  101 | 		await page.goto("/programs/frm/exam-setup")
  102 | 
  103 | 		await ready(page)
  104 | 		// Same administration, different site — the free change.
  105 | 		await page.getByRole("combobox", { name: /Where do you plan to sit/ }).click()
  106 | 		await page.getByRole("option", { name: "Paris" }).click()
  107 | 		await page.getByRole("button", { name: SAVE }).click()
  108 | 
  109 | 		await expect(page.getByText("Your exam setup is complete.")).toBeVisible()
  110 | 		await expect.poll(() => org.hits("examSetupId")).toBe(1)
  111 | 
  112 | 		const call = org.of("examSetupId")[0]
  113 | 		expect(call.method).toBe("POST")
  114 | 		const body = JSON.parse(call.postData ?? "{}") as {
  115 | 			programType: string
  116 | 			id: Record<string, unknown>
  117 | 			selection: Record<string, unknown>
  118 | 		}
  119 | 		expect(body.programType).toBe("frm")
  120 | 		expect(body.selection).toEqual({
  121 | 			selectedAdminPart1: "admin-may",
  122 | 			selectedSitePart1: "site-paris",
  123 | 			selectedAdminPart2: null,
  124 | 			selectedSitePart2: null,
  125 | 		})
  126 | 		// FRM sends the government-ID trio, with the date in the US format the
  127 | 		// write expects — not the ISO the read returned.
  128 | 		expect(body.id).toMatchObject({
  129 | 			idName: "Ada Lovelace",
  130 | 			idType: "passport",
  131 | 			idNumber: "45678",
  132 | 			idExpireDate: "01/01/2030",
  133 | 		})
  134 | 		// No OSTA block: this member does not sit in mainland China.
  135 | 		expect(body.id.ostaIDLocation).toBeUndefined()
  136 | 	})
  137 | 
  138 | 	test("a fee-bearing change is written, then priced exactly once", async ({
  139 | 		page,
  140 | 	}) => {
  141 | 		const org = await installMockOrg(page, {
  142 | 			actions: examSetupActions({
  143 | 				examSetupId: examSetupSaveResult({
  144 | 					nextScreen: "Pay Fees",
  145 | 					paymentRequired: true,
  146 | 					examModificationId: "a0M999",
  147 | 				}),
  148 | 			}),
  149 | 		})
  150 | 		await page.goto("/programs/frm/exam-setup")
  151 | 
  152 | 		await ready(page)
  153 | 		await page.getByRole("radio", { name: /November 2026/ }).click()
  154 | 		await expect(page.getByText("New sitting")).toBeVisible()
  155 | 		await page.getByRole("button", { name: SAVE }).click()
  156 | 
  157 | 		await expect(page.getByText("There's a fee for this change")).toBeVisible()
> 158 | 		await expect(page.getByText("$250.00").first()).toBeVisible()
      |                                                   ^ Error: expect(locator).toBeVisible() failed
  159 | 
  160 | 		// Priced from the modification the write raised — one call, no polling.
  161 | 		await expect.poll(() => org.hits("examSetupFees")).toBe(1)
  162 | 		const fees = JSON.parse(org.of("examSetupFees")[0].postData ?? "{}") as {
  163 | 			modificationId: string
  164 | 		}
  165 | 		expect(fees.modificationId).toBe("a0M999")
  166 | 
  167 | 		await expect(page.getByRole("link", { name: "Pay Fees" })).toHaveAttribute(
  168 | 			"href",
  169 | 			/myprograms\/setup\/feescheckout\/a0M999/,
  170 | 		)
  171 | 	})
  172 | 
  173 | 	test("nothing is priced when nothing is owed", async ({ page }) => {
  174 | 		const org = await installMockOrg(page, { actions: examSetupActions() })
  175 | 		await page.goto("/programs/frm/exam-setup")
  176 | 
  177 | 		await ready(page)
  178 | 		await page.getByRole("button", { name: SAVE }).click()
  179 | 
  180 | 		await expect(page.getByText("Your exam setup is complete.")).toBeVisible()
  181 | 		expect(org.hits("examSetupFees")).toBe(0)
  182 | 	})
  183 | 
  184 | 	test("a scheduling-required save pushes to the provider once and links out", async ({
  185 | 		page,
  186 | 	}) => {
  187 | 		const org = await installMockOrg(page, {
  188 | 			actions: examSetupActions({
  189 | 				examSetupId: examSetupSaveResult({
  190 | 					nextScreen: "Check Authorization",
  191 | 					schedulingRequired: true,
  192 | 				}),
  193 | 				examSetupAuthorize: examSetupAuthorizeResult({
  194 | 					isAuthorized: true,
  195 | 					examScheduleExamURLPart1: "https://provider.example/schedule/one",
  196 | 				}),
  197 | 			}),
  198 | 		})
  199 | 		await page.goto("/programs/frm/exam-setup")
  200 | 
  201 | 		await ready(page)
  202 | 		await page.getByRole("button", { name: SAVE }).click()
  203 | 
  204 | 		await expect(page.getByText("Your exam setup was successful.")).toBeVisible()
  205 | 		await expect(
  206 | 			page.getByRole("link", { name: "Schedule Exam" }),
  207 | 		).toHaveAttribute("href", "https://provider.example/schedule/one")
  208 | 
  209 | 		// Accepted first time, so no retry: the second attempt only exists for a
  210 | 		// provider that answers "not yet". Never a poll.
  211 | 		await expect.poll(() => org.hits("examSetupAuthorize")).toBe(1)
  212 | 		const call = org.of("examSetupAuthorize")[0]
  213 | 		expect(JSON.parse(call.postData ?? "{}")).toEqual({
  214 | 			programType: "frm",
  215 | 			isRetry: false,
  216 | 		})
  217 | 	})
  218 | 
  219 | 	test("a server refusal keeps the member on the form", async ({ page }) => {
  220 | 		const org = await installMockOrg(page, {
  221 | 			actions: examSetupActions({
  222 | 				examSetupId: examSetupSaveResult({
  223 | 					statusCode: 505,
  224 | 					statusMessage: "Part II cannot be taken before Part I",
  225 | 				}),
  226 | 			}),
  227 | 		})
  228 | 		await page.goto("/programs/frm/exam-setup")
  229 | 
  230 | 		await ready(page)
  231 | 		await page.getByRole("button", { name: SAVE }).click()
  232 | 
  233 | 		await expect(page.getByRole("alert")).toContainText(
  234 | 			"Part II cannot be taken before Part I",
  235 | 		)
  236 | 		// Still the form, not an outcome: the member can act on it.
  237 | 		await expect(page.getByRole("button", { name: SAVE })).toBeVisible()
  238 | 		expect(org.hits("examSetupFees")).toBe(0)
  239 | 	})
  240 | })
  241 | 
```