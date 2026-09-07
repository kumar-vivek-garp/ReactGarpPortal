import { expect, test } from "@playwright/test"

import type { EBookAccess } from "@/api/study-materials/types"
import {
	deniedStudyMaterials,
	myEBooksEmpty,
} from "@/testing/factories/study-materials"
import { installMockOrg, refuse, refuseWith } from "../support/mock-org"
import {
	singleProgramData,
	studyMaterialsActions,
} from "../support/study-materials"

/**
 * The listing's other answers: a per-card eBook title minting a reader link,
 * the archive gate, the members-only refusal, and a transport failure that
 * keeps the chrome intact.
 */

const ACCESS_OK: EBookAccess = {
	statusMessage: null,
	statusCode: 200,
	// Relative => resolves against the e2e static server, never the vendor.
	accessURL: "/e2e-reader-stub",
}

test.describe("study materials — eBooks and the archive", () => {
	test("Read mints a reader link for that title via eBookAccess and opens it", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: { ...studyMaterialsActions(), eBookAccess: ACCESS_OK },
		})
		await page.goto("/study-materials")
		await expect(page.getByText("Your eBooks")).toBeVisible()

		const popupPromise = page.waitForEvent("popup")
		// First Read = first vendor title of the owned Part I set = 111.
		await page.getByRole("button", { name: "Read" }).first().click()
		const popup = await popupPromise

		await expect.poll(() => org.hits("eBookAccess")).toBe(1)
		const call = org.of("eBookAccess")[0]
		expect(call.method).toBe("GET")
		expect(call.url).toContain("vendorId=111")
		await expect(popup).toHaveURL(/\/e2e-reader-stub/)
	})

	test("My eBook links appears only for a member who holds an eBook key", async ({
		page,
	}) => {
		await installMockOrg(page, {
			actions: { ...studyMaterialsActions(), myEBooks: myEBooksEmpty() },
		})
		await page.goto("/study-materials")
		await expect(page.getByText("2026 SCR Book")).toBeVisible()
		await expect(page.getByRole("link", { name: /My eBook links/ })).toHaveCount(0)

		await installMockOrg(page, { actions: studyMaterialsActions() })
		await page.goto("/study-materials")
		await page.getByRole("link", { name: /My eBook links/ }).click()
		await expect(page).toHaveURL(/\/study-materials\/archive/)
	})
})

test.describe("study materials — refusal and failure", () => {
	test("a member with no contract sees the members-only state, not an error", async ({
		page,
	}) => {
		await installMockOrg(page, {
			actions: {
				...studyMaterialsActions(),
				// Apex's real shape: HTTP 403, the message in the payload, no buckets.
				studyMaterials: refuseWith(
					403,
					"Portal Access Denied",
					deniedStudyMaterials(403),
				),
			},
		})
		await page.goto("/study-materials")

		await expect(page.getByText("Study materials are for members")).toBeVisible()
		await expect(page.getByText("Portal Access Denied")).toBeVisible()
		await expect(page.getByRole("tab")).toHaveCount(0)
		await expect(page.getByText(/couldn.t load your study materials/i)).toHaveCount(0)
		await expect(page.getByText(/unable to load/i)).toHaveCount(0)
	})

	test("a single programme earns no pills", async ({ page }) => {
		await installMockOrg(page, {
			actions: studyMaterialsActions(singleProgramData()),
		})
		await page.goto("/study-materials")

		await expect(page.getByText("FRM Study Guide")).toBeVisible()
		await expect(page.getByRole("tab")).toHaveCount(0)
	})

	test("a studyMaterials 500 shows the error line with the chrome intact", async ({
		page,
	}) => {
		await installMockOrg(page, {
			actions: {
				...studyMaterialsActions(),
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
