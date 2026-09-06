import { expect, test } from "@playwright/test"

import type { Benefit, MembershipView } from "@/api/membership/types"
import {
	directorySearchResults,
	directoryView,
} from "@/testing/factories/directory"
import { identity, membershipView } from "@/testing/factories/identity"
import { installMockOrg, refuse } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * Membership module journeys: the identity hero + benefit sections render from
 * the real `membership` action, `?tab=` switches to the embedded directory,
 * the locked-benefit upsell renders for a lapsed non-member, and a membership
 * failure degrades without taking the chrome down.
 *
 * `programs` is stubbed everywhere because the sidebar's CPD gate reads it on
 * every _appLayout page — the mock org's `{}` default fails fetchPrograms'
 * statusCode check and toasts, which would poison the no-stray-toast audit.
 */

function benefit(overrides: Partial<Benefit> = {}): Benefit {
	return {
		id: "b1",
		title: "GARP Careers",
		section: "Career",
		sortOrder: 1,
		paragraphs: ["Job board access for risk professionals."],
		bullets: [],
		imageUrl: null,
		ctaLabel: null,
		ctaUrl: null,
		ctaIsExternal: false,
		opensInNewWindow: false,
		promoCode: null,
		locked: false,
		membershipRequired: false,
		...overrides,
	}
}

function memberBenefitsView(): MembershipView {
	return membershipView({
		sections: [
			{
				name: "Career",
				benefits: [
					benefit(),
					benefit({ id: "b2", title: "Networking Events" }),
				],
			},
		],
	})
}

function baseActions(
	view: MembershipView = memberBenefitsView(),
): Record<string, unknown> {
	return { membership: view, programs: programsListData() }
}

test.describe("membership benefits", () => {
	test("the hero and benefit sections render from the membership payload", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: baseActions() })
		await page.goto("/membership")

		await expect(
			page.getByRole("heading", { name: "Membership Benefits", level: 1 }),
		).toBeVisible()

		// Identity hero: name, GARP ID chip, membership type, standing.
		await expect(
			page.getByRole("heading", { name: "Ada Lovelace" }),
		).toBeVisible()
		await expect(
			page.getByRole("button", { name: "Copy GARP ID 123456" }),
		).toBeVisible()
		await expect(page.getByText("Individual", { exact: true })).toBeVisible()
		await expect(page.getByText("Active", { exact: true })).toBeVisible()

		// The section heading carries its count; both benefits render.
		await expect(page.getByRole("heading", { name: /Career.*\(2\)/ })).toBeVisible()
		await expect(page.getByText("GARP Careers")).toBeVisible()
		await expect(page.getByText("Networking Events")).toBeVisible()
		// The benefits pill counts them too.
		await expect(
			page.getByRole("tab", { name: /Member Benefits.*\(2\)/ }),
		).toBeVisible()

		// A healthy org must not toast a load failure anywhere.
		await expect(page.getByText(/unable to load/i)).toHaveCount(0)
		await expect.poll(() => org.hits("membership")).toBe(1)
	})

	test("switching to the directory tab writes ?tab= and mounts the directory", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				...baseActions(),
				directory: directoryView(),
				directorySearch: directorySearchResults(),
			},
		})
		await page.goto("/membership")
		await expect(page.getByText("GARP Careers")).toBeVisible()
		expect(org.hits("directory")).toBe(0)

		await page.getByRole("tab", { name: /Member Directory/ }).click()

		await expect(page).toHaveURL(/\/membership\?tab=directory/)
		await expect(
			page.getByText(/Find and connect with opted-in members/),
		).toBeVisible()
		await expect.poll(() => org.hits("directory")).toBe(1)
	})

	test("a lapsed non-member sees the locked-benefit upsell", async ({
		page,
	}) => {
		const lapsed = identity({
			isMember: false,
			isIndividualMember: false,
			isAffiliateMember: true,
			isMemberInGoodStanding: false,
			membershipType: "Affiliate",
			membershipStatus: "Lapsed",
			membershipExpiration: "2024-01-31",
			audience: "Affiliate",
		})
		await installMockOrg(page, {
			actions: baseActions(
				membershipView({
					identity: lapsed,
					lockedCount: 2,
					sections: [
						{
							name: "Career",
							benefits: [
								benefit({ id: "l1", title: "Locked Careers", locked: true }),
								benefit({ id: "l2", title: "Locked Events", locked: true }),
								benefit({ id: "b3", title: "Open Webcasts" }),
							],
						},
					],
				}),
			),
		})
		await page.goto("/membership")

		// Hero flags the standing: lapsed chip plus the dated expiry chip.
		await expect(page.getByText("Lapsed", { exact: true })).toBeVisible()
		await expect(page.getByText(/Expired January 31, 2024/)).toBeVisible()

		// The hero's right zone becomes the locked-benefits callout.
		await expect(page.getByText("Members-only benefits")).toBeVisible()
		await expect(
			page.getByText(
				"2 of the benefits below unlock with Individual Membership.",
			),
		).toBeVisible()

		// Each locked card carries the badge and the upgrade overlay; the open
		// benefit carries neither.
		await expect(page.getByText("Members only")).toHaveCount(2)
		await expect(page.getByText("Upgrade to unlock this benefit")).toHaveCount(2)
		await expect(page.getByText("Open Webcasts")).toBeVisible()
	})
})

test.describe("membership failure leg", () => {
	test("a membership 500 shows the error line with the chrome intact", async ({
		page,
	}) => {
		await installMockOrg(page, {
			actions: {
				...baseActions(),
				membership: refuse(500, "Membership service exploded"),
			},
		})
		await page.goto("/membership")

		await expect(
			page.getByText(/couldn.t load your membership benefits/i),
		).toBeVisible()
		// The failure toasts with the SERVER's message, never a swallowed generic.
		await expect(page.getByText("Membership service exploded")).toBeVisible()
		// Chrome survives: page heading, tab bar, and the app header all stand.
		await expect(
			page.getByRole("heading", { name: "Membership Benefits", level: 1 }),
		).toBeVisible()
		await expect(
			page.getByRole("tab", { name: /Member Directory/ }),
		).toBeVisible()
		await expect(page.locator("header").first()).toBeVisible()
	})
})
