import { describe, expect, it, vi } from "vitest"

// No HTTP boundary — jsdom's hostname is `localhost`, which would flip
// `resolvePortalAssetUrl` into its local-Vite branch and rewrite photo URLs.
vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => undefined),
}))

import {
	accountStanding,
	accountView,
	completeness,
} from "@/testing/factories/account"
import {
	buildIdentityPresentation,
	buildMissingChips,
	missingCountForSection,
} from "./account-presentation"

describe("buildMissingChips", () => {
	it("maps a known Apex label to its Career dialog field", () => {
		const chips = buildMissingChips(
			completeness({ missing: ["Employment status", "Highest degree"] }),
		)
		expect(chips).toEqual([
			{ label: "Employment status", field: "workStatus", section: "career" },
			// Apex calls it "Highest degree"; the form control is `degreeProgram`.
			{ label: "Highest degree", field: "degreeProgram", section: "career" },
		])
	})

	it("keeps an unknown label as an inert chip rather than dropping it", () => {
		expect(buildMissingChips(completeness({ missing: ["Shoe size"] }))).toEqual([
			{ label: "Shoe size", field: null, section: null },
		])
	})
})

describe("missingCountForSection", () => {
	it("charges every missing item to the Career card and nothing else", () => {
		const missing = completeness({ missing: ["Employment status", "School name"] })
		expect(missingCountForSection(missing, "career")).toBe(2)
		expect(missingCountForSection(missing, "personal")).toBe(0)
		expect(missingCountForSection(missing, "membership")).toBe(0)
	})
})

describe("buildIdentityPresentation — name and photo", () => {
	it("builds the display name from the personal record", () => {
		expect(buildIdentityPresentation(accountView()).displayName).toBe(
			"Ada Lovelace",
		)
	})

	it("falls back to the identity full name, then to a generic label", () => {
		const fromIdentity = accountView({
			personal: { firstName: null, lastName: null },
			identity: { fullName: "A. Lovelace" },
		})
		expect(buildIdentityPresentation(fromIdentity).displayName).toBe("A. Lovelace")

		const nothing = accountView({
			personal: { firstName: null, lastName: null },
			identity: { fullName: "  " },
		})
		expect(buildIdentityPresentation(nothing).displayName).toBe("Your profile")
	})

	it("prefers the personal photo and resolves nothing to undefined", () => {
		expect(buildIdentityPresentation(accountView()).photoUrl).toBeUndefined()
		const view = accountView({
			personal: { photoUrl: "/servlet/servlet.FileDownload?file=00P1" },
			identity: { photoUrl: "/servlet/other" },
		})
		expect(buildIdentityPresentation(view).photoUrl).toBe(
			"/servlet/servlet.FileDownload?file=00P1",
		)
	})
})

describe("buildIdentityPresentation — status", () => {
	it("lets the Membership contract win over the Contact", () => {
		const presentation = buildIdentityPresentation(
			accountView({
				identity: { garpId: "G-IDENTITY", membershipType: "Affiliate" },
				standing: accountStanding({ garpId: "G-STANDING", memberType: "Individual" }),
			}),
		)
		expect(presentation.garpId).toBe("G-STANDING")
		expect(presentation.memberType).toBe("Individual")
		expect(presentation.statusLabel).toBe("Active")
		expect(presentation.statusTone).toBe("success")
	})

	it("falls back to the Contact when there is no contract", () => {
		const presentation = buildIdentityPresentation(
			accountView({
				identity: {
					garpId: "G-IDENTITY",
					membershipType: "Individual",
					membershipStatus: "Active",
				},
			}),
		)
		expect(presentation.garpId).toBe("G-IDENTITY")
		expect(presentation.memberType).toBe("Individual")
		expect(presentation.statusLabel).toBe("Active")
	})

	it("shows an expired membership as Lapsed with the danger tone", () => {
		const presentation = buildIdentityPresentation(
			accountView({ identity: { membershipStatus: "Expired" } }),
		)
		expect(presentation.statusLabel).toBe("Lapsed")
		expect(presentation.statusTone).toBe("danger")
	})

	it("overrides everything with Payment Pending while an order is unpaid", () => {
		const presentation = buildIdentityPresentation(
			accountView({ standing: accountStanding({ pendingOrderId: "006x" }) }),
		)
		expect(presentation.statusLabel).toBe("Payment Pending")
		expect(presentation.statusTone).toBe("warning")
	})

	it("reads auto-renew from the contract first", () => {
		const view = accountView({
			identity: { autoRenew: false },
			standing: accountStanding({ isAutoRenewEnabled: true }),
		})
		expect(buildIdentityPresentation(view).autoRenewOn).toBe(true)
	})
})

describe("buildIdentityPresentation — meta lines", () => {
	it("lists email, phone, member-since and renewal in order, skipping blanks", () => {
		const presentation = buildIdentityPresentation(
			accountView({
				personal: { phone: "5551234567" },
				identity: { memberSince: "2020-03-01" },
				standing: accountStanding({
					isAutoRenewEnabled: true,
					expirationDate: "2027-03-01",
				}),
			}),
		)
		expect(presentation.metaLines).toEqual([
			{ icon: "email", text: "ada@example.com" },
			{ icon: "phone", text: "5551234567" },
			{ icon: "memberSince", text: "Member since March 1, 2020" },
			{ icon: "renews", text: "Renews March 1, 2027" },
		])
	})

	it("reads the renewal wording from the Contact when there is no contract", () => {
		const presentation = buildIdentityPresentation(
			accountView({
				personal: { email: null },
				identity: { autoRenew: true, membershipExpiration: "2027-03-01" },
			}),
		)
		expect(presentation.metaLines).toEqual([
			{ icon: "renews", text: "Renews March 1, 2027" },
		])
	})

	it("says Expires when auto-renew is off and Expired once it has", () => {
		const expiring = buildIdentityPresentation(
			accountView({
				personal: { email: null },
				standing: accountStanding({ expirationDate: "2027-03-01" }),
			}),
		)
		expect(expiring.metaLines).toEqual([
			{ icon: "renews", text: "Expires March 1, 2027" },
		])

		const expired = buildIdentityPresentation(
			accountView({
				personal: { email: null },
				standing: accountStanding({
					memberStatus: "Expired",
					expirationDate: "2026-03-01",
				}),
			}),
		)
		expect(expired.metaLines).toEqual([
			{ icon: "renews", text: "Expired March 1, 2026" },
		])
	})

	it("suppresses the renewal line while a payment is pending", () => {
		// The date on file is about to change; asserting it would mislead.
		const presentation = buildIdentityPresentation(
			accountView({
				personal: { email: null },
				standing: accountStanding({
					pendingOrderId: "006x",
					expirationDate: "2027-03-01",
				}),
			}),
		)
		expect(presentation.metaLines).toEqual([])
	})

	it("passes completeness through for the profile meter", () => {
		const presentation = buildIdentityPresentation(
			accountView({ completeness: { percentComplete: 64, isComplete: false } }),
		)
		expect(presentation.percentComplete).toBe(64)
		expect(presentation.isComplete).toBe(false)
	})
})
