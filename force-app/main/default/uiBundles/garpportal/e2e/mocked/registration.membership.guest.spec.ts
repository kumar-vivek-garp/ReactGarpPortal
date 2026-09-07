import { expect, test, type Route } from "@playwright/test"

import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { verifyCustomerResult } from "@/testing/factories/exam"
import {
	membershipFeesResult,
	membershipLoad,
} from "@/testing/factories/membership-registration"
import { installMockOrg } from "../support/mock-org"

/**
 * The GUEST membership form at /registration/membership: the membership
 * programme's own title and byline, nothing prefilled, no back link, the
 * cart priced as the MAIN line before anything is chosen, the Risk.net add-on
 * re-pricing the rail through `fees`, and the `?track_cta=` tag reaching
 * `verifyCustomer` — and only `verifyCustomer`.
 */

function parse(postData: string | null): Record<string, any> {
	return JSON.parse(postData ?? "{}")
}

/** Prices the cart from what the form sent, as Apex does. */
async function priceCart(route: Route) {
	const body = parse(route.request().postData())
	await route.fulfill({
		json: memberPortalEnvelope(
			membershipFeesResult({
				riskNet: body.riskNetSelected === true,
				offline: Boolean(body.paymentType) && body.paymentType !== "Stripe",
			}),
		),
	})
}

test.describe("guest membership registration", () => {
	test("renders the membership checkout unprefilled, priced, with the byline and no back link", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			identity: "guest",
			examreg: { info: membershipLoad(), fees: priceCart },
		})

		await page.goto("/registration/membership?track_cta=PortalMyAccountPage")

		await expect(
			page.getByRole("heading", { level: 1, name: /Member Registration/ }),
		).toBeVisible()
		await expect(page.getByText(/Already a member\? Sign in/)).toBeVisible()
		await expect(
			page.getByRole("link", { name: "Sign in", exact: true }),
		).toBeVisible()

		// Guest-shaped: identity fields present and empty; no exam anywhere.
		await expect(page.getByRole("textbox", { name: "First name" })).toHaveValue("")
		await expect(page.getByRole("combobox", { name: "Exam part" })).toHaveCount(0)
		await expect(
			page.getByRole("checkbox", { name: /Candidate Responsibility/ }),
		).toHaveCount(0)

		// No back affordance: every in-app parent is behind the session guard.
		const main = page.getByRole("main")
		await expect(main.getByRole("link", { name: /^Back/ })).toHaveCount(0)

		// The membership is the main line, priced with nothing chosen.
		await expect.poll(() => org.hits("fees")).toBeGreaterThan(0)
		await expect(page.getByText("Individual Membership").first()).toBeVisible()
		await expect(page.getByText("USD 195.00").first()).toBeVisible()
		expect(org.hits("info")).toBe(1)
		expect(parse(org.of("fees")[0].postData).type).toBe("mem")
	})

	test("Risk.net Add re-prices the rail through fees; the tag rides verifyCustomer only", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			identity: "guest",
			examreg: {
				info: membershipLoad(),
				fees: priceCart,
				verifyCustomer: verifyCustomerResult(),
			},
		})

		await page.goto("/registration/membership?track_cta=PortalMyAccountPage")
		// A card title, not a heading — the h1 is the page's only heading.
		await expect(page.getByText(/Exclusive Offer for Members/)).toBeVisible()
		await expect.poll(() => org.hits("fees")).toBeGreaterThan(0)

		await page.getByRole("button", { name: /Add/ }).click()
		await expect
			.poll(() =>
				org.of("fees").some((call) => parse(call.postData).riskNetSelected === true),
			)
			.toBe(true)
		await expect(page.getByText("Risk.net Membership")).toBeVisible()
		await expect(page.getByText("USD 295.00").first()).toBeVisible()
		await expect(page.getByRole("button", { name: /Remove/ })).toBeVisible()

		// The identity check on blur carries the attribution tag...
		await page.getByRole("textbox", { name: "First name" }).fill("Ada")
		await page.getByRole("textbox", { name: "Last name" }).fill("Lovelace")
		const email = page.getByRole("textbox", { name: "Email", exact: true })
		await email.fill("ada@example.org")
		await email.blur()

		await expect.poll(() => org.hits("verifyCustomer")).toBe(1)
		const verifyBody = parse(org.of("verifyCustomer")[0].postData)
		expect(verifyBody.type).toBe("mem")
		expect(verifyBody.tracking).toEqual({ trackCta: "PortalMyAccountPage" })

		// ...and nothing else does.
		for (const call of org.of("fees")) {
			expect(parse(call.postData)).not.toHaveProperty("tracking")
		}
	})
})
