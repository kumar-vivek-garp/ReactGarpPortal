import { expect, test, type Route } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { RegistrationCountry } from "@/api/registration/exam-types"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	examCustomer,
	examLoad,
	examRegisterRequest,
	feesResult,
	verifyCustomerResult,
} from "@/testing/factories/exam"
import {
	demographicsOptions,
	resumeResult,
	stagedPaymentStatus,
	stagedRegisterResult,
} from "@/testing/factories/exam-payment"
import { installMockOrg, type MockOrgOptions } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * The DEFERRED card flow (`Stripe_Auth_Configuration__mdt
 * .Is_Stripe_Order_History__c` = true), as a GUEST on the public route:
 *
 * - `register` returns a STAGED id and no order; checkout must be opened
 *   under that id (falling through to "registered" here is the live bug).
 * - Stripe's cancel URL carries BOTH `checkout_cancelled` and `resume`; the
 *   resume wins — the form is rebuilt from the banked payload, nothing is
 *   rolled back, and the retry carries `resumeStagedId` so the same row is
 *   reused.
 * - A plain cancelled checkout (an ORDER, no resume) rolls back once.
 * - A declined return offers Try again with the staged id; a Failed return
 *   is a failure that needs a human, never a success.
 */

const NO_ALERT = {
	statusMessage: null,
	statusCode: 200,
	examType: null,
	examPart: null,
	alertStatus: null,
	deadline: null,
	orderId: null,
	route: null,
} satisfies AlertBarView

const UNITED_STATES: RegistrationCountry = {
	id: "cc-us",
	name: "United States",
	countryCode: "United States",
	phoneCode: "1",
	creditCardAllowed: true,
	wireAllowed: true,
	achAllowed: true,
	provinces: [{ name: "NJ" }, { name: "NY" }],
	provinceRequired: true,
	postalCodeRequired: true,
}

const STAGED_ID = "a0H000000000001"

/** `demographics` is one key for GET (picklists) and POST (save). */
async function demographicsResponder(route: Route) {
	await route.fulfill({
		json: memberPortalEnvelope(
			route.request().method() === "POST"
				? { saved: true, rejected: [] }
				: demographicsOptions(),
		),
	})
}

function guestDeferredOptions(): MockOrgOptions {
	return {
		identity: "guest",
		actions: { programs: programsListData(), alertBar: NO_ALERT },
		examreg: {
			info: examLoad({ countries: [UNITED_STATES] }),
			fees: feesResult(750),
			options: { companies: [], schools: [] },
			verifyCustomer: verifyCustomerResult({ contactId: null, accountId: null }),
			register: stagedRegisterResult({ stagedId: STAGED_ID }),
			checkout: { checkoutUrl: "/e2e-checkout-stub", stagedId: STAGED_ID },
			payOrder: {},
			rollback: {},
			demographics: demographicsResponder,
		},
	}
}

function parse(postData: string | null): Record<string, any> {
	return JSON.parse(postData ?? "{}")
}

/** The payload the candidate submitted before pressing Back on Stripe. */
function bankedPayload() {
	return examRegisterRequest({
		customer: examCustomer({
			firstName: "Resumed",
			lastName: "Candidate",
			email: "resumed@example.org",
			mobilePhoneCode: "United States (+1)",
			mobilePhone: "5551234",
		}),
		selection: {
			partSelected: "FRM Exam Part I",
			part1: { rateId: "rate-1a", siteId: "site-a2" },
			part2: null,
		},
		materials: ["SM-GEN"],
		paymentType: "Stripe",
		billingAddress: {
			company: "",
			street1: "",
			street2: "",
			street3: "",
			city: "",
			province: "",
			postalCode: "",
			country: "United States",
			phone: "",
		},
		shippingAddress: {
			company: "",
			street1: "",
			street2: "",
			street3: "",
			city: "",
			province: "",
			postalCode: "",
			country: "United States",
			phone: "",
		},
	})
}

