import { expect, test, type Route } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import { accountOptionsView } from "@/testing/factories/account-options"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { examLoad, feesResult } from "@/testing/factories/exam"
import {
	demographicsOptions,
	paymentStatusResult,
	stagedPaymentStatus,
} from "@/testing/factories/exam-payment"
import {
	accountViewFromPersonalInfo,
	billingCompanyGraphql,
	personalInfoEditData,
	portalAddressFields,
} from "@/testing/factories/personal-info"
import { installMockOrg, type MockOrgOptions } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * The post-registration "Complete Your Profile" survey, on the payment
 * return leg of both audiences. Two save paths, picked by the client
 * session and never by a URL:
 *
 * - GUEST: picklists from `GET examreg/demographics`, saved with
 *   `POST examreg/demographics { key, values }` — `key` being the staged or
 *   order id the registration itself returned.
 * - MEMBER: options and the current record from the member portal, saved
 *   through `POST memberportal/profile { values }`.
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

const PROFILE = personalInfoEditData({
	mailing: portalAddressFields(),
	sameAsBilling: true,
})

const STAGED_ID = "a0H000000000001"

function parse(postData: string | null): Record<string, any> {
	return JSON.parse(postData ?? "{}")
}

async function demographicsResponder(route: Route) {
	await route.fulfill({
		json: memberPortalEnvelope(
			route.request().method() === "POST"
				? { saved: true, rejected: [] }
				: demographicsOptions(),
		),
	})
}

function guestOptions(): MockOrgOptions {
	return {
		identity: "guest",
		actions: { programs: programsListData(), alertBar: NO_ALERT },
		examreg: {
			info: examLoad(),
			fees: feesResult(750),
			options: { companies: ["Acme Bank"], schools: ["MIT"] },
			paymentStatus: stagedPaymentStatus(),
			demographics: demographicsResponder,
		},
	}
}

function memberOptions(): MockOrgOptions {
	const demographics = demographicsOptions()
	return {
		actions: {
			programs: programsListData(),
			alertBar: NO_ALERT,
			account: accountViewFromPersonalInfo(PROFILE),
			options: accountOptionsView({
				picklists: demographics.picklists,
				workingYears: demographics.workingYears,
				graduationYears: demographics.graduationYears,
				organizations: ["Acme Bank"],
				schools: ["MIT"],
			}),
			profile: {
				applied: ["Job_Function__c"],
				rejected: [],
				completeness: { percentComplete: 80 },
			},
		},
		graphql: { BillingCompany: billingCompanyGraphql(PROFILE) },
		examreg: {
			info: examLoad({ isAuthenticated: true, contact: { id: "003-member" } }),
			paymentStatus: paymentStatusResult({ orderNumber: "ORD-1001" }),
		},
	}
}

test.describe("post-registration survey", () => {
	test("a GUEST saves through the registration module with the registration's own id as the key", async ({
		page,
	}) => {
		const org = await installMockOrg(page, guestOptions())
		await page.goto(`/registration/frm?stripe_return=1&oid=${STAGED_ID}`)

		await expect(page.getByText("Thank you — payment received")).toBeVisible()
		await expect(
			page.getByRole("heading", { name: /Help us tailor your/ }),
		).toBeVisible()
		// Guest reads: the module's picklists and its company/school lists.
		expect(org.hits("demographics")).toBe(1)
		expect(org.hits("options")).toBe(1)
		expect(org.hits("account")).toBe(0)

		await page.getByRole("combobox", { name: /work status/i }).click()
		await page.getByRole("option", { name: "Working", exact: true }).click()
		await page.getByRole("combobox", { name: /job function/i }).click()
		await page.getByRole("option", { name: "Risk Management" }).click()
		await page.getByRole("combobox", { name: /risk specialty/i }).click()
		await page.getByRole("option", { name: "Credit Risk" }).click()
		await page.getByLabel(/most recent company/i).fill("Acme Bank")
		await page.getByRole("button", { name: "Next" }).click()
		await page.getByRole("checkbox", { name: "CFA" }).click()
		await page.getByRole("button", { name: "Next" }).click()
		await page.getByRole("button", { name: "Save my answers" }).click()

		// Saved: the closing actions come back, guest-safe.
		await expect(
			page.getByRole("link", { name: "Sign in", exact: true }),
		).toBeVisible()
		const saves = org
			.of("demographics")
			.filter((call) => call.method === "POST")
		expect(saves).toHaveLength(1)
		const body = parse(saves[0].postData)
		expect(body.key).toBe(STAGED_ID)
		expect(body.values).toMatchObject({
			Currently_Working_Status__c: "Working",
			Job_Function__c: "Risk Management",
			Risk_Specialty__c: "Credit Risk",
			Company__c: "Acme Bank",
			Professional_Designation_CFA__c: true,
			Professional_Designation_CA__c: false,
			Area_of_Concentration__c: null,
		})
		expect(org.hits("profile")).toBe(0)
	})

	test("a MEMBER saves through the member-portal profile, never the registration key", async ({
		page,
	}) => {
		const org = await installMockOrg(page, memberOptions())
		await page.goto("/programs/frm/register?stripe_return=1&oid=801")

		await expect(page.getByText("Thank you — payment received")).toBeVisible()
		await expect(
			page.getByRole("heading", { name: /Help us tailor your/ }),
		).toBeVisible()
		expect(org.hits("options")).toBe(1)
		expect(org.hits("demographics")).toBe(0)

		await page.getByRole("combobox", { name: /job function/i }).click()
		await page.getByRole("option", { name: "Trading" }).click()
		await page.getByRole("button", { name: "Next" }).click()
		await page.getByRole("button", { name: "Next" }).click()
		await page.getByRole("button", { name: "Save my answers" }).click()

		await expect(page.getByRole("link", { name: "Go to dashboard" })).toBeVisible()
		expect(org.hits("profile")).toBe(1)
		expect(parse(org.of("profile")[0].postData).values).toMatchObject({
			Job_Function__c: "Trading",
			Risk_Specialty__c: null,
		})
		expect(org.hits("demographics")).toBe(0)
	})
})
