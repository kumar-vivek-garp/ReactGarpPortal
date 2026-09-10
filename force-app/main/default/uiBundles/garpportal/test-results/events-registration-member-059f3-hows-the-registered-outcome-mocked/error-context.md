# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: events-registration.spec.ts >> member event registration — free journey >> loads without eventType, posts the closed DTO, and shows the registered outcome
- Location: e2e/mocked/events-registration.spec.ts:62:2

# Error details

```
Error: expect(locator).toBeDisabled() failed

Locator:  getByRole('button', { name: 'Complete Registration' })
Expected: disabled
Received: enabled
Timeout:  5000ms

Call log:
  - Expect "toBeDisabled" with timeout 5000ms
  - waiting for getByRole('button', { name: 'Complete Registration' })
    14 × locator resolved to <button type="submit" data-size="lg" data-slot="button" data-variant="default" class="inline-flex cursor-pointer items-center justify-center gap-2 rounded-xl text-sm font-extrabold whitespace-nowrap transition-[color,background-color,border-color,box-shadow,opacity] outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive…>Complete Registration</button>
       - unexpected value "enabled"

```

```yaml
- button "Complete Registration"
```

# Test source

```ts
  1   | import { expect, test } from "@playwright/test"
  2   | 
  3   | import type { AlertBarView } from "@/api/alert-bar"
  4   | import type { EventOptions } from "@/api/registration/event-types"
  5   | import {
  6   | 	eventContact,
  7   | 	eventCountry,
  8   | 	eventLoad,
  9   | 	eventRegisterResult,
  10  | 	eventView,
  11  | } from "@/testing/factories/event"
  12  | import {
  13  | 	accountViewFromPersonalInfo,
  14  | 	billingCompanyGraphql,
  15  | 	personalInfoEditData,
  16  | } from "@/testing/factories/personal-info"
  17  | import {
  18  | 	installMockOrg,
  19  | 	refuse,
  20  | 	type MockOrgOptions,
  21  | } from "../support/mock-org"
  22  | import { programsListData } from "../support/payloads"
  23  | 
  24  | /**
  25  |  * Member event/webcast registration: the free journey end to end (GET wiring,
  26  |  * form, POST body, outcome), the webcast-only variant plumbing (`eventType` in
  27  |  * the query, the country-options read, the location card), and the two
  28  |  * non-form screens — already registered, and a load failure.
  29  |  */
  30  | 
  31  | function alertBarIdle(): AlertBarView {
  32  | 	return {
  33  | 		statusMessage: "No alerts found",
  34  | 		statusCode: 200,
  35  | 		examType: null,
  36  | 		examPart: null,
  37  | 		alertStatus: null,
  38  | 		deadline: null,
  39  | 		orderId: null,
  40  | 		route: null,
  41  | 	}
  42  | }
  43  | 
  44  | /**
  45  |  * Every member spec's floor: sidebar programs + quiet alert bar, and the
  46  |  * profile hydrate the register panel waits on for a session with a contact
  47  |  * (unanswered it errors and toasts "Unable to load personal information").
  48  |  */
  49  | function memberBaseline(): Pick<MockOrgOptions, "actions" | "graphql"> {
  50  | 	const profile = personalInfoEditData()
  51  | 	return {
  52  | 		actions: {
  53  | 			programs: programsListData(),
  54  | 			alertBar: alertBarIdle(),
  55  | 			account: accountViewFromPersonalInfo(profile),
  56  | 		},
  57  | 		graphql: { BillingCompany: billingCompanyGraphql(profile) },
  58  | 	}
  59  | }
  60  | 
  61  | test.describe("member event registration — free journey", () => {
  62  | 	test("loads without eventType, posts the closed DTO, and shows the registered outcome", async ({
  63  | 		page,
  64  | 	}) => {
  65  | 		const org = await installMockOrg(page, {
  66  | 			...memberBaseline(),
  67  | 			examreg: {
  68  | 				"event/info": eventLoad({
  69  | 					isAuthenticated: true,
  70  | 					contact: eventContact(),
  71  | 				}),
  72  | 				"event/register": eventRegisterResult({
  73  | 					registrationNumber: "ER-1001",
  74  | 					message: "See you there.",
  75  | 				}),
  76  | 			},
  77  | 		})
  78  | 		await page.goto("/events/event/E1/register")
  79  | 
  80  | 		// The event's title is the page's h1; identity came from the record so
  81  | 		// the member sees the collapsed contact card, not name/email inputs.
  82  | 		await expect(
  83  | 			page.getByRole("heading", { name: "Risk Summit 2026", level: 1 }),
  84  | 		).toBeVisible()
  85  | 		await expect(page.getByText("Contact details")).toBeVisible()
  86  | 
  87  | 		// GET wiring: the id travels, `eventType` does NOT — omitting it is the
  88  | 		// Apex default for plain events, and sending it would change the record
  89  | 		// family the server writes.
  90  | 		const info = org.of("event/info")
  91  | 		expect(info.length).toBeGreaterThan(0)
  92  | 		expect(info[0].url).toContain("eventId=E1")
  93  | 		expect(info[0].url).not.toContain("eventType")
  94  | 
  95  | 		// Only the attestation stands between a member and a valid form.
  96  | 		const submit = page.getByRole("button", { name: "Complete Registration" })
> 97  | 		await expect(submit).toBeDisabled()
      |                        ^ Error: expect(locator).toBeDisabled() failed
  98  | 		await page.getByRole("checkbox", { name: /GARP Privacy Notice/ }).click()
  99  | 		await expect(submit).toBeEnabled()
  100 | 		await submit.click()
  101 | 
  102 | 		await expect(
  103 | 			page.getByRole("heading", { name: "You're registered" }),
  104 | 		).toBeVisible()
  105 | 		await expect(page.getByText("See you there.")).toBeVisible()
  106 | 		await expect(page.getByText("ER-1001")).toBeVisible()
  107 | 
  108 | 		// The wire payload is the whitelist: seeded identity travels, unrendered
  109 | 		// sections are absent entirely, nothing posts as a silent default.
  110 | 		expect(org.hits("event/register")).toBe(1)
  111 | 		const body: unknown = JSON.parse(
  112 | 			org.of("event/register")[0].postData ?? "{}",
  113 | 		)
  114 | 		expect(body).toEqual({
  115 | 			variant: "event",
  116 | 			eventId: "E1",
  117 | 			email: "ada@example.test",
  118 | 			firstName: "Ada",
  119 | 			lastName: "Lovelace",
  120 | 			jobTitle: "Analyst",
  121 | 			company: "Analytical Engines",
  122 | 			isGdpr: false,
  123 | 			userQuestions: "",
  124 | 			privacyPolicyAttestation: true,
  125 | 			agreeToGarpContent: false,
  126 | 		})
  127 | 
  128 | 		// The country-options read is webcast-only — a plain event never asks.
  129 | 		expect(org.hits("event/options")).toBe(0)
  130 | 	})
  131 | })
  132 | 
  133 | test.describe("member webcast registration — variant plumbing", () => {
  134 | 	test("sends eventType=webcast, fetches the country options, and renders the location card", async ({
  135 | 		page,
  136 | 	}) => {
  137 | 		const options: EventOptions = {
  138 | 			countries: [
  139 | 				eventCountry(),
  140 | 				eventCountry({
  141 | 					id: "cty-de",
  142 | 					name: "Germany",
  143 | 					countryCode: "DE",
  144 | 					compliance: true,
  145 | 				}),
  146 | 			],
  147 | 			professionalLevels: [],
  148 | 			jobFunctions: [],
  149 | 			riskSpecialties: [],
  150 | 		}
  151 | 		const org = await installMockOrg(page, {
  152 | 			...memberBaseline(),
  153 | 			examreg: {
  154 | 				"event/info": eventLoad({
  155 | 					isAuthenticated: true,
  156 | 					contact: eventContact(),
  157 | 					event_x: eventView({ id: "W1", title: "Climate Webcast" }),
  158 | 				}),
  159 | 				"event/options": options,
  160 | 			},
  161 | 		})
  162 | 		await page.goto("/events/webcast/W1/register")
  163 | 
  164 | 		await expect(
  165 | 			page.getByRole("heading", { name: "Climate Webcast", level: 1 }),
  166 | 		).toBeVisible()
  167 | 
  168 | 		// The variant rides in the query string, never the body.
  169 | 		const info = org.of("event/info")
  170 | 		expect(info.length).toBeGreaterThan(0)
  171 | 		expect(info[0].url).toContain("eventType=webcast")
  172 | 		expect(info[0].url).toContain("eventId=W1")
  173 | 		await expect.poll(() => org.hits("event/options")).toBe(1)
  174 | 
  175 | 		// The webcast-only "Your location" card, populated from the payload.
  176 | 		await expect(page.getByText("Your location")).toBeVisible()
  177 | 		const country = page.getByRole("combobox", { name: "Country" })
  178 | 		await country.click()
  179 | 		await page.getByRole("option", { name: "Germany" }).click()
  180 | 		await expect(country).toHaveText(/Germany/)
  181 | 	})
  182 | })
  183 | 
  184 | test.describe("member event registration — non-form screens", () => {
  185 | 	test("an existing registration renders its own screen instead of the form", async ({
  186 | 		page,
  187 | 	}) => {
  188 | 		await installMockOrg(page, {
  189 | 			...memberBaseline(),
  190 | 			examreg: {
  191 | 				"event/info": eventLoad({
  192 | 					isAuthenticated: true,
  193 | 					contact: eventContact(),
  194 | 					alreadyRegistered: true,
  195 | 					existingRegistrationId: "reg-9",
  196 | 				}),
  197 | 			},
```