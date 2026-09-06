import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { CpdActivityFieldInfo, CpdCycleInfo } from "@/api/cpd"
import { cpdClaim, cpdCycleInfo, cpdProgramView } from "@/testing/factories/cpd"
import { installMockOrg } from "../support/mock-org"
import { dashboardActionSet } from "../support/payloads"

/**
 * The CPD write journeys: Add Credits fetches its two option GETs lazily and
 * posts the typed claim, delete confirms and posts `cpdClaimDelete`, and an
 * unattested certificate click walks the two-checkbox attestation dialog into
 * a `cpdAttest` POST. Every write triggers a `cpdProgram` refetch via the
 * shared cache invalidation.
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

/** One activity type whose admin labels switch on three dynamic fields. */
const WEBINAR: CpdActivityFieldInfo = {
	id: "type-webinar",
	name: "Webinar",
	organizationLabel: "Organization",
	providerLabel: "Provider",
	publicationLabel: null,
	titleLabel: "Title",
	contactEmailLabel: null,
}

/** `GET options` — the Area of Study picklist the claim form renders. */
function optionsData() {
	return {
		picklists: {
			Area_of_Study__c: [
				{ label: "Credit Risk", value: "Credit Risk" },
				{ label: "Market Risk", value: "Market Risk" },
			],
		},
		chapters: [],
	}
}

/** Every CPD write answers 200 — `status` is the only honest outcome signal. */
const SAVE_OK = { status: "Success", msg: null, claimId: "claim-9" }

function cpdProgramData(currentCycle: Partial<CpdCycleInfo> = {}) {
	return cpdProgramView({
		cycles: [
			cpdCycleInfo({
				pendingClaims: [
					cpdClaim({ claimId: "claim-1", title: "Climate Risk Webinar" }),
				],
				approvedClaims: [],
				...currentCycle,
			}),
		],
	})
}

function claimsActions(
	currentCycle: Partial<CpdCycleInfo> = {},
): Record<string, unknown> {
	return {
		...dashboardActionSet(),
		alertBar: NO_ALERT,
		cpdProgram: cpdProgramData(currentCycle),
		cpdActivityTypes: [WEBINAR],
		options: optionsData(),
		cpdClaim: SAVE_OK,
		cpdClaimDelete: SAVE_OK,
		cpdAttest: SAVE_OK,
	}
}

test.describe("add credits", () => {
	test("the dialog loads its options lazily and posts the typed claim", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: claimsActions() })
		await page.goto("/cpd")

		// Lazy: neither GET fires until the form actually mounts.
		await expect(page.getByRole("button", { name: "Add Credits" })).toBeVisible()
		expect(org.hits("cpdActivityTypes")).toBe(0)
		expect(org.hits("options")).toBe(0)

		await page.getByRole("button", { name: "Add Credits" }).click()
		const dialog = page.getByRole("dialog", { name: "Credit Details" })
		await expect(dialog).toBeVisible()
		await expect.poll(() => org.hits("cpdActivityTypes")).toBe(1)
		await expect.poll(() => org.hits("options")).toBe(1)

		// Picking the type reveals its admin-configured dynamic fields.
		await dialog
			.getByRole("combobox", { name: "Activity Type*", exact: true })
			.click()
		await page.getByRole("option", { name: "Webinar" }).click()

		await dialog.getByRole("checkbox", { name: "Credit Risk" }).click()
		await dialog
			.getByLabel("Date of Completion*", { exact: true })
			.fill("2026-02-01")
		await dialog.getByLabel("Number of Credits*", { exact: true }).fill("2.5")
		await dialog.getByLabel("Organization*", { exact: true }).fill("GARP")
		await dialog.getByLabel("Title*", { exact: true }).fill("Climate Webinar")
		// Provider is the one shown-but-optional extra; left empty on purpose.
		await dialog.getByRole("button", { name: "Submit", exact: true }).click()

		await expect(page.getByRole("dialog")).toBeHidden()
		await expect(page.getByText("Activity submitted")).toBeVisible()

		// The wire shape: exactly the chosen type's fields, no claimId on create.
		expect(org.hits("cpdClaim")).toBe(1)
		expect(JSON.parse(org.of("cpdClaim")[0].postData ?? "{}")).toEqual({
			activityType: "type-webinar",
			credits: 2.5,
			dateOfCompletionString: "2026-02-01",
			areaOfStudy: "Credit Risk",
			comments: null,
			URL: null,
			organizationName: "GARP",
			provider: null,
			title: "Climate Webinar",
		})

		// The write invalidates the CPD cache and the page refetches its claims.
		await expect.poll(() => org.hits("cpdProgram")).toBe(2)
	})
})

