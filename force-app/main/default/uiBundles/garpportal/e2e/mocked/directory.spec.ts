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

		// Nothing is asked for until criteria are entered: no rows, no request.
		await expect(page.getByText("Results will display here")).toBeVisible()
		await expect(
			page.getByRole("button", { name: "View Ada Lovelace" }),
		).toHaveCount(0)
		await page.waitForTimeout(600)
		expect(org.hits("directorySearch")).toBe(0)

		// A burst of 6 keystrokes inside the 350ms debounce window buys exactly
		// ONE POST, carrying the settled term, the first page and a clamped size.
		await page
			.getByRole("textbox", { name: "Search the member directory" })
			.pressSequentially("hopper", { delay: 40 })
		await expect.poll(() => org.hits("directorySearch")).toBe(1)
		await page.waitForTimeout(600)
		expect(org.hits("directorySearch")).toBe(1)

		const searchCalls = org.of("directorySearch")
		const searched = parse(searchCalls[searchCalls.length - 1].postData)
		expect(searched.searchText).toBe("hopper")
		expect(searched.pageCurrent).toBe(1)
		expect(searched.pageSize).toBe(10)

		// The rows the org returned land once the search has been made.
		await expect(
			page.getByRole("button", { name: "View Ada Lovelace" }),
		).toBeVisible()
		await expect(
			page.getByRole("button", { name: "View Grace Hopper" }),
		).toBeVisible()
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
