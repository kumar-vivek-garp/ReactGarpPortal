import { describe, expect, it } from "vitest"

import {
	isMembershipKind,
	memberBackKind,
	railEmptyState,
	showAutorenew,
	showMembershipOffer,
	showRiskNet,
} from "./registration-presentation"

/**
 * The membership-kind rules — the branches GarpAppv1's `isMembership` flag
 * drives. Kept apart from `registration-presentation.test.ts`, which is
 * already past the size cap.
 */

describe("isMembershipKind", () => {
	it("is true for the membership kind only", () => {
		expect(isMembershipKind("membership")).toBe(true)
		expect(isMembershipKind("exam")).toBe(false)
		expect(isMembershipKind("course")).toBe(false)
		// A missing kind reads as an exam, never as a membership.
		expect(isMembershipKind(null)).toBe(false)
		expect(isMembershipKind(undefined)).toBe(false)
	})
})

describe("showAutorenew — the membership programme", () => {
	it("offers auto-renew on a card membership order with nothing ticked", () => {
		// GarpAppv1's `isMembership ||` clause: the membership IS the purchase.
		expect(showAutorenew(false, "Stripe", false, false, true)).toBe(true)
		expect(showAutorenew(null, "Stripe", null, false, true)).toBe(true)
	})

	it("still needs a card — there is no saved method to renew against otherwise", () => {
		expect(showAutorenew(false, "Wire Transfer", false, false, true)).toBe(false)
		expect(showAutorenew(false, "ACH", false, false, true)).toBe(false)
		expect(showAutorenew(false, "", false, false, true)).toBe(false)
	})

	it("does not ask someone whose contract already auto-renews", () => {
		expect(showAutorenew(true, "Stripe", false, false, true)).toBe(false)
	})

	it("leaves the exam and course rules exactly as they were", () => {
		expect(showAutorenew(false, "Stripe", true)).toBe(true)
		expect(showAutorenew(false, "Stripe", false, true)).toBe(true)
		expect(showAutorenew(false, "Stripe", false, false)).toBe(false)
		expect(showAutorenew(false, "Stripe", false)).toBe(false)
	})
})

describe("showRiskNet", () => {
	const offer = { productCode: "MEMR", amount: 100, months: 12 }

	it("shows the add-on on the membership form when the server priced one", () => {
		expect(showRiskNet("membership", offer)).toBe(true)
	})

	it("never shows it without an offer, or on any other kind", () => {
		expect(showRiskNet("membership", null)).toBe(false)
		expect(showRiskNet("membership", undefined)).toBe(false)
		// The server never sends one for these, and the card must not appear
		// even if a payload did — MEMR is priced against membership cover.
		expect(showRiskNet("exam", offer)).toBe(false)
		expect(showRiskNet("course", offer)).toBe(false)
		expect(showRiskNet(undefined, offer)).toBe(false)
	})
})

describe("showMembershipOffer", () => {
	const offer = { productCode: "MEMI", amount: 195 }

	it("shows the course upsell when the server priced one", () => {
		expect(showMembershipOffer("course", offer)).toBe(true)
		// An exam never gets one, but the rule is the offer's presence.
		expect(showMembershipOffer("exam", offer)).toBe(true)
	})

	it("never shows it on the membership form — the membership IS the order", () => {
		expect(showMembershipOffer("membership", offer)).toBe(false)
		expect(showMembershipOffer("course", null)).toBe(false)
		expect(showMembershipOffer("course", undefined)).toBe(false)
	})
})

describe("memberBackKind", () => {
	it("sends a membership purchase back to Membership Benefits", () => {
		expect(memberBackKind("membership")).toBe("membership")
	})

	it("sends every programme back to the programmes listing", () => {
		expect(memberBackKind("exam")).toBe("programs")
		expect(memberBackKind("course")).toBe("programs")
		expect(memberBackKind(undefined)).toBe("programs")
	})
})

describe("railEmptyState", () => {
	it("asks an exam candidate to choose their exam", () => {
		const state = railEmptyState("exam")
		expect(state.message).toBe("Choose your exam to see the total.")
		expect(state.ghostLabels).toEqual([
			"Exam registration",
			"Enrollment fee",
			"Total",
		])
		expect(railEmptyState(undefined)).toEqual(state)
	})

	it("never asks a membership buyer to choose an exam", () => {
		const state = railEmptyState("membership")
		expect(state.message).toBe("Pricing your membership…")
		expect(state.ghostLabels).toEqual(["Individual Membership", "Total"])
		expect(state.message).not.toMatch(/exam/i)
	})

	it("keeps a course generic", () => {
		expect(railEmptyState("course").ghostLabels).toEqual([
			"Course registration",
			"Total",
		])
	})

	it("always ends on the total row", () => {
		for (const kind of ["exam", "course", "membership"] as const) {
			const labels = railEmptyState(kind).ghostLabels
			expect(labels[labels.length - 1]).toBe("Total")
		}
	})
})