test.describe("delete a pending activity", () => {
	test("confirming posts cpdClaimDelete with the claim id and refetches", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: claimsActions() })
		await page.goto("/cpd")

		await page
			.getByRole("button", { name: "Delete Climate Risk Webinar" })
			.click()
		await expect(
			page.getByRole("dialog", { name: "Delete this submission?" }),
		).toBeVisible()
		await page.getByRole("button", { name: "Delete", exact: true }).click()

		await expect(page.getByRole("dialog")).toBeHidden()
		await expect(page.getByText("Activity deleted")).toBeVisible()

		expect(org.hits("cpdClaimDelete")).toBe(1)
		expect(JSON.parse(org.of("cpdClaimDelete")[0].postData ?? "{}")).toEqual({
			claimId: "claim-1",
		})
		await expect.poll(() => org.hits("cpdProgram")).toBe(2)
	})
})

test.describe("attestation", () => {
	test("a certificate click gates on two checkboxes, posts cpdAttest, then opens the PDF", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: claimsActions({
				isFRMCompleted: true,
				completedFRMCertURL: "/apex/CPDCertificate_FRM?id=cert-1",
				attestationID: "att-1",
			}),
		})
		// The success path calls window.open on an external Experience URL —
		// stub it so no real network is touched, and record what it was given.
		await page.addInitScript(() => {
			const opened: string[] = []
			Object.defineProperty(window, "__openedUrls", { value: opened })
			window.open = ((url?: string | URL) => {
				opened.push(String(url ?? ""))
				return null
			}) as typeof window.open
		})
		await page.goto("/cpd")

		// Unattested, so the certificate row is a button, not a link.
		await page.getByRole("button", { name: "CPD Certificate - FRM" }).click()
		const dialog = page.getByRole("dialog", {
			name: /You have completed your required 40 credits/,
		})
		await expect(dialog).toBeVisible()

		// Both boxes must be ticked before Submit arms.
		const submit = dialog.getByRole("button", { name: "Submit", exact: true })
		await expect(submit).toBeDisabled()
		await dialog
			.getByRole("checkbox", { name: /I attest that all I have submitted/ })
			.click()
		await expect(submit).toBeDisabled()
		await dialog
			.getByRole("checkbox", { name: /Code of Conduct/ })
			.click()
		await expect(submit).toBeEnabled()
		await submit.click()

		await expect(page.getByRole("dialog")).toBeHidden()

		expect(org.hits("cpdAttest")).toBe(1)
		expect(JSON.parse(org.of("cpdAttest")[0].postData ?? "{}")).toEqual({
			attestationId: "att-1",
		})

		// On success the certificate the member asked for opens.
		await expect
			.poll(() =>
				page.evaluate(
					() =>
						(window as Window & { __openedUrls?: string[] }).__openedUrls ?? [],
				),
			)
			.toContainEqual(expect.stringContaining("CPDCertificate_FRM"))

		// `isAttested` gates the cert links, so the refetch here is load-bearing.
		await expect.poll(() => org.hits("cpdProgram")).toBe(2)
	})
})
