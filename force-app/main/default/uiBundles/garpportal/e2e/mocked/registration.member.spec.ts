import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { RegistrationCountry } from "@/api/registration/exam-types"
import {
	examLoad,
	examRegisterResult,
	feesResult,
	verifyCustomerResult,
} from "@/testing/factories/exam"
import {
	accountViewFromPersonalInfo,
	billingCompanyGraphql,
	personalInfoEditData,
	portalAddressFields,
} from "@/testing/factories/personal-info"
import { installMockOrg } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * The full MEMBER exam journey at /programs/frm/register, against the built
 * app: the examLoad-driven form renders member-shaped (no name/email
 * controls, phone still asked), the cascading exam choice prices the cart on
 * a debounce, an OFFLINE payment (Wire Transfer) raises the address card,
 * the confirm dialog STAGES the submit (nothing written while it is open),
 * and Confirm runs the module's contract in order:
 * verifyCustomer → verifyAddress → register → payOrder(exactly once) →
 * paymentStatus, ending on the invoiced outcome with the order number.
 *
 * `payOrder` is the not-idempotent call — the final assertion that it was
 * hit exactly once IS the point of this spec.
 */

/** No floating alert over the form's sticky bar. */
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

/**
 * The factory's default country carries no payment permissions, which would
 * leave every tile disabled — this journey needs wire (and the country's own
 * province/postal rules, so the prefilled billing address validates).
 */
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

function memberExamLoad() {
	return examLoad({
		isAuthenticated: true,
		contact: { id: "003-member" },
		countries: [UNITED_STATES],
	})
}

/**
 * The member's own record, served as the composed account payload the
 * registration panel hydrates from.
 * Mailing mirrors billing on purpose: the loader DERIVES same-as-billing by
 * comparing the two, so differing addresses would mount the shipping card.
 */
const PROFILE = personalInfoEditData({
	mailing: portalAddressFields(),
	sameAsBilling: true,
})

function parse(postData: string | null): Record<string, any> {
	return JSON.parse(postData ?? "{}")
}

