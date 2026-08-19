import { afterEach, describe, expect, it, vi } from "vitest"

import type { Identity } from "@/api/account/types"
import type { Benefit, PortalCard } from "@/api/membership/types"
import {
	buildBenefitPresentation,
	buildMembershipHeroPresentation,
	buildMembershipIdentityPresentation,
	lockedBenefitsNotice,
} from "./membership-presentation"

afterEach(() => {
	vi.useRealTimers()
})

function benefit(overrides: Partial<Benefit> = {}): Benefit {
	return {
		id: "b1",
		title: "Risk Intelligence",
		section: "Knowledge",
		sortOrder: 1,
		paragraphs: ["Curated research.", "Updated weekly."],
		bullets: [],
		imageUrl: null,
		ctaLabel: "Explore",
		ctaUrl: "https://www.garp.org/risk-intelligence",
		ctaIsExternal: true,
		opensInNewWindow: true,
		promoCode: null,
		locked: false,
		membershipRequired: false,
		...overrides,
	}
}

function heroCard(overrides: Partial<PortalCard> = {}): PortalCard {
	return {
		key: "hero",
		page: "membership",
		provider: null,
		rank: 1,
		title: "Individual Membership",
		body: "Unlock every member benefit.",
		ctaLabel: "Upgrade",
		ctaUrl: "https://www.garp.org/membership",
		ctaIsExternal: true,
		imageUrl: null,
		eyebrow: "Membership",
		badge: "Best value",
		locked: false,
		dismissible: false,
		bullets: ["Directory access", "Preferential pricing"],
		meta: {},
		...overrides,
	}
}

describe("buildBenefitPresentation", () => {
	it("joins paragraphs into one clamped body", () => {
		expect(buildBenefitPresentation(benefit()).body).toBe(
			"Curated research. Updated weekly.",
		)
	})

	it("returns null body when there is no copy", () => {
		expect(buildBenefitPresentation(benefit({ paragraphs: [] })).body).toBeNull()
		expect(
			buildBenefitPresentation(benefit({ paragraphs: ["  ", ""] })).body,
		).toBeNull()
	})

	it("caps bullets and reports how many were trimmed", () => {
		const result = buildBenefitPresentation(
			benefit({ bullets: ["one", "two", "three", "four", "five"] }),
		)
		expect(result.bullets).toEqual(["one", "two", "three"])
		expect(result.hiddenBulletCount).toBe(2)
	})

	it("reports no hidden bullets when everything fits", () => {
		const result = buildBenefitPresentation(benefit({ bullets: ["one", "two"] }))
		expect(result.bullets).toHaveLength(2)
		expect(result.hiddenBulletCount).toBe(0)
	})

	it("ignores blank bullets when counting", () => {
		const result = buildBenefitPresentation(
			benefit({ bullets: ["one", "   ", "two"] }),
		)
		expect(result.bullets).toEqual(["one", "two"])
		expect(result.hiddenBulletCount).toBe(0)
	})

	it("badges locked benefits and leaves unlocked ones unbadged", () => {
		const locked = buildBenefitPresentation(benefit({ locked: true }))
		expect(locked.statusLabel).toBe("Members only")
		expect(locked.statusTone).toBe("info")

		const open = buildBenefitPresentation(benefit())
		expect(open.statusLabel).toBeNull()
		expect(open.statusTone).toBeNull()
	})

	it("builds a cta only when both label and url are present", () => {
		expect(buildBenefitPresentation(benefit()).cta).toEqual({
			label: "Explore",
			url: "https://www.garp.org/risk-intelligence",
			isExternal: true,
			newWindow: true,
		})
		expect(buildBenefitPresentation(benefit({ ctaUrl: null })).cta).toBeNull()
		expect(buildBenefitPresentation(benefit({ ctaLabel: "  " })).cta).toBeNull()
	})

	it("falls back to a placeholder title", () => {
		expect(buildBenefitPresentation(benefit({ title: null })).title).toBe(
			"Benefit",
		)
	})
})

