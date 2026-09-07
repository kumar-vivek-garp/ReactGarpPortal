import { describe, expect, it, vi } from "vitest"

// No HTTP boundary — jsdom's hostname is `localhost`, which would flip
// `resolvePortalAssetUrl` (imported by the module under test) into its
// local-Vite branch.
vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => undefined),
}))

import { accountStanding, accountView } from "@/testing/factories/account"
import { buildMembershipPresentation } from "./account-presentation"

/** An Individual with an active contract, auto-renew off — the base case. */
function individual(overrides: Parameters<typeof accountStanding>[0] = {}) {
	return accountView({ standing: accountStanding(overrides) })
}

describe("buildMembershipPresentation — intro copy", () => {
	it("describes the benefits to an active Individual", () => {
		expect(buildMembershipPresentation(individual(), false).intro).toContain(
			"Your Individual Membership unlocks",
		)
	})

	it("asks an Affiliate to upgrade", () => {
		const presentation = buildMembershipPresentation(
			individual({ memberType: "Affiliate" }),
			false,
		)
		expect(presentation.intro).toContain("Upgrade to Individual Membership")
	})

	it("asks a lapsed Individual to renew", () => {
		const presentation = buildMembershipPresentation(
			individual({ memberStatus: "Expired", statusLabel: "Lapsed" }),
			false,
		)
		expect(presentation.intro).toContain("Renew your Individual Membership")
	})

	it("treats any non-Activated contract label as lapsed, not only Expired", () => {
		// A Cancelled contract: Apex labels it Lapsed while memberStatus is not
		// "Expired". GarpAppv1 keys off the label, and so must this.
		const presentation = buildMembershipPresentation(
			individual({ memberStatus: "Cancelled", statusLabel: "Lapsed" }),
			false,
		)
		expect(presentation.intro).toContain("Renew your Individual Membership")
		expect(presentation.showTurnOnCallout).toBe(false)
		expect(presentation.statusTone).toBe("danger")
	})

	it("classifies from the Contact when there is no contract", () => {
		const presentation = buildMembershipPresentation(
			accountView({ identity: { isAffiliateMember: true } }),
			false,
		)
		expect(presentation.intro).toContain("Upgrade to Individual Membership")
	})
})

describe("buildMembershipPresentation — status and facts", () => {
	it("shows the label with its expiry for an active membership", () => {
		expect(buildMembershipPresentation(individual(), false).statusText).toBe(
			"Active (until March 1, 2027)",
		)
	})

	it("shows when an expired membership lapsed", () => {
		const presentation = buildMembershipPresentation(
			individual({
				memberStatus: "Expired",
				statusLabel: "Lapsed",
				expirationDate: "2026-03-01",
			}),
			false,
		)
		expect(presentation.statusText).toBe("Lapsed (expired March 1, 2026)")
		expect(presentation.statusTone).toBe("danger")
	})

	it("derives Lapsed itself when the contract carries no label", () => {
		const presentation = buildMembershipPresentation(
			individual({
				memberStatus: "Expired",
				statusLabel: null,
				expirationDate: "2026-03-01",
			}),
			false,
		)
		expect(presentation.statusText).toBe("Lapsed (expired March 1, 2026)")
	})

	it("shows the bare label when no expiry is on file", () => {
		expect(
			buildMembershipPresentation(individual({ expirationDate: null }), false)
				.statusText,
		).toBe("Active")
	})

	it("is null with nothing to say", () => {
		expect(
			buildMembershipPresentation(
				individual({ statusLabel: null, memberStatus: null }),
				false,
			).statusText,
		).toBeNull()
	})

	it("formats Member Since from the contract, falling back to the Contact", () => {
		expect(buildMembershipPresentation(individual(), false).memberSince).toBe(
			"March 1, 2020",
		)
		expect(
			buildMembershipPresentation(
				accountView({ identity: { memberSince: "2019-06-15" } }),
				false,
			).memberSince,
		).toBe("June 15, 2019")
	})

	it("flags a certification holder", () => {
		expect(buildMembershipPresentation(individual(), false).isCertHolder).toBe(false)
		expect(
			buildMembershipPresentation(individual({ isCertHolder: true }), false)
				.isCertHolder,
		).toBe(true)
	})

	it("quotes the cert-holder rate only to a cert holder", () => {
		expect(buildMembershipPresentation(individual(), false).renewAmount).toBe("195")
		expect(
			buildMembershipPresentation(individual({ isCertHolder: true }), false)
				.renewAmount,
		).toBe("150")
	})
})

