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

	it("classifies from the Contact when there is no contract", () => {
		const presentation = buildMembershipPresentation(
			accountView({ identity: { isAffiliateMember: true } }),
			false,
		)
		expect(presentation.intro).toContain("Upgrade to Individual Membership")
	})
})

describe("buildMembershipPresentation — status text", () => {
	it("shows the label with its expiry for an active membership", () => {
		expect(buildMembershipPresentation(individual(), false).statusText).toBe(
			"Active (Until March 1, 2027)",
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

	it("overrides everything with Payment Pending", () => {
		const presentation = buildMembershipPresentation(
			individual({ pendingOrderId: "006x" }),
			false,
		)
		expect(presentation.statusText).toBe("Payment Pending")
		expect(presentation.statusTone).toBe("warning")
		expect(presentation.showViewOrder).toBe(true)
		expect(presentation.pendingOrderId).toBe("006x")
	})
})

describe("buildMembershipPresentation — renewal amount", () => {
	it("quotes the cert-holder rate only to a cert holder", () => {
		expect(buildMembershipPresentation(individual(), false).renewAmount).toBe("195")
		expect(
			buildMembershipPresentation(individual({ isCertHolder: true }), false)
				.renewAmount,
		).toBe("150")
	})
})

describe("buildMembershipPresentation — auto-renew callouts", () => {
	it("invites an Individual without auto-renew to turn it on", () => {
		const presentation = buildMembershipPresentation(individual(), false)
		expect(presentation.showTurnOnCallout).toBe(true)
		expect(presentation.showOnCallout).toBe(false)
		expect(presentation.showRenewNow).toBe(true)
		expect(presentation.showDisable).toBe(false)
	})

	it("confirms auto-renew when it is on", () => {
		const presentation = buildMembershipPresentation(
			individual({ isAutoRenewEnabled: true }),
			false,
		)
		expect(presentation.showOnCallout).toBe(true)
		expect(presentation.showDisable).toBe(true)
		expect(presentation.showTurnOnCallout).toBe(false)
		expect(presentation.showRenewNow).toBe(false)
	})

	it("holds the invite while Stripe setup has not landed on the contract", () => {
		// The member just finished checkout; Apex has not flipped the flag yet.
		const presentation = buildMembershipPresentation(individual(), true)
		expect(presentation.isAutoRenewPending).toBe(true)
		expect(presentation.showTurnOnCallout).toBe(false)
	})

	it("is not pending once the contract itself reports auto-renew on", () => {
		const presentation = buildMembershipPresentation(
			individual({ isAutoRenewEnabled: true }),
			true,
		)
		expect(presentation.isAutoRenewPending).toBe(false)
	})

	it("offers nothing auto-renew to an expired or pending membership", () => {
		const expired = buildMembershipPresentation(
			individual({ memberStatus: "Expired", statusLabel: "Lapsed" }),
			false,
		)
		expect(expired.showTurnOnCallout).toBe(false)
		// Renew Now is exactly what a lapsed Individual should still see.
		expect(expired.showRenewNow).toBe(true)

		const pending = buildMembershipPresentation(
			individual({ pendingOrderId: "006x" }),
			false,
		)
		expect(pending.showTurnOnCallout).toBe(false)
		expect(pending.showRenewNow).toBe(false)
	})
})

describe("buildMembershipPresentation — upgrade", () => {
	it("offers the upgrade to an Affiliate without a pending order", () => {
		expect(
			buildMembershipPresentation(individual({ memberType: "Affiliate" }), false)
				.showUpgrade,
		).toBe(true)
		expect(
			buildMembershipPresentation(
				individual({ memberType: "Affiliate", pendingOrderId: "006x" }),
				false,
			).showUpgrade,
		).toBe(false)
	})

	it("never offers it to an Individual", () => {
		expect(buildMembershipPresentation(individual(), false).showUpgrade).toBe(false)
	})
})