function identity(overrides: Partial<Identity> = {}): Identity {
	return {
		contactId: "c1",
		firstName: "QATEST2",
		lastName: "TEST1",
		fullName: "QATEST2 TEST1",
		email: "member@example.com",
		garpId: "2472763",
		membershipType: "Individual",
		membershipStatus: "Active",
		membershipExpiration: "2028-02-09",
		memberSince: "2026-08-10",
		autoRenew: true,
		isMember: true,
		isIndividualMember: true,
		isAffiliateMember: false,
		audience: "Individual" as Identity["audience"],
		photoUrl: null,
		...overrides,
	}
}

describe("buildMembershipIdentityPresentation", () => {
	it("tones an active membership as success", () => {
		const result = buildMembershipIdentityPresentation(identity())
		expect(result.statusLabel).toBe("Active")
		expect(result.statusTone).toBe("success")
	})

	it("stays neutral for any non-active status rather than guessing severity", () => {
		const result = buildMembershipIdentityPresentation(
			identity({ membershipStatus: "Lapsed" }),
		)
		expect(result.statusLabel).toBe("Lapsed")
		expect(result.statusTone).toBe("neutral")
	})

	it("surfaces memberSince and autoRenew, which were previously dropped", () => {
		const result = buildMembershipIdentityPresentation(identity())
		expect(result.memberSinceLabel).toContain("Member since")
		expect(result.autoRenewLabel).toBe("Auto-renew on")
	})

	it("stays quiet about auto-renew when it is off", () => {
		expect(
			buildMembershipIdentityPresentation(identity({ autoRenew: false }))
				.autoRenewLabel,
		).toBeNull()
	})

	it("states a far-off renewal date without a tone", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const result = buildMembershipIdentityPresentation(identity())
		expect(result.expiryLabel).toContain("Renews")
		expect(result.expiryTone).toBeNull()
	})

	it("warns as renewal approaches", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2028, 0, 10))
		const result = buildMembershipIdentityPresentation(identity())
		expect(result.expiryLabel).toBe("Expires in 30 days")
		expect(result.expiryTone).toBe("warning")
	})

	it("flags an expired membership as danger", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2028, 5, 1))
		const result = buildMembershipIdentityPresentation(identity())
		expect(result.expiryLabel).toContain("Expired")
		expect(result.expiryTone).toBe("danger")
	})

	it("tolerates missing dates", () => {
		const result = buildMembershipIdentityPresentation(
			identity({ membershipExpiration: null, memberSince: null }),
		)
		expect(result.expiryLabel).toBeNull()
		expect(result.memberSinceLabel).toBeNull()
	})
})

describe("buildMembershipHeroPresentation", () => {
	it("surfaces eyebrow, badge and bullets that were previously dropped", () => {
		const result = buildMembershipHeroPresentation(heroCard())
		expect(result.eyebrow).toBe("Membership")
		expect(result.badgeLabel).toBe("Best value")
		expect(result.bullets).toEqual(["Directory access", "Preferential pricing"])
	})

	it("hero ctas default to same-tab — PortalCard has no newWindow flag", () => {
		expect(buildMembershipHeroPresentation(heroCard()).cta?.newWindow).toBe(false)
	})

	it("degrades to empty values with no hero card", () => {
		expect(buildMembershipHeroPresentation(null)).toEqual({
			eyebrow: null,
			badgeLabel: null,
			body: null,
			bullets: [],
			cta: null,
		})
	})

	it("treats blank strings as absent", () => {
		const result = buildMembershipHeroPresentation(
			heroCard({ eyebrow: "  ", badge: "", body: "   " }),
		)
		expect(result.eyebrow).toBeNull()
		expect(result.badgeLabel).toBeNull()
		expect(result.body).toBeNull()
	})
})

describe("lockedBenefitsNotice", () => {
	it("agrees in number", () => {
		expect(lockedBenefitsNotice(1)).toContain("1 of the benefits below unlocks")
		expect(lockedBenefitsNotice(4)).toContain("4 of the benefits below unlock ")
	})

	it("says nothing when nothing is locked", () => {
		expect(lockedBenefitsNotice(0)).toBeNull()
		expect(lockedBenefitsNotice(-1)).toBeNull()
	})
})
