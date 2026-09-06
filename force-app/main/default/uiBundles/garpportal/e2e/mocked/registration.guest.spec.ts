import { expect, test } from "@playwright/test"

import {
	examLoad,
	verifyCustomerResult,
	feesResult,
} from "@/testing/factories/exam"
import { installMockOrg } from "../support/mock-org"

/**
 * The GUEST public form at /registration/frm: nothing prefilled (the identity
 * fields exist and are empty), the programme byline and the sign-in offer are
 * shown up front, no back link promises a "back" that would hit the login
 * wall, `verifyCustomer` fires once on email blur with a TRIMMED body, and a
 * `mustSignIn` answer is met with an honest sign-in link — register never
 * fires.
 */

function parse(postData: string | null): Record<string, any> {
	return JSON.parse(postData ?? "{}")
}

/** Fill the three identity fields (with untrimmed names) and blur the email. */
async function fillIdentity(page: import("@playwright/test").Page) {
	await page
		.getByRole("textbox", { name: "First name" })
		.fill(" Ada ")
	await page
		.getByRole("textbox", { name: "Last name" })
		.fill(" Lovelace ")
	await page
		.getByRole("textbox", { name: "Email", exact: true })
		.fill("ada@example.org")
	// Blur the email — the identity check runs here, not on submit.
	await page.getByRole("textbox", { name: "Email", exact: true }).blur()
}

test.describe("guest public registration", () => {
	test("renders unprefilled with the byline and sign-in offer, and no back link", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			identity: "guest",
			examreg: { info: examLoad(), fees: feesResult(600) },
		})

		await page.goto("/registration/frm")

		// The page's only h1 names the certification in full.
		await expect(
			page.getByRole("heading", { level: 1, name: /Financial Risk Manager/ }),
		).toBeVisible()

		// FRM's guest byline, with a live sign-in link beside it.
		await expect(
			page.getByText(/Returning candidates registering for the FRM Part II/),
		).toBeVisible()
		const offer = page.getByRole("link", { name: "Sign in", exact: true })
		await expect(offer).toBeVisible()
		expect(await offer.getAttribute("href")).toContain("/Login")

		// Guest-shaped details card: the identity fields are PRESENT and EMPTY.
		await expect(page.getByText("Your details")).toBeVisible()
		await expect(page.getByRole("textbox", { name: "First name" })).toHaveValue(
			"",
		)
		await expect(page.getByRole("textbox", { name: "Last name" })).toHaveValue(
			"",
		)
		await expect(
			page.getByRole("textbox", { name: "Email", exact: true }),
		).toHaveValue("")
		await expect(
			page.getByRole("textbox", { name: "Mobile phone", exact: true }),
		).toHaveValue("")

		// No back affordance: every in-app parent is behind the session guard.
		const main = page.getByRole("main")
		await expect(main.getByRole("link", { name: /^Back/ })).toHaveCount(0)
		await expect(main.getByRole("button", { name: /^Back/ })).toHaveCount(0)

		// Nothing was checked yet — no email has blurred.
		expect(org.hits("verifyCustomer")).toBe(0)
	})

	test("verifyCustomer fires ONCE on email blur, with the trimmed body", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			identity: "guest",
			examreg: {
				info: examLoad(),
				fees: feesResult(600),
				verifyCustomer: verifyCustomerResult({ isExistingCustomer: true }),
			},
		})

		await page.goto("/registration/frm")
		await expect(
			page.getByRole("textbox", { name: "First name" }),
		).toBeVisible()

		await fillIdentity(page)

		await expect.poll(() => org.hits("verifyCustomer")).toBe(1)
		const body = parse(org.of("verifyCustomer")[0].postData)
		// The typed values carried spaces; the wire body must not.
		expect(body).toEqual({
			type: "frm",
			courseCode: null,
			email: "ada@example.org",
			firstName: "Ada",
			lastName: "Lovelace",
		})

		// Re-blurring the SAME address is not a second identity call — the
		// answer doubles as the registration's session.
		await page.getByRole("textbox", { name: "Email", exact: true }).focus()
		await page.getByRole("textbox", { name: "Email", exact: true }).blur()
		await page.waitForTimeout(300)
		expect(org.hits("verifyCustomer")).toBe(1)

		// A found record that may proceed is said calmly, not as a block.
		await expect(page.getByText("We found your record")).toBeVisible()
	})

	test("mustSignIn gets an honest sign-in link and register never fires", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			identity: "guest",
			examreg: {
				info: examLoad(),
				fees: feesResult(600),
				verifyCustomer: verifyCustomerResult({ mustSignIn: true }),
			},
		})

		await page.goto("/registration/frm")
		await expect(
			page.getByRole("textbox", { name: "First name" }),
		).toBeVisible()

		await fillIdentity(page)

		// The binding answer, before the rest of the form was filled in.
		await expect(page.getByText("You already have an account")).toBeVisible()
		const rescue = page.getByRole("link", {
			name: "Sign in and start again",
		})
		await expect(rescue).toBeVisible()
		// A REAL link, carrying the way back to this form after sign-in.
		const href = await rescue.getAttribute("href")
		expect(href).toContain("/Login")
		expect(href).toContain("startUrl=")

		expect(org.hits("register")).toBe(0)
	})
})
