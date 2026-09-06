import { expect, test } from "@playwright/test"

import type { ApexStudyMaterialsPayload } from "@/api/study-materials/types"
import { installMockOrg, refuse } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * Study Materials module: owned entitlements + catalogue render from the
 * legacy-shaped `studyMaterials` payload, `?tab=` filters by program, the
 * refusal-with-data (403-in-payload) shape resolves to the purchasable
 * catalogue rather than an error, and a transport failure degrades with the
 * chrome intact.
 *
 * The wire shape is Apex `studyMaterialsInfo` buckets (see
 * `api/study-materials/normalize.ts`), NOT the normalized panel model.
 */

/** frm (one owned + one purchasable) and scr (one purchasable) buckets. */
function studyMaterialsData(): ApexStudyMaterialsPayload {
	return {
		statusMessage: null,
		statusCode: 200,
		studyMaterialsInfo: {
			frmStudyMaterials: [
				{
					title: "2026 FRM Learning",
					productCode: "FRMBP",
					materialType: "GARP Learning",
					GARPLearningAccessURL: "https://learning.garp.org/sso?prog=FRM",
					isOwned: true,
					isAvailable: true,
					isCompWithReg: true,
					// Far-future expiry so the meta line never counts down in CI.
					eBook: { keyStatus: "Taken", expireDate: "2030-12-31" },
				},
				{
					title: "FRM Exam Part I eBooks",
					productCode: "FRM-P1-EB",
					materialType: "eBook",
					shortDescription: "<p>Four digital books&nbsp;covering Part I.</p>",
					leadGenURL: "https://www.garp.org/frm/study-materials",
					price: 295,
					isOwned: false,
					isAvailable: true,
					canPurchase: true,
				},
			],
			scrStudyMaterials: [
				{
					title: "2026 SCR Book",
					productCode: "SCRH",
					materialType: "Book",
					shortDescription: "Printed book",
					leadGenURL: "https://www.garp.org/scr/purchase",
					price: 100,
					isOwned: false,
					isAvailable: true,
					canPurchase: true,
				},
			],
		},
	}
}

function baseActions(
	payload: ApexStudyMaterialsPayload = studyMaterialsData(),
): Record<string, unknown> {
	// `programs` feeds the sidebar's CPD gate on every _appLayout page; the
	// mock's `{}` default would fail fetchPrograms and toast.
	return { studyMaterials: payload, programs: programsListData() }
}

test.describe("study materials catalogue", () => {
	test("owned materials and the catalogue render from the legacy buckets", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: baseActions() })
		await page.goto("/study-materials")

		await expect(
			page.getByRole("heading", {
				name: "Study Materials for Risk Professionals",
				level: 1,
			}),
		).toBeVisible()

		// Owned section: the one isOwned row, openable via its access URL.
		await expect(
			page.getByRole("heading", { name: /My Materials.*\(1\)/ }),
		).toBeVisible()
		const open = page.getByRole("link", { name: "Open material" })
		await expect(open).toBeVisible()
		expect(await open.getAttribute("href")).toBe(
			"https://learning.garp.org/sso?prog=FRM",
		)
		// The archive entry point rides with the owned section.
		await expect(
			page.getByRole("link", { name: /My Access Links/ }),
		).toBeVisible()

		// Catalogue: every row of every bucket (the owned one included).
		await expect(
			page.getByRole("heading", { name: /Catalogue.*\(3\)/ }),
		).toBeVisible()
		await expect(page.getByText("FRM Exam Part I eBooks")).toBeVisible()
		// HTML-stripped copy, prices, and the purchase CTAs.
		await expect(
			page.getByText("Four digital books covering Part I."),
		).toBeVisible()
		await expect(page.getByText("$295")).toBeVisible()
		await expect(page.getByText("$100")).toBeVisible()
		await expect(page.getByRole("link", { name: "Purchase" })).toHaveCount(2)

		// Program pills appear because more than one bucket came back.
		await expect(page.getByRole("tab", { name: "All" })).toBeVisible()
		await expect(
			page.getByRole("tab", { name: /Financial Risk Manager/ }),
		).toBeVisible()
		await expect(
			page.getByRole("tab", { name: /Sustainability & Climate Risk/ }),
		).toBeVisible()

		await expect(page.getByText(/unable to load/i)).toHaveCount(0)
		await expect.poll(() => org.hits("studyMaterials")).toBe(1)
	})

	test("the program pills filter both sections and write ?tab=", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: baseActions() })
		await page.goto("/study-materials")
		await expect(page.getByText("2026 SCR Book")).toBeVisible()

		await page
			.getByRole("tab", { name: /Sustainability & Climate Risk/ })
			.click()

		await expect(page).toHaveURL(/\/study-materials\?tab=scr/)
		await expect(page.getByText("2026 SCR Book")).toBeVisible()
		// FRM's catalogue row AND its owned entitlement follow the filter out.
		await expect(page.getByText("FRM Exam Part I eBooks")).toBeHidden()
		await expect(
			page.getByRole("heading", { name: /My Materials/ }),
		).toBeHidden()
	})

	test("an unknown ?tab= normalizes back to the full catalogue", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: baseActions() })
		await page.goto("/study-materials?tab=bogus")

		await expect(page).toHaveURL(/\/study-materials\?tab=all/)
		await expect(page.getByText("2026 SCR Book")).toBeVisible()
	})
})

