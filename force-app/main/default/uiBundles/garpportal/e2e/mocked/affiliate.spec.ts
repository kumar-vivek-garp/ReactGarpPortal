import { expect, test } from "@playwright/test"

import {
	affiliateLoad,
	affiliateRegisterResult,
} from "@/testing/factories/affiliate"
import { verifyCustomerResult } from "@/testing/factories/exam"
import { installMockOrg } from "../support/mock-org"

/**
 * The guest Affiliate sign-up at /registration/affiliate — this app's
 * "Create Account". One full journey: fill → identity check on email blur →
 * submit (no confirm dialog; the order is free) → the register body carries
 * TRIMMED names and the COLLAPSED consent → the zero-total order is closed by
 * exactly one payOrder → the outcome offers only guest-safe destinations.
 */

function parse(postData: string | null): Record<string, any> {
	return JSON.parse(postData ?? "{}")
}

async function chooseOption(
	page: import("@playwright/test").Page,
	comboboxName: string | RegExp,
	optionName: string | RegExp,
) {
	await page.getByRole("combobox", { name: comboboxName }).click()
	await page.getByRole("option", { name: optionName }).click()
}

test.describe("affiliate sign-up", () => {
	test("guest journey: verify on blur, trimmed register body, payOrder once, guest-safe outcome", async ({
		page,
	}) => {
		test.slow()
		const org = await installMockOrg(page, {
			identity: "guest",
			examreg: {
				info: affiliateLoad(),
				verifyCustomer: verifyCustomerResult(),
				register: affiliateRegisterResult(),
				payOrder: { completed: true },
			},
		})

		await page.goto("/registration/affiliate")

		// The page's only heading, and the fixed price beside the commitment.
		await expect(
			page.getByRole("heading", {
				level: 1,
				name: "Affiliate Membership Registration",
			}),
		).toBeVisible()
		// The bar's fixed total (the rail repeats "Free" in its own rows).
		await expect(
			page.getByText("Free", { exact: true }).first(),
		).toBeVisible()

		const submit = page.getByRole("button", { name: "Register", exact: true })
		await expect(submit).toBeDisabled()

		// Names first (they travel with the identity check), then the email —
		// typed with surrounding spaces so the trim is proven on the wire.
		await page.getByRole("textbox", { name: "First name" }).fill(" Ada ")
		await page.getByRole("textbox", { name: "Last name" }).fill(" Lovelace ")
		const email = page.getByRole("textbox", { name: "Email address" })
		await email.fill("ada@garp.org")
		await email.blur()

		// The blur check fires once, already trimmed, typed for this programme.
		await expect.poll(() => org.hits("verifyCustomer")).toBe(1)
		expect(parse(org.of("verifyCustomer")[0].postData)).toEqual({
			type: "affiliate",
			email: "ada@garp.org",
			firstName: "Ada",
			lastName: "Lovelace",
		})

		await chooseOption(page, "Location", "United States")
		await chooseOption(page, "Mobile phone country code", "United States (+1)")
		await page
			.getByRole("textbox", { name: "Mobile phone", exact: true })
			.fill("5551234")

		// US carries no compliance tag, so submitting IS the consent — the
		// button opens once the fields are in, with no ticks to find.
		await expect(submit).toBeEnabled()
		await submit.click()

		// The outcome replaces the form.
		await expect(
			page.getByText(/You.re an Affiliate Member/),
		).toBeVisible()

		// The register body: session quoted back, ids from the verify answer,
		// trimmed names, composite phone code, and the consent COLLAPSED to the
		// single boolean the server stores.
		expect(org.hits("register")).toBe(1)
		expect(parse(org.of("register")[0].postData)).toEqual({
			type: "affiliate",
			sessionId: "S-1",
			customer: {
				contactId: "003-verified",
				accountId: "001-verified",
				leadId: null,
				firstName: "Ada",
				lastName: "Lovelace",
				email: "ada@garp.org",
				mobilePhoneCode: "United States (+1)",
				mobilePhone: "5551234",
				smsPromotionalUpdates: false,
			},
			billingAddress: { country: "United States" },
			billingAndShippingSame: true,
			consent: { privacyPolicy: true },
		})

		// The zero-total order is settled by exactly one payOrder — the call is
		// not idempotent, and the blur session meant no second verify either.
		expect(org.hits("payOrder")).toBe(1)
		expect(parse(org.of("payOrder")[0].postData)).toEqual({
			orderId: "801-aff",
		})
		expect(org.hits("verifyCustomer")).toBe(1)
		expect(
			org.calls
				.filter(
					(call) =>
						call.kind === "examreg" &&
						["verifyCustomer", "register", "payOrder"].includes(call.key),
				)
				.map((call) => call.key),
		).toEqual(["verifyCustomer", "register", "payOrder"])

		// Guest-safe destinations only: garp.org, and a sign-in to the account
		// this registration just created. Nothing points into the walled portal.
		const exit = page.getByRole("link", { name: /Back to GARP\.org/ })
		await expect(exit).toBeVisible()
		expect(await exit.getAttribute("href")).toBe("https://www.garp.org")
		const signIn = page.getByRole("link", { name: "Sign in", exact: true })
		await expect(signIn).toBeVisible()
		expect(await signIn.getAttribute("href")).toContain("/Login")
		await expect(
			page.getByRole("link", { name: "Go to dashboard" }),
		).toHaveCount(0)
	})

	test("a mustSignIn email is told before the form is finished, with a real way in", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			identity: "guest",
			examreg: {
				info: affiliateLoad(),
				verifyCustomer: verifyCustomerResult({ mustSignIn: true }),
			},
		})

		await page.goto("/registration/affiliate")
		await page.getByRole("textbox", { name: "First name" }).fill("Ada")
		await page.getByRole("textbox", { name: "Last name" }).fill("Lovelace")
		const email = page.getByRole("textbox", { name: "Email address" })
		await email.fill("member@garp.org")
		await email.blur()

		await expect(page.getByText("You already have an account")).toBeVisible()
		const rescue = page.getByRole("link", { name: "Sign in and start again" })
		await expect(rescue).toBeVisible()
		expect(await rescue.getAttribute("href")).toContain("/Login")
		expect(org.hits("register")).toBe(0)
	})
})