test.describe("member exam registration", () => {
	test("wire-transfer journey: staged confirm, ordered call sequence, payOrder once", async ({
		page,
	}) => {
		test.slow()

		const org = await installMockOrg(page, {
			actions: {
				programs: programsListData(),
				alertBar: NO_ALERT,
				account: accountViewFromPersonalInfo(PROFILE),
			},
			graphql: { BillingCompany: billingCompanyGraphql(PROFILE) },
			examreg: {
				info: memberExamLoad(),
				fees: feesResult(750),
				verifyCustomer: verifyCustomerResult(),
				verifyAddress: {
					billingValid: true,
					billingAllowed: true,
					shippingValid: true,
					shippingAllowed: true,
					message: null,
				},
				register: examRegisterResult(),
				payOrder: { completed: true },
				// A wire order's real answer: the order exists, and no payment is recorded
			// yet — finance settles it days later. The poll accepts that first time.
			paymentStatus: { isOrderFound: true, isPaymentFound: false },
			},
		})

		await page.goto("/programs/frm/register")

		// The programme's own h1, through the mega-menu heading.
		await expect(
			page.getByRole("heading", { level: 1, name: /Financial Risk Manager/ }),
		).toBeVisible()

		// Member-shaped details card: name/email come from the record, so their
		// controls are gone — the phone stays, prefilled, because exam-day
		// messages go to it.
		await expect(page.getByText("Contact details")).toBeVisible()
		await expect(page.getByRole("textbox", { name: "First name" })).toHaveCount(0)
		await expect(page.getByRole("textbox", { name: "Last name" })).toHaveCount(0)
		await expect(
			page.getByRole("textbox", { name: "Email", exact: true }),
		).toHaveCount(0)
		await expect(
			page.getByRole("textbox", { name: "Mobile phone", exact: true }),
		).toHaveValue("5551234")

		// Pick the exam: part, then site. The sitting auto-resolves to the
		// earliest (May 2027 / rate-1a), so only the exam centre is a choice.
		await page.getByRole("combobox", { name: "Exam part" }).click()
		await page
			.getByRole("option", { name: "FRM Exam Part I", exact: true })
			.click()
		await page.getByRole("combobox", { name: "Where you will sit" }).click()
		await page.getByRole("option", { name: "Boston" }).click()

		// The debounced pricing settles on the FULL selection...
		await expect
			.poll(() =>
				org.of("fees").some((call) => {
					const body = parse(call.postData)
					return (
						body.selection?.part1?.rateId === "rate-1a" &&
						body.selection?.part1?.siteId === "site-a1"
					)
				}),
			)
			.toBe(true)
		// ...and the priced total reaches the bar (AnimatedAmount settles there).
		await expect(page.getByText("USD 750.00").first()).toBeVisible()

		// Offline payment: the Wire Transfer tile, which raises the address card
		// (prefilled from the member's record) and relabels submit.
		await page.getByRole("radio", { name: "Wire transfer" }).click()
		await expect(page.getByText("Billing & shipping")).toBeVisible()
		await expect(
			page.getByRole("textbox", { name: "Street address", exact: true }),
		).toHaveValue("1 Main St")

		// Wait for the re-price under the new payment type to settle, then prove
		// the 400ms debounce: a burst of keystrokes into a priced field buys ONE
		// fees call, not one per character.
		await expect
			.poll(() =>
				org
					.of("fees")
					.some((call) => parse(call.postData).paymentType === "Wire Transfer"),
			)
			.toBe(true)
		await page.waitForTimeout(700)
		const baseline = org.hits("fees")
		const city = page.getByRole("textbox", { name: "City", exact: true })
		await city.click()
		await page.keyboard.press("End")
		await city.pressSequentially("town", { delay: 40 })
		await expect(city).toHaveValue("Hobokentown")
		await expect.poll(() => org.hits("fees")).toBe(baseline + 1)
		await page.waitForTimeout(700)
		expect(org.hits("fees")).toBe(baseline + 1)

		// Submit stays closed until the required consents are in.
		const submit = page.getByRole("button", { name: "Submit Order" })
		await expect(submit).toBeDisabled()
		await page
			.getByRole("checkbox", { name: /Candidate Responsibility/ })
			.click()
		await page.getByRole("checkbox", { name: /Exam Policies/ }).click()
		await expect(submit).toBeEnabled()

		// Submit STAGES: the dialog opens with the figures and NOTHING has been
		// written yet — no identity call, no order.
		await submit.click()
		const dialog = page.getByRole("dialog")
		await expect(dialog.getByText("Confirm your registration")).toBeVisible()
		await expect(dialog.getByText("An invoice will be raised")).toBeVisible()
		expect(org.hits("verifyCustomer")).toBe(0)
		expect(org.hits("register")).toBe(0)

		// Confirm fires the whole sequence.
		await dialog.getByRole("button", { name: "Submit Order" }).click()

		// The invoiced outcome, with the order number given prominence.
		await expect(page.getByText("Your order has been submitted")).toBeVisible()
		await expect(page.getByText("ORD-1001")).toBeVisible()
		// Member outcome offers the in-portal destinations.
		// The optional survey stands between the outcome and its actions —
		// shown after every successful registration, wire included.
		await expect(
			page.getByRole("heading", { name: /Help us tailor your/ }),
		).toBeVisible()
		await page.getByRole("button", { name: "Skip for now" }).click()
		await expect(
			page.getByRole("link", { name: "Go to dashboard" }),
		).toBeVisible()

		// THE contract: the four writes in order — verify, address check (wire
		// collects an address), register, the one payOrder, then the poll.
		const WRITE_KEYS = new Set([
			"verifyCustomer",
			"verifyAddress",
			"register",
			"payOrder",
			"paymentStatus",
		])
		expect(
			org.calls
				.filter((call) => call.kind === "examreg" && WRITE_KEYS.has(call.key))
				.map((call) => call.key),
		).toEqual([
			"verifyCustomer",
			"verifyAddress",
			"register",
			"payOrder",
			"paymentStatus",
		])

		// payOrder: exactly once, exactly this body — it is not idempotent.
		expect(org.hits("payOrder")).toBe(1)
		expect(org.of("payOrder")[0].postData).toBe(
			'{"orderId":"801-order","paymentType":"Wire Transfer"}',
		)

		// The register body carries the verified session and the collapsed
		// consents, and the address exactly as edited on screen.
		const registerBody = parse(org.of("register")[0].postData)
		expect(registerBody.type).toBe("frm")
		expect(registerBody.sessionId).toBe("S-1")
		expect(registerBody.customer.contactId).toBe("003-verified")
		expect(registerBody.customer.email).toBe("ada@example.org")
		expect(registerBody.customer.mobilePhoneCode).toBe("United States (+1)")
		expect(registerBody.paymentType).toBe("Wire Transfer")
		expect(registerBody.selection).toEqual({
			partSelected: "FRM Exam Part I",
			part1: { rateId: "rate-1a", siteId: "site-a1" },
			part2: null,
		})
		expect(registerBody.billingAddress.city).toBe("Hobokentown")
		expect(registerBody.billingAddress.country).toBe("United States")
		expect(registerBody.consent).toEqual({
			// US carries no compliance tag: submitting IS the privacy agreement.
			privacyPolicy: true,
			examPolicy: true,
			osta: false,
			releaseExamResults: false,
		})
		// No OSTA site chosen — the identity block must not travel.
		expect(registerBody.personal).toBeNull()
	})
})
