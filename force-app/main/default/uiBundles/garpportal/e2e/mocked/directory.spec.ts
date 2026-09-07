import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import {
	directoryMember,
	directorySearchResults,
	directoryView,
} from "@/testing/factories/directory"
import { installMockOrg } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * Member Directory journeys: an entitled member gets the search-as-you-type
 * panel (one DEBOUNCED `directorySearch` POST per pause, carrying the term),
 * a row opens the member dialog, and a member whose entitlement says no gets
 * the gate — with zero searches fired on their behalf.
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

const ADA = directoryMember()
const GRACE = directoryMember({
	id: "003-2",
	garpId: "G-2",
	name: "Grace Hopper",
	firstName: "Grace",
	lastName: "Hopper",
	mailingCity: "Arlington",
	mailingCountry: "United States",
	company: "US Navy",
	corporateTitle: "Rear Admiral",
	canSendMessage: false,
	canInvite: true,
})

function entitledActions() {
	return {
		programs: programsListData(),
		alertBar: NO_ALERT,
		directory: directoryView(),
		directorySearch: directorySearchResults({ members: [ADA, GRACE] }),
		/** The filter dialog's picklists — empty is a valid, quiet answer. */
		options: { picklists: {}, chapters: [] },
	}
}

function parse(postData: string | null): Record<string, any> {
	return JSON.parse(postData ?? "{}")
}

test.describe("member directory", () => {
	test("entitled render, debounced search POST with the term, member dialog opens", async ({
		page,
	}) => {
		test.slow()
		const org = await installMockOrg(page, { actions: entitledActions() })
		await page.goto("/member-directory")

		await expect(
			page.getByRole("heading", { name: "Member Directory", level: 1 }),
		).toBeVisible()

		// The first (empty-term) page renders the rows the org returned.
		await expect(
			page.getByRole("button", { name: "View Ada Lovelace" }),
		).toBeVisible()
		await expect(
			page.getByRole("button", { name: "View Grace Hopper" }),
		).toBeVisible()

		// The mount search is a real search: empty term (sent as null — the
		// server's "everyone I may see"), first page, clamped size.
		await expect.poll(() => org.hits("directorySearch")).toBeGreaterThan(0)
		const first = parse(org.of("directorySearch")[0].postData)
		expect(first.searchText).toBeNull()
		expect(first.pageCurrent).toBe(1)
		expect(first.pageSize).toBe(10)

		// Let the mount settle fully, then type a burst: 6 keystrokes inside the
		// 350ms debounce window must buy exactly ONE more POST, carrying the term.
		await page.waitForTimeout(600)
		const baseline = org.hits("directorySearch")
		await page
			.getByRole("textbox", { name: "Search the member directory" })
			.pressSequentially("hopper", { delay: 40 })
		await expect.poll(() => org.hits("directorySearch")).toBe(baseline + 1)
		await page.waitForTimeout(600)
		expect(org.hits("directorySearch")).toBe(baseline + 1)
		const searchCalls = org.of("directorySearch")
		const searched = parse(searchCalls[searchCalls.length - 1].postData)
		expect(searched.searchText).toBe("hopper")
		expect(searched.pageCurrent).toBe(1)

		// A row opens the member dialog with the redacted entry.
		await page.getByRole("button", { name: "View Grace Hopper" }).click()
		const dialog = page.getByRole("dialog")
		await expect(dialog.getByText("Grace Hopper")).toBeVisible()
		await expect(dialog.getByText("US Navy")).toBeVisible()
	})

	test("not entitled: the gate renders its upsell and no search ever fires", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				...entitledActions(),
				directory: directoryView({
					hasDirectoryAccess: false,
					hasDirectoryAdvancedSearchAccess: false,
					hasDirectorySettingsAccess: false,
					upsellMembershipType: "Upgrade",
				}),
			},
		})
		await page.goto("/member-directory")

		await expect(
			page.getByText("The directory is not available on your membership"),
		).toBeVisible()
		// The upsell says what to do about it, and points at the tagged
		// membership purchase form — not the benefits page.
		const upsell = page.getByRole("link", { name: "Upgrade" })
		await expect(upsell).toBeVisible()
		expect(await upsell.getAttribute("href")).toBe(
			"/membership/register?track_cta=PortalMembershipPage",
		)

		// No search box, and none run on this member's behalf.
		await expect(
			page.getByRole("textbox", { name: "Search the member directory" }),
		).toHaveCount(0)
		expect(org.hits("directorySearch")).toBe(0)
	})
})
