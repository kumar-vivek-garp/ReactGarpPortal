/**
 * Pure derivations for the exam registration form.
 *
 * Everything here is a function of the load payload plus the candidate's
 * choices — no React, no network — so the rules that decide what is shown and
 * what the cart contains are testable on their own.
 */

import type {
	ExamAdminView,
	ExamPartView,
	ExamSiteView,
	FeeLine,
	StudyMaterialView,
} from "@/api/registration/exam-types"

/**
 * Which parts a selection covers.
 *
 * Derived from the `partsAvailable` STRING, not from `program.isTwoPart` —
 * that flag is on the payload but never describes a choice, and the choice is
 * what the form keys off. FRM offers "FRM Exam Part I" and "FRM Exam Part I
 * and FRM Exam Part II", so the combined option has to activate both.
 *
 * The negative lookahead is what separates them: `Part I(?!I)` matches the
 * first "Part I" in the combined string but never the "Part I" inside
 * "Part II".
 */
export function isPart1Active(partSelected: string): boolean {
	return /Part I(?!I)/.test(partSelected)
}

export function isPart2Active(partSelected: string): boolean {
	return partSelected.includes("Part II")
}

/** Sittings, earliest exam window first. */
export function sortAdmins(admins: ExamAdminView[]): ExamAdminView[] {
	return [...admins].sort(
		(a, b) => (a.examStartEpoch ?? 0) - (b.examStartEpoch ?? 0),
	)
}

/** Sites A–Z. */
export function sortSites(sites: ExamSiteView[]): ExamSiteView[] {
	return [...sites].sort((a, b) => (a.name || "").localeCompare(b.name || ""))
}

export function findPart(
	parts: ExamPartView[] | undefined,
	key: "part1" | "part2",
): ExamPartView | null {
	return parts?.find((part) => part.key === key) ?? null
}

export function findAdmin(
	part: ExamPartView | null,
	rateId: string,
): ExamAdminView | null {
	if (!rateId) return null
	return part?.admins.find((admin) => admin.id === rateId) ?? null
}

export function findSite(
	admin: ExamAdminView | null,
	siteId: string,
): ExamSiteView | null {
	if (!siteId) return null
	return admin?.sites.find((site) => site.id === siteId) ?? null
}

/**
 * The selection actually in force for one part.
 *
 * A derivation rather than state synced by an effect, because two of these are
 * defaults rather than choices:
 *
 * 1. **The earliest sitting is pre-selected.** When a part offers only one,
 *    the UI shows it as a statement rather than a control — so without a
 *    default the rate id stays empty, the part is sent as `null`, and the cart
 *    never prices at all.
 * 2. **A site only survives if it belongs to the chosen sitting.** Sites hang
 *    off the sitting, so a leftover id would price against a centre that
 *    sitting does not run. A single-site sitting fills itself in for the same
 *    reason as (1).
 *
 * An inactive part resolves to nothing, so dropping Part II drops its choice.
 */
export function resolvePartSelection(
	active: boolean,
	chosen: { rateId: string; siteId: string },
	admins: ExamAdminView[],
): { rateId: string; siteId: string } {
	if (!active) return { rateId: "", siteId: "" }

	const rateId = chosen.rateId || admins[0]?.id || ""
	const admin = admins.find((candidate) => candidate.id === rateId) ?? null
	const sites = admin?.sites ?? []

	if (sites.some((site) => site.id === chosen.siteId)) {
		return { rateId, siteId: chosen.siteId }
	}
	return { rateId, siteId: sites.length === 1 ? sites[0].id : "" }
}

/**
 * Part II must not sit before Part I.
 *
 * Strictly greater-than: both parts of one sitting share a start date, so `>=`
 * would refuse the normal "both parts" booking.
 */
export function isOutOfOrder(
	part1Active: boolean,
	part2Active: boolean,
	admin1: ExamAdminView | null,
	admin2: ExamAdminView | null,
): boolean {
	if (!part1Active || !part2Active || !admin1 || !admin2) return false
	return (admin1.examStartEpoch ?? 0) > (admin2.examStartEpoch ?? 0)
}

/** China test centres need the extra identity details. */
export function isOstaRequired(
	site1: ExamSiteView | null,
	site2: ExamSiteView | null,
): boolean {
	return site1?.isOSTA === true || site2?.isOSTA === true
}

/**
 * Materials for the parts actually being registered.
 *
 * A part-agnostic material always shows; a Part 1 book disappears when the
 * candidate switches to Part II only.
 */
export function visibleStudyMaterials<T extends StudyMaterialView>(
	materials: T[],
	part1Active: boolean,
	part2Active: boolean,
): T[] {
	return materials.filter((material) => {
		if (material.relatedPart === "Part 1") return part1Active
		if (material.relatedPart === "Part 2") return part2Active
		return true
	})
}

/**
 * Two lists, because they mean different things.
 *
 * `included` arrives with the registration — no price, no control. `offered`
 * is what the candidate can add. `isCompSelectable` deliberately lands in
 * `offered`: it is free but must be chosen, because shipping is still charged.
 */
export function splitStudyMaterials<T extends StudyMaterialView>(
	materials: T[],
): { included: T[]; offered: T[] } {
	return {
		included: materials.filter(
			(m) => m.isComp === true && m.isCompSelectable !== true,
		),
		offered: materials.filter(
			(m) => m.isComp !== true || m.isCompSelectable === true,
		),
	}
}

/**
 * Cart order: enrolment fees first, then paid items, then included ones, each
 * group by descending amount. Tax lines are excluded — they show in the
 * summary footer against their own labels, not as cart rows.
 */
export function sortFeeLines(lines: FeeLine[]): FeeLine[] {
	return [...lines]
		.filter((line) => line.isTax !== true)
		.sort(
			(a, b) =>
				Number(b.isEnrollment === true) - Number(a.isEnrollment === true) ||
				Number(a.isComp === true) - Number(b.isComp === true) ||
				(b.amount ?? 0) - (a.amount ?? 0),
		)
}

/**
 * A subtotal row only earns its place when it differs from the total — one
 * untaxed line would print the same number twice.
 */
export function showSubtotal(
	lines: FeeLine[],
	vatAmount?: number | null,
	njSalesTax?: number | null,
): boolean {
	return lines.length > 1 || (vatAmount ?? 0) > 0 || (njSalesTax ?? 0) > 0
}

/** `Register` when there is nothing to pay; otherwise by payment type. */
export function submitLabel(hasBilling: boolean, paymentType: string): string {
	if (!hasBilling) return "Register"
	if (paymentType === "Wire Transfer" || paymentType === "ACH") {
		return "Submit Order"
	}
	return "Pay and Register"
}

/** The dial digits Apex reads back out of `"United States (+1)"`. */
export function phoneCodeDigits(mobilePhoneCode: string): string | null {
	return mobilePhoneCode.replace(/[^0-9]/g, "") || null
}
