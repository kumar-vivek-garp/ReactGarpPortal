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

/* ===================== identity (OSTA) ===================== */

/**
 * Whether an ID number is acceptable for where it was issued.
 *
 * Ported verbatim from the legacy, and it matters more here than most ported
 * rules: Apex applies NO validation to the identity block — it writes whatever
 * arrives straight onto the Contact. If this is wrong, a candidate turns up at
 * a Chinese test centre with an ID GARP recorded incorrectly.
 *
 * The China passport rule excludes **I** and **O** because they are too easily
 * confused with 1 and 0 on a printed document.
 *
 * Returns null when the number is acceptable, or when it is empty — an absent
 * value is the "required" check's business, not this one's.
 */
export function idFormatError(
	idLocation: string,
	idType: string,
	idNumber: string,
): string | null {
	if (!idNumber) return null

	if (idLocation === "China") {
		if (idType === "Passport") {
			if (idNumber.length !== 9) return "Your ID must be 9 characters long."
			if (!/^[A-HJ-NP-Za-hj-np-z0-9]{9}$/.test(idNumber)) {
				return 'Your ID must only contain numbers and letters, not including "I" or "O".'
			}
			return null
		}
		if (!/^[A-Za-z0-9]{18}$/.test(idNumber)) {
			return "Your ID should consist of 18 numbers or letters."
		}
		return null
	}

	if (idType === "Passport") {
		if (!/^[A-Za-z0-9]{5,10}$/.test(idNumber)) {
			return "Your ID must be between 5 and 10 characters long, and only contain numbers and letters."
		}
		return null
	}

	if (!/^[A-Za-z0-9]{5,25}$/.test(idNumber)) {
		return "Your ID must be between 5 and 25 characters long, and only contain numbers and letters."
	}
	return null
}

/* ===================== payment ===================== */

/** The payment types Apex prices and branches on. */
export type PaymentType = "Stripe" | "Wire Transfer" | "ACH"

type PaymentCountry = {
	creditCardAllowed?: boolean | null
	wireAllowed?: boolean | null
	achAllowed?: boolean | null
} | null

/**
 * Which payment types the country permits.
 *
 * Before a country is chosen, wire and ACH stay open and only card is gated —
 * by the org-level Stripe switch — so the options are not all dead on first
 * paint, before the candidate has told us where they are.
 */
export function isPaymentAllowed(
	type: string,
	country: PaymentCountry,
	useStripe: boolean,
): boolean {
	if (!country) return type !== "Stripe" || useStripe
	if (type === "Stripe") return useStripe && country.creditCardAllowed === true
	if (type === "Wire Transfer") return country.wireAllowed === true
	if (type === "ACH") return country.achAllowed === true
	return false
}

/**
 * Preference order card → wire → ACH, keeping a still-valid current choice.
 *
 * Re-run whenever the billing country changes: the new country may not permit
 * what was already selected, and silently leaving an impossible payment type
 * in place would fail at submit rather than at the point of choosing.
 */
export function defaultPaymentType(
	country: PaymentCountry,
	useStripe: boolean,
	current: string,
): string {
	const order: PaymentType[] = ["Stripe", "Wire Transfer", "ACH"]
	if (current && isPaymentAllowed(current, country, useStripe)) return current
	return order.find((type) => isPaymentAllowed(type, country, useStripe)) ?? ""
}

/**
 * Address cards appear for the offline methods only.
 *
 * A card order collects its address on Stripe's own checkout page, so asking
 * for it here as well would be two chances to disagree. Wire and ACH never
 * reach Stripe, so finance needs the address from us.
 */
export function showAddresses(paymentType: string): boolean {
	return Boolean(paymentType) && paymentType !== "Stripe"
}

/** Wire and ACH carry a processing fee and are taxed locally by Apex. */
export function isOfflinePayment(paymentType: string): boolean {
	return paymentType === "Wire Transfer" || paymentType === "ACH"
}

/**
 * The auto-renew offer.
 *
 * Only for a card order — there is no saved payment method to renew against
 * otherwise — and only when the cart actually contains a complimentary
 * membership to renew. Someone who already has auto-renew on is not asked
 * again.
 */
export function showAutorenew(
	isAutoRenewEnabled: boolean | null | undefined,
	paymentType: string,
	hasCompMembership: boolean | null | undefined,
): boolean {
	return (
		isAutoRenewEnabled !== true &&
		paymentType === "Stripe" &&
		hasCompMembership === true
	)
}

/** A country tagged GDPR/CASL needs the policies ticked, not just implied. */
export function isComplianceCountry(
	countries: Array<{ countryCode: string; compliance?: boolean | null }>,
	countryCode: string,
): boolean {
	if (!countryCode) return false
	return countries.some(
		(country) =>
			country.countryCode === countryCode && country.compliance === true,
	)
}