test.describe("study materials refusal and failure", () => {
	test("a refusal that still carries the catalogue renders the upsell, not an error", async ({
		page,
	}) => {
		/*
		 * The documented "403 from study materials carries the upsell" shape
		 * (api/client/member-portal-envelope.ts): the service refuses with its
		 * own non-200 statusCode INSIDE the payload while `studyMaterialsInfo`
		 * still carries the purchasable rows. Verified against the client:
		 * fetchStudyMaterials — unlike fetchMyEBooks/fetchDirectory — has no
		 * inner statusCode check, so this refusal-with-data RESOLVES and the
		 * purchase catalogue renders. (An HTTP-level 403 would throw instead;
		 * this shape is the one the current client accepts.)
		 */
		const refusal: ApexStudyMaterialsPayload = {
			statusMessage: "Not entitled to member materials",
			statusCode: 403,
			studyMaterialsInfo: {
				scrStudyMaterials: [
					{
						title: "2026 SCR Book",
						productCode: "SCRH",
						materialType: "Book",
						shortDescription: "Printed book",
						leadGenURL: "https://www.garp.org/scr/purchase",
						price: 100,
						isOwned: false,
						isAvailable: true,
						canPurchase: true,
					},
				],
			},
		}
		await installMockOrg(page, { actions: baseActions(refusal) })
		await page.goto("/study-materials")

		await expect(
			page.getByRole("heading", { name: /Catalogue.*\(1\)/ }),
		).toBeVisible()
		await expect(page.getByRole("link", { name: "Purchase" })).toBeVisible()
		// The refusal must NOT present as a failure.
		await expect(
			page.getByText(/couldn.t load your study materials/i),
		).toHaveCount(0)
		await expect(page.getByText(/unable to load/i)).toHaveCount(0)
	})

	test("a studyMaterials 500 shows the error line with the chrome intact", async ({
		page,
	}) => {
		await installMockOrg(page, {
			actions: {
				...baseActions(),
				studyMaterials: refuse(500, "Study materials service exploded"),
			},
		})
		await page.goto("/study-materials")

		await expect(
			page.getByText(/couldn.t load your study materials/i),
		).toBeVisible()
		// The failure toasts with the SERVER's message.
		await expect(
			page.getByText("Study materials service exploded"),
		).toBeVisible()
		// Chrome survives: page heading and the app header still stand.
		await expect(
			page.getByRole("heading", {
				name: "Study Materials for Risk Professionals",
				level: 1,
			}),
		).toBeVisible()
		await expect(page.locator("header").first()).toBeVisible()
	})
})