test.describe("deferred card flow (staged registration)", () => {
	test("a staged register result opens checkout under the staged id — never 'registered'", async ({
		page,
	}) => {
		test.slow()
		const org = await installMockOrg(page, guestDeferredOptions())
		await page.goto("/registration/frm")

		await page.getByLabel(/Email/).fill("guest@example.org")
		await page.getByLabel(/First name/).fill("Grace")
		await page.getByLabel(/Last name/).fill("Hopper")
		await page
			.getByRole("combobox", { name: "Mobile phone country code" })
			.click()
		await page.getByRole("option", { name: /United States/ }).click()
		await page.getByRole("textbox", { name: /^Mobile phone/ }).fill("5551234")
		await page.getByRole("combobox", { name: "Location" }).click()
		await page.getByRole("option", { name: "United States" }).click()

		await page.getByRole("combobox", { name: "Exam part" }).click()
		await page.getByRole("option", { name: "FRM Exam Part I", exact: true }).click()
		await page.getByRole("combobox", { name: "Where you will sit" }).click()
		await page.getByRole("option", { name: "Boston" }).click()
		await page.getByRole("radio", { name: "Card", exact: true }).click()
		await page.getByRole("checkbox", { name: /Candidate Responsibility/ }).click()
		await page.getByRole("checkbox", { name: /Exam Policies/ }).click()

		const submit = page.getByRole("button", { name: "Pay and Register" })
		await expect(submit).toBeEnabled()
		await submit.click()
		await page
			.getByRole("dialog")
			.getByRole("button", { name: "Pay and Register" })
			.click()

		// Off to the provider — not a "You're registered" screen.
		await expect(page).toHaveURL(/\/e2e-checkout-stub$/)
		expect(org.hits("checkout")).toBe(1)
		const checkoutBody = parse(org.of("checkout")[0].postData)
		expect(checkoutBody.orderId).toBe(STAGED_ID)
		expect(String(checkoutBody.successUrl)).toContain(
			`/registration/frm?stripe_return=1&oid=${STAGED_ID}`,
		)
		expect(org.hits("payOrder")).toBe(0)
		expect(org.hits("rollback")).toBe(0)
	})

	test("Stripe's cancel leg for a STAGED checkout restores the form, rolls nothing back, and the retry reuses the row", async ({
		page,
	}) => {
		test.slow()
		const org = await installMockOrg(page, {
			...guestDeferredOptions(),
			examreg: {
				...guestDeferredOptions().examreg,
				resume: resumeResult({ stagedId: STAGED_ID, payload: bankedPayload() }),
			},
		})

		// The server appends `resume` to the cancel URL itself, so both arrive.
		await page.goto(
			`/registration/frm?checkout_cancelled=1&oid=${STAGED_ID}&resume=${STAGED_ID}`,
		)

		// Restored, not cancelled: what was typed and chosen is back.
		await expect(page.getByLabel(/Email/)).toHaveValue("resumed@example.org")
		await expect(page.getByLabel(/First name/)).toHaveValue("Resumed")
		await expect(page.getByRole("combobox", { name: "Exam part" })).toContainText(
			"FRM Exam Part I",
		)
		await expect(
			page.getByRole("combobox", { name: "Where you will sit" }),
		).toContainText("Chicago")
		await expect(page.getByRole("button", { name: "Remove" })).toHaveCount(1)
		await expect(
			page.getByRole("heading", { name: "Payment was not completed" }),
		).toHaveCount(0)
		expect(org.hits("resume")).toBe(1)
		expect(org.hits("rollback")).toBe(0)

		// Submitting again: the register body names the row it came from.
		const submit = page.getByRole("button", { name: "Pay and Register" })
		await expect(submit).toBeEnabled()
		await submit.click()
		await page
			.getByRole("dialog")
			.getByRole("button", { name: "Pay and Register" })
			.click()
		await expect(page).toHaveURL(/\/e2e-checkout-stub$/)
		expect(org.hits("register")).toBe(1)
		expect(parse(org.of("register")[0].postData).resumeStagedId).toBe(STAGED_ID)
	})

	test("a plain cancelled checkout (an ORDER) rolls back exactly once and offers a restart", async ({
		page,
	}) => {
		const org = await installMockOrg(page, guestDeferredOptions())
		await page.goto("/registration/frm?checkout_cancelled=1&oid=801")

		await expect(
			page.getByRole("heading", { name: "Payment was not completed" }),
		).toBeVisible()
		await expect(page.getByRole("link", { name: "Start again" })).toBeVisible()
		await expect(page.getByLabel(/Email/)).toHaveCount(0)

		await expect.poll(() => org.hits("rollback")).toBe(1)
		expect(parse(org.of("rollback")[0].postData)).toEqual({
			orderId: "801",
			reason: "Checkout cancelled",
		})
		await page.waitForTimeout(250)
		expect(org.hits("rollback")).toBe(1)
		expect(org.hits("info")).toBe(0)
	})

	test("a declined card offers Try again carrying the staged id; nothing is rolled back", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			...guestDeferredOptions(),
			examreg: {
				...guestDeferredOptions().examreg,
				paymentStatus: stagedPaymentStatus({
					registrationStatus: "Payment Failed",
					isPaymentSuccess: false,
					errorMessage: "Your card was declined.",
				}),
			},
		})
		await page.goto(`/registration/frm?stripe_return=1&oid=${STAGED_ID}`)

		await expect(
			page.getByRole("heading", {
				name: "There may have been an issue processing your payment",
			}),
		).toBeVisible()
		await expect(page.getByText(/Your card was declined\./)).toBeVisible()
		const tryAgain = page.getByRole("link", { name: "Try again" })
		await expect(tryAgain).toHaveAttribute("href", new RegExp(`resume=${STAGED_ID}`))
		await expect(
			page.getByRole("heading", { name: /Help us tailor your/ }),
		).toHaveCount(0)
		expect(org.hits("rollback")).toBe(0)
		expect(org.hits("demographics")).toBe(0)
	})

	test("paid but Failed is a failure that needs a human — never a confirmation, never the survey", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			...guestDeferredOptions(),
			examreg: {
				...guestDeferredOptions().examreg,
				paymentStatus: stagedPaymentStatus({
					registrationStatus: "Failed",
					errorMessage: "Contract creation failed",
				}),
			},
		})
		await page.goto(`/registration/frm?stripe_return=1&oid=${STAGED_ID}`)

		await expect(
			page.getByRole("heading", { name: "We could not complete your registration" }),
		).toBeVisible()
		await expect(page.getByText("REG-000123")).toBeVisible()
		await expect(
			page.getByRole("heading", { name: /Help us tailor your/ }),
		).toHaveCount(0)
		expect(org.hits("demographics")).toBe(0)
	})
})