describe("buildMembershipPresentation — pending order outranks everything", () => {
	it("overrides the status, names the order and offers View Order alone", () => {
		const presentation = buildMembershipPresentation(
			individual({
				isAutoRenewEnabled: true,
				pendingOrderId: "006x",
				pendingOrderNumber: "INV-42",
				pendingOrderAmount: 195,
			}),
			false,
		)
		expect(presentation.statusText).toBe("Payment Pending")
		expect(presentation.statusTone).toBe("warning")
		expect(presentation.pendingOrderId).toBe("006x")
		expect(presentation.pendingOrderText).toBe(
			"Order INV-42 — $195.00 is waiting to be paid.",
		)
		expect(presentation.action).toBe("viewOrder")
		expect(presentation.showOnCallout).toBe(false)
		expect(presentation.showTurnOnCallout).toBe(false)
	})

	it("falls back to the id and omits the amount when the order carries neither", () => {
		expect(
			buildMembershipPresentation(individual({ pendingOrderId: "006x" }), false)
				.pendingOrderText,
		).toBe("Order 006x is waiting to be paid.")
	})

	it("has no order line without a pending order", () => {
		expect(buildMembershipPresentation(individual(), false).pendingOrderText).toBeNull()
	})
})

describe("buildMembershipPresentation — auto-renew callouts and action", () => {
	it("invites an Individual without auto-renew to turn it on, and offers Renew Now", () => {
		const presentation = buildMembershipPresentation(individual(), false)
		expect(presentation.showTurnOnCallout).toBe(true)
		expect(presentation.showOnCallout).toBe(false)
		expect(presentation.action).toBe("renewNow")
	})

	it("confirms auto-renew when it is on, and offers only Disable", () => {
		const presentation = buildMembershipPresentation(
			individual({ isAutoRenewEnabled: true }),
			false,
		)
		expect(presentation.showOnCallout).toBe(true)
		expect(presentation.showTurnOnCallout).toBe(false)
		expect(presentation.action).toBe("disable")
	})

	it("says the card is saved while Stripe's webhook has not flipped the contract", () => {
		// The member just came back from Stripe; Apex still reports auto-renew off.
		const presentation = buildMembershipPresentation(individual(), true)
		expect(presentation.showCardSaved).toBe(true)
		// Not GarpAppv1's behaviour, deliberately: no second Stripe session
		// while the first card is still landing.
		expect(presentation.showTurnOnCallout).toBe(false)
		// Renew Now stays offered, as in GarpAppv1.
		expect(presentation.action).toBe("renewNow")
	})

	it("drops the saved notice once the contract itself reports auto-renew on", () => {
		const presentation = buildMembershipPresentation(
			individual({ isAutoRenewEnabled: true }),
			true,
		)
		expect(presentation.showCardSaved).toBe(false)
		expect(presentation.showOnCallout).toBe(true)
	})

	it("offers a lapsed Individual Renew Now and no turn-on invitation", () => {
		const expired = buildMembershipPresentation(
			individual({ memberStatus: "Expired", statusLabel: "Lapsed" }),
			false,
		)
		expect(expired.showTurnOnCallout).toBe(false)
		expect(expired.action).toBe("renewNow")
	})

	it("offers an Affiliate the upgrade, unless an order is pending", () => {
		expect(
			buildMembershipPresentation(individual({ memberType: "Affiliate" }), false)
				.action,
		).toBe("upgrade")
		expect(
			buildMembershipPresentation(
				individual({ memberType: "Affiliate", pendingOrderId: "006x" }),
				false,
			).action,
		).toBe("viewOrder")
	})

	it("offers nothing to an account with no membership at all", () => {
		expect(buildMembershipPresentation(accountView(), false).action).toBeNull()
	})
})
