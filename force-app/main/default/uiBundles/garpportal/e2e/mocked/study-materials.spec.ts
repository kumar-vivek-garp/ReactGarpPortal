import { expect, test } from "@playwright/test"

import { installMockOrg } from "../support/mock-org"
import { studyMaterialsActions } from "../support/study-materials"

/**
 * Study Materials listing: one card per material, filed under its programme
 * and — for FRM — its exam part, with the card's action decided by the
 * legacy's chain (GARP Learning → eBook → download → unpaid order → owned →
 * coming soon → out of stock → purchase). `?tab=` filters by programme and
 * the provider's `?purchased=1` return is acknowledged once.
 *
 * States, denial and failure live in `study-materials-states.spec.ts`.
 */

test.describe("study materials catalogue", () => {
	test("renders every card state from the legacy buckets, one card each", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: studyMaterialsActions() })
		await page.goto("/study-materials")

		await expect(
			page.getByRole("heading", {
				name: "Study Materials for Risk Professionals",
				level: 1,
			}),
		).toBeVisible()

		// Programmes in the legacy's order, each counted, FRM split by part.
		await expect(
			page.getByRole("heading", { name: /Financial Risk Manager.*\(3\)/ }),
		).toBeVisible()
		/*
		 * Each programme splits into what the member holds and what is still on
		 * sale; the FRM part grouping runs inside those as captions rather than
		 * headings. Scoped to main — the footer carries its own level-3s.
		 */
		await expect(
			page.getByRole("main").getByRole("heading", { level: 3 }),
		).toHaveText([
			"My Materials(2)",
			"Available to Purchase(1)",
			"Available to Purchase(1)",
			"Available to Purchase(1)",
		])
		await expect(page.getByText("Part 1", { exact: true })).toBeVisible()
		await expect(page.getByText("Part 2", { exact: true })).toBeVisible()

		// 1. GARP Learning: the SSO button, plus the practice-exam add-on with
		//    its pending order.
		const learning = page.getByRole("link", { name: "Access GARP Learning" })
		await expect(learning).toHaveAttribute(
			"href",
			"https://learning.garp.org/sso?prog=FRM&part=1",
		)
		await expect(learning).toHaveAttribute("target", "_blank")
		await expect(page.getByText("Upgrade for Additional Content")).toBeVisible()
		await expect(page.getByText("USD 75")).toBeVisible()
		await expect(
			page.getByRole("link", { name: /Order awaiting payment/ }),
		).toHaveAttribute("href", "/my-account/orders/006ADDON0000000001")

		// 5. Owned with the registration: the eBook titles, and no action.
		await expect(page.getByText("Your eBooks")).toBeVisible()
		await expect(page.getByRole("button", { name: "Read" })).toHaveCount(2)
		await expect(page.getByText(/Included with your registration/)).toBeVisible()
		await expect(page.getByText("Four digital books covering Part I.")).toBeVisible()

		// 8. For sale: price and the in-app purchase page (asserted by href —
		//    the page itself has its own spec).
		await expect(page.getByText("USD 295")).toBeVisible()
		await expect(page.getByRole("link", { name: /Purchase/ })).toHaveAttribute(
			"href",
			"/study-materials/purchase/FRM2H",
		)

		// 4. Unpaid order → the order. 6. Coming soon → Notify me. 7. Out of stock.
		await expect(
			page.getByRole("link", { name: /Complete your order/ }),
		).toHaveAttribute("href", "/my-account/orders/006UNPAID00000001")
		// The coming-soon line, not the "Available to Purchase" block headings.
		await expect(page.getByText(/^Available (?!to Purchase)/)).toBeVisible()
		await expect(page.getByRole("link", { name: /Notify me/ })).toHaveAttribute(
			"href",
			"https://www.garp.org/rai/notify",
		)
		await expect(page.getByText("Out of stock").first()).toBeVisible()

		// Errata per programme, on the route each programme's errata lives at.
		const errata = page.getByRole("link", { name: /Report an error/ })
		await expect(errata).toHaveCount(4)
		expect(await errata.evaluateAll((els) => els.map((e) => e.getAttribute("href")))).toEqual([
			"/programs/frm/errata",
			"/programs/scr/errata",
			"/programs/riskai/errata",
			"/programs/frr/errata",
		])

		// The archive entry point, because this member holds a key.
		await expect(page.getByRole("link", { name: /My eBook links/ })).toBeVisible()

		await expect(page.getByText(/unable to load/i)).toHaveCount(0)
		await expect.poll(() => org.hits("studyMaterials")).toBe(1)
		await expect.poll(() => org.hits("myEBooks")).toBe(1)
	})

	/*
	 * Ownership is a section, not just a chip: each programme splits into what
	 * the member holds and what is still on sale, so "is there anything here I
	 * still need?" is answered by the headings rather than by reading cards.
	 */
	test("each programme splits into My Materials and Available to Purchase", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: studyMaterialsActions() })
		await page.goto("/study-materials?tab=frm")

		const frm = page.getByRole("region", { name: /Financial Risk Manager/ })
		await expect(
			frm.getByRole("heading", { name: /^My Materials/ }),
		).toBeVisible()
		await expect(
			frm.getByRole("heading", { name: /^Available to Purchase/ }),
		).toBeVisible()

		// The owned material states when it was acquired, in its meta run.
		await expect(
			frm.getByText(/Included with your registration on /),
		).toBeVisible()
		// …and the one for sale keeps its Purchase link in the other block.
		await expect(
			frm
				.getByRole("heading", { name: /^Available to Purchase/ })
				.locator("xpath=following::a[contains(., 'Purchase')][1]"),
		).toBeVisible()
	})

	test("the program pills filter the page and write ?tab=", async ({ page }) => {
		await installMockOrg(page, { actions: studyMaterialsActions() })
		await page.goto("/study-materials")
		await expect(page.getByText("2026 SCR Book")).toBeVisible()

		await page
			.getByRole("tab", { name: /Sustainability & Climate Risk/ })
			.click()

		await expect(page).toHaveURL(/\/study-materials\?tab=scr/)
		await expect(page.getByText("2026 SCR Book")).toBeVisible()
		await expect(page.getByText("2026 FRM Exam Part II Books")).toBeHidden()
		await expect(page.getByRole("link", { name: /Report an error/ })).toHaveCount(1)
	})

	test("an unknown ?tab= normalizes back to the full catalogue", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: studyMaterialsActions() })
		await page.goto("/study-materials?tab=bogus")

		await expect(page).toHaveURL(/\/study-materials\?tab=all/)
		await expect(page.getByText("2026 SCR Book")).toBeVisible()
	})

	test("the provider's success return is acknowledged once and dropped from the address", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: studyMaterialsActions() })
		await page.goto("/study-materials?purchased=1")

		await expect(page.getByText("Purchase complete")).toBeVisible()
		await expect(page).not.toHaveURL(/purchased/)
		await expect(page.getByText("2026 SCR Book")).toBeVisible()
	})
})
