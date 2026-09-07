# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: directory.spec.ts >> member directory >> entitled render, debounced search POST with the term, member dialog opens
- Location: e2e/mocked/directory.spec.ts:61:2

# Error details

```
Error: expect(locator).toBeVisible() failed

Locator: getByRole('button', { name: 'View Ada Lovelace' })
Expected: visible
Timeout: 5000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" with timeout 5000ms
  - waiting for getByRole('button', { name: 'View Ada Lovelace' })

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
  - heading "Member Directory" [level=1]
  - paragraph: Search members who chose to appear in the GARP directory.
  - textbox "Search the member directory":
    - /placeholder: Search by name, city or country
  - button "Filters"
  - paragraph: Results will display here
  - paragraph: Please enter search criteria above.
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
  1   | import { expect, test } from "@playwright/test"
  2   | 
  3   | import type { AlertBarView } from "@/api/alert-bar"
  4   | import {
  5   | 	directoryMember,
  6   | 	directorySearchResults,
  7   | 	directoryView,
  8   | } from "@/testing/factories/directory"
  9   | import { installMockOrg } from "../support/mock-org"
  10  | import { programsListData } from "../support/payloads"
  11  | 
  12  | /**
  13  |  * Member Directory journeys: an entitled member gets the search-as-you-type
  14  |  * panel (one DEBOUNCED `directorySearch` POST per pause, carrying the term),
  15  |  * a row opens the member dialog, and a member whose entitlement says no gets
  16  |  * the gate — with zero searches fired on their behalf.
  17  |  */
  18  | 
  19  | const NO_ALERT = {
  20  | 	statusMessage: null,
  21  | 	statusCode: 200,
  22  | 	examType: null,
  23  | 	examPart: null,
  24  | 	alertStatus: null,
  25  | 	deadline: null,
  26  | 	orderId: null,
  27  | 	route: null,
  28  | } satisfies AlertBarView
  29  | 
  30  | const ADA = directoryMember()
  31  | const GRACE = directoryMember({
  32  | 	id: "003-2",
  33  | 	garpId: "G-2",
  34  | 	name: "Grace Hopper",
  35  | 	firstName: "Grace",
  36  | 	lastName: "Hopper",
  37  | 	mailingCity: "Arlington",
  38  | 	mailingCountry: "United States",
  39  | 	company: "US Navy",
  40  | 	corporateTitle: "Rear Admiral",
  41  | 	canSendMessage: false,
  42  | 	canInvite: true,
  43  | })
  44  | 
  45  | function entitledActions() {
  46  | 	return {
  47  | 		programs: programsListData(),
  48  | 		alertBar: NO_ALERT,
  49  | 		directory: directoryView(),
  50  | 		directorySearch: directorySearchResults({ members: [ADA, GRACE] }),
  51  | 		/** The filter dialog's picklists — empty is a valid, quiet answer. */
  52  | 		options: { picklists: {}, chapters: [] },
  53  | 	}
  54  | }
  55  | 
  56  | function parse(postData: string | null): Record<string, any> {
  57  | 	return JSON.parse(postData ?? "{}")
  58  | }
  59  | 
  60  | test.describe("member directory", () => {
  61  | 	test("entitled render, debounced search POST with the term, member dialog opens", async ({
  62  | 		page,
  63  | 	}) => {
  64  | 		test.slow()
  65  | 		const org = await installMockOrg(page, { actions: entitledActions() })
  66  | 		await page.goto("/member-directory")
  67  | 
  68  | 		await expect(
  69  | 			page.getByRole("heading", { name: "Member Directory", level: 1 }),
  70  | 		).toBeVisible()
  71  | 
  72  | 		// The first (empty-term) page renders the rows the org returned.
  73  | 		await expect(
  74  | 			page.getByRole("button", { name: "View Ada Lovelace" }),
> 75  | 		).toBeVisible()
      |     ^ Error: expect(locator).toBeVisible() failed
  76  | 		await expect(
  77  | 			page.getByRole("button", { name: "View Grace Hopper" }),
  78  | 		).toBeVisible()
  79  | 
  80  | 		// The mount search is a real search: empty term (sent as null — the
  81  | 		// server's "everyone I may see"), first page, clamped size.
  82  | 		await expect.poll(() => org.hits("directorySearch")).toBeGreaterThan(0)
  83  | 		const first = parse(org.of("directorySearch")[0].postData)
  84  | 		expect(first.searchText).toBeNull()
  85  | 		expect(first.pageCurrent).toBe(1)
  86  | 		expect(first.pageSize).toBe(10)
  87  | 
  88  | 		// Let the mount settle fully, then type a burst: 6 keystrokes inside the
  89  | 		// 350ms debounce window must buy exactly ONE more POST, carrying the term.
  90  | 		await page.waitForTimeout(600)
  91  | 		const baseline = org.hits("directorySearch")
  92  | 		await page
  93  | 			.getByRole("textbox", { name: "Search the member directory" })
  94  | 			.pressSequentially("hopper", { delay: 40 })
  95  | 		await expect.poll(() => org.hits("directorySearch")).toBe(baseline + 1)
  96  | 		await page.waitForTimeout(600)
  97  | 		expect(org.hits("directorySearch")).toBe(baseline + 1)
  98  | 		const searchCalls = org.of("directorySearch")
  99  | 		const searched = parse(searchCalls[searchCalls.length - 1].postData)
  100 | 		expect(searched.searchText).toBe("hopper")
  101 | 		expect(searched.pageCurrent).toBe(1)
  102 | 
  103 | 		// A row opens the member dialog with the redacted entry.
  104 | 		await page.getByRole("button", { name: "View Grace Hopper" }).click()
  105 | 		const dialog = page.getByRole("dialog")
  106 | 		await expect(dialog.getByText("Grace Hopper")).toBeVisible()
  107 | 		await expect(dialog.getByText("US Navy")).toBeVisible()
  108 | 	})
  109 | 
  110 | 	test("not entitled: the gate renders its upsell and no search ever fires", async ({
  111 | 		page,
  112 | 	}) => {
  113 | 		const org = await installMockOrg(page, {
  114 | 			actions: {
  115 | 				...entitledActions(),
  116 | 				directory: directoryView({
  117 | 					hasDirectoryAccess: false,
  118 | 					hasDirectoryAdvancedSearchAccess: false,
  119 | 					hasDirectorySettingsAccess: false,
  120 | 					upsellMembershipType: "Upgrade",
  121 | 				}),
  122 | 			},
  123 | 		})
  124 | 		await page.goto("/member-directory")
  125 | 
  126 | 		await expect(
  127 | 			page.getByText("The directory is not available on your membership"),
  128 | 		).toBeVisible()
  129 | 		// The upsell says what to do about it, and points at the tagged
  130 | 		// membership purchase form — not the benefits page.
  131 | 		const upsell = page.getByRole("link", { name: "Upgrade" })
  132 | 		await expect(upsell).toBeVisible()
  133 | 		expect(await upsell.getAttribute("href")).toBe(
  134 | 			"/membership/register?track_cta=PortalMembershipPage",
  135 | 		)
  136 | 
  137 | 		// No search box, and none run on this member's behalf.
  138 | 		await expect(
  139 | 			page.getByRole("textbox", { name: "Search the member directory" }),
  140 | 		).toHaveCount(0)
  141 | 		expect(org.hits("directorySearch")).toBe(0)
  142 | 	})
  143 | })
  144 | 
```