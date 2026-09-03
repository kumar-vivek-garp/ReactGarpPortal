# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: smoke.spec.ts >> registration guards >> the public form route serves a guest under its own chrome
- Location: e2e/smoke.spec.ts:121:2

# Error details

```
Error: expect(locator).toBeVisible() failed

Locator: locator('header').first()
Expected: visible
Timeout: 5000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" with timeout 5000ms
  - waiting for locator('header').first()

```

```yaml
- strong: Something went wrong!
- button "Show Error"
```

# Test source

```ts
  28  | 				Contact: {
  29  | 					Id: "003000000000001AAA",
  30  | 					GARP_Member_ID__c: { value: "123456" },
  31  | 					Photo_URL__c: { value: null },
  32  | 				},
  33  | 			},
  34  | 		},
  35  | 	},
  36  | }
  37  | 
  38  | /**
  39  |  * Identity via the local gateway; every other org read = empty success.
  40  |  * Playwright matches routes in REVERSE registration order, so the generic
  41  |  * catch-all is registered FIRST and the identity route last — a gateway URL
  42  |  * like /__local_sf/services/data/v67.0/graphql matches both patterns.
  43  |  */
  44  | async function mockOrgWire(page: Page) {
  45  | 	await page.route("**/services/**", async (route) => {
  46  | 		await route.fulfill({ json: ENVELOPE_OK })
  47  | 	})
  48  | 	await page.route("**/__local_sf/**", async (route) => {
  49  | 		if (route.request().url().includes("/graphql")) {
  50  | 			await route.fulfill({ json: MEMBER_GRAPHQL })
  51  | 			return
  52  | 		}
  53  | 		await route.fulfill({ json: ENVELOPE_OK })
  54  | 	})
  55  | }
  56  | 
  57  | async function asGuest(page: Page) {
  58  | 	await page.addInitScript(() => {
  59  | 		sessionStorage.setItem("garpportal:local-logged-out", "1")
  60  | 	})
  61  | }
  62  | 
  63  | test.describe("boot and auth wall", () => {
  64  | 	test("a guest hitting the app is walled off at Login", async ({ page }) => {
  65  | 		await mockOrgWire(page)
  66  | 		await asGuest(page)
  67  | 		await page.goto("/")
  68  | 		await expect(page).toHaveURL(/\/Login/)
  69  | 	})
  70  | 
  71  | 	test("a member lands on the dashboard with the app chrome", async ({
  72  | 		page,
  73  | 	}) => {
  74  | 		await mockOrgWire(page)
  75  | 		await page.goto("/")
  76  | 		await expect(page).toHaveURL(/\/dashboard$/)
  77  | 		await expect(page.locator("header").first()).toBeVisible()
  78  | 		await expect(page.locator("#boot-splash")).not.toBeVisible()
  79  | 	})
  80  | 
  81  | 	test("client-side navigation reaches Programs", async ({ page }) => {
  82  | 		await mockOrgWire(page)
  83  | 		await page.goto("/dashboard")
  84  | 		await page.locator('a[href="/programs"]').first().click()
  85  | 		await expect(page).toHaveURL(/\/programs$/)
  86  | 	})
  87  | 
  88  | 	test("an unknown path renders the 404 page", async ({ page }) => {
  89  | 		await mockOrgWire(page)
  90  | 		await page.goto("/this-page-does-not-exist")
  91  | 		await expect(
  92  | 			page.getByRole("heading", { name: "Page not found" }),
  93  | 		).toBeVisible()
  94  | 	})
  95  | })
  96  | 
  97  | test.describe("registration guards", () => {
  98  | 	test("a guest deep-linking the member form lands on its public twin, code intact", async ({
  99  | 		page,
  100 | 	}) => {
  101 | 		await mockOrgWire(page)
  102 | 		await asGuest(page)
  103 | 		await page.goto("/programs/frm/register?regCode=TEAM24")
  104 | 		await expect(page).toHaveURL(/\/registration\/frm/)
  105 | 		expect(page.url()).toContain("regCode=TEAM24")
  106 | 	})
  107 | 
  108 | 	test("a guest payment return keeps its params through the public-twin bounce", async ({
  109 | 		page,
  110 | 	}) => {
  111 | 		await mockOrgWire(page)
  112 | 		await asGuest(page)
  113 | 		await page.goto("/programs/frm/register?stripe_return=1&oid=801&on=1234")
  114 | 		// The guard sends a guest to the public twin WITH search preserved —
  115 | 		// dropping oid/on here would blank a confirmation for a charged order.
  116 | 		await expect(page).toHaveURL(/\/registration\/frm/)
  117 | 		expect(page.url()).toContain("stripe_return")
  118 | 		expect(page.url()).toContain("801")
  119 | 	})
  120 | 
  121 | 	test("the public form route serves a guest under its own chrome", async ({
  122 | 		page,
  123 | 	}) => {
  124 | 		await mockOrgWire(page)
  125 | 		await asGuest(page)
  126 | 		await page.goto("/registration/affiliate")
  127 | 		await expect(page).toHaveURL(/\/registration\/affiliate/)
> 128 | 		await expect(page.locator("header").first()).toBeVisible()
      |                                                ^ Error: expect(locator).toBeVisible() failed
  129 | 	})
  130 | })
  131 | 
  132 | test.describe("theming", () => {
  133 | 	test("system dark scheme yields the dark theme", async ({ page }) => {
  134 | 		await mockOrgWire(page)
  135 | 		await page.emulateMedia({ colorScheme: "dark" })
  136 | 		await page.goto("/dashboard")
  137 | 		await expect(page.locator("html")).toHaveClass(/dark/)
  138 | 	})
  139 | 
  140 | 	test("system light scheme yields the light theme", async ({ page }) => {
  141 | 		await mockOrgWire(page)
  142 | 		await page.emulateMedia({ colorScheme: "light" })
  143 | 		await page.goto("/dashboard")
  144 | 		await expect(page.locator("html")).not.toHaveClass(/dark/)
  145 | 	})
  146 | })
  147 | 
```