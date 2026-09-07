import type { AccountView, Completeness } from "@/api/account/types"
import type { AccountSection } from "@/config/account-sections"
import {
	AUTO_RENEW_USD_CERT_HOLDER,
	AUTO_RENEW_USD_INDIVIDUAL,
} from "@/config/membership-account"
import { formatLongDate, formatMoney } from "@/lib/account-format"
import type { MetaLine } from "@/lib/meta-line"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"
import type { StatusTone } from "@/lib/status-tone"

/**
 * Pure presentation builders for My Account — same split as
 * `program-listing-presentation.ts`: all the branching lives here so the cards
 * stay declarative and the same facts cannot be derived two different ways.
 */

/* -------------------------------------------------------------------------- */
/* Completeness                                                               */
/* -------------------------------------------------------------------------- */

/**
 * The eleven fields `GARP_Portal_Core.PROFILE_RULES` scores, keyed by the exact
 * `missing[]` label Apex emits. Every one of them is edited in the Career
 * Information dialog, so a missing chip can open that dialog focused on the
 * offending control rather than merely pointing at a card.
 */
export const CAREER_FOCUS_FIELDS = [
	"workStatus",
	"industry",
	"industryStartYear",
	"company",
	"professionalLevel",
	"jobFunction",
	"riskStartYear",
	"school",
	"degreeProgram",
	"graduationYear",
	"graduationMonth",
] as const

export type CareerFocusField = (typeof CAREER_FOCUS_FIELDS)[number]

const MISSING_LABEL_TO_FIELD: Record<string, CareerFocusField> = {
	"Employment status": "workStatus",
	"Area of concentration": "industry",
	"Years in the industry": "industryStartYear",
	"Current/last company": "company",
	"Professional level": "professionalLevel",
	"Job function": "jobFunction",
	"Years in risk management": "riskStartYear",
	"School name": "school",
	// Apex calls it "Highest degree"; the form control is `degreeProgram`.
	"Highest degree": "degreeProgram",
	"Expected graduation year": "graduationYear",
	"Expected graduation month": "graduationMonth",
}

export type MissingChip = {
	label: string
	/** Null when Apex emitted a label this build does not know — chip is inert. */
	field: CareerFocusField | null
	section: AccountSection | null
}

export function buildMissingChips(completeness: Completeness): MissingChip[] {
	return completeness.missing.map((label) => {
		const field = MISSING_LABEL_TO_FIELD[label] ?? null
		return { label, field, section: field ? "career" : null }
	})
}

/**
 * How many missing-field chips the hero shows before collapsing the rest behind
 * a "+N more" toggle.
 *
 * Apex scores eleven fields, and a new member is missing most of them. Eleven
 * chips wrap to four rows on a phone, pushing the cards below the fold — the
 * strip stops being a nudge and becomes the page (UI/UX request, Sep 2026).
 */
export const VISIBLE_MISSING_CHIPS = 4

export type MissingChipSplit = {
	visible: MissingChip[]
	/** 0 when everything is on screen — the toggle is not rendered. */
	hiddenCount: number
}

/**
 * Splits the chips into what is shown now and how many are held back.
 *
 * Collapsing a single chip is not worth it: "+1 more" occupies the row the
 * chip itself would have, so one over the cap is shown rather than hidden.
 */
export function splitMissingChips(
	chips: MissingChip[],
	expanded: boolean,
): MissingChipSplit {
	if (expanded || chips.length <= VISIBLE_MISSING_CHIPS + 1) {
		return { visible: chips, hiddenCount: 0 }
	}
	return {
		visible: chips.slice(0, VISIBLE_MISSING_CHIPS),
		hiddenCount: chips.length - VISIBLE_MISSING_CHIPS,
	}
}

/** How many missing items a given card owns. All eleven belong to Career. */
export function missingCountForSection(
	completeness: Completeness,
	section: AccountSection,
): number {
	if (section !== "career") return 0
	return completeness.missing.length
}

/* -------------------------------------------------------------------------- */
/* Identity hero                                                              */
/* -------------------------------------------------------------------------- */

export type IdentityPresentation = {
	displayName: string
	garpId: string | null
	memberType: string | null
	statusLabel: string | null
	statusTone: StatusTone
	autoRenewOn: boolean
	photoUrl: string | undefined
	metaLines: MetaLine[]
	percentComplete: number
	isComplete: boolean
}

export function buildIdentityPresentation(
	account: AccountView,
): IdentityPresentation {
	const { identity, personal, standing, completeness } = account

	const displayName =
		[personal.firstName, personal.lastName].filter(Boolean).join(" ").trim() ||
		identity.fullName?.trim() ||
		"Your profile"

	const memberType = standing?.memberType ?? identity.membershipType
	const memberStatus = standing?.memberStatus ?? identity.membershipStatus
	const isExpired = memberStatus === "Expired"
	const statusLabel =
		standing?.statusLabel ?? (isExpired ? "Lapsed" : identity.membershipStatus)
	const pendingOrderId = standing?.pendingOrderId ?? null
	const expiryLabel = formatLongDate(
		standing?.expirationDate ?? identity.membershipExpiration,
	)

	const metaLines: MetaLine[] = []
	if (personal.email) metaLines.push({ icon: "email", text: personal.email })
	if (personal.phone) metaLines.push({ icon: "phone", text: personal.phone })
	const memberSince = formatLongDate(identity.memberSince)
	if (memberSince) {
		metaLines.push({ icon: "memberSince", text: `Member since ${memberSince}` })
	}
	if (expiryLabel && !pendingOrderId) {
		metaLines.push({
			icon: "renews",
			text: isExpired
				? `Expired ${expiryLabel}`
				: `${standing?.isAutoRenewEnabled ?? identity.autoRenew ? "Renews" : "Expires"} ${expiryLabel}`,
		})
	}

	return {
		displayName,
		garpId: standing?.garpId ?? identity.garpId,
		memberType,
		statusLabel: pendingOrderId ? "Payment Pending" : statusLabel,
		statusTone: pendingOrderId ? "warning" : isExpired ? "danger" : "success",
		autoRenewOn: standing?.isAutoRenewEnabled ?? identity.autoRenew,
		photoUrl: resolvePortalAssetUrl(personal.photoUrl ?? identity.photoUrl),
		metaLines,
		percentComplete: completeness.percentComplete,
		isComplete: completeness.isComplete,
	}
}

/* -------------------------------------------------------------------------- */
/* Membership card                                                            */
/* -------------------------------------------------------------------------- */

const INDIVIDUAL_INTRO =
	"Your Individual Membership unlocks every Member benefit, the Member Directory, and preferential pricing on products and events."

const AFFILIATE_INTRO =
	"Upgrade to Individual Membership to get exclusive access to premium content and professional learning resources, special Career Center features, networking opportunities through our GARP Member Directory, and preferential pricing on products and events."

const EXPIRED_INTRO =
	"Renew your Individual Membership to get exclusive access to premium content and professional learning resources, special Career Center features, networking opportunities through our GARP Member Directory, and preferential pricing on products and events."

export type MembershipFooterAction =
	| "viewOrder"
	| "upgrade"
	| "disable"
	| "renewNow"
	| null

export type MembershipPresentation = {
	intro: string
	garpId: string | null
	memberType: string | null
	memberSince: string | null
	statusText: string | null
	statusTone: StatusTone
	expiryLabel: string | null
	isCertHolder: boolean
	renewAmount: string
	/** Opportunity Id when a membership order is unpaid — for `/my-account/orders/$orderNumber`. */
	pendingOrderId: string | null
	/** "Order X — $Y is waiting to be paid." Only with a pending order. */
	pendingOrderText: string | null
	showTurnOnCallout: boolean
	showOnCallout: boolean
	/** Back from Stripe with a card stored; the contract has not flipped yet. */
	showCardSaved: boolean
	/** The one footer action — GarpAppv1's rule: they are mutually exclusive. */
	action: MembershipFooterAction
}

function statusDisplay(options: {
	pendingOrderId: string | null
	statusLabel: string | null
	isLapsed: boolean
	expiryLabel: string | null
}): string | null {
	if (options.pendingOrderId) return "Payment Pending"
	if (!options.statusLabel) return null
	if (!options.expiryLabel) return options.statusLabel
	if (options.isLapsed) {
		return `${options.statusLabel} (expired ${options.expiryLabel})`
	}
	return `${options.statusLabel} (until ${options.expiryLabel})`
}

function pendingOrderDisplay(
	standing: AccountView["standing"],
): string | null {
	const id = standing?.pendingOrderId
	if (!id) return null
	const amount = formatMoney(standing?.pendingOrderAmount, "USD")
	const label = standing?.pendingOrderNumber ?? id
	return `Order ${label}${amount ? ` — ${amount}` : ""} is waiting to be paid.`
}

/**
 * The Membership card's state machine, ported from GarpAppv1's
 * `MembershipInfoCard`: two mutually exclusive auto-renew notices and one
 * footer action, keyed off member type, auto-renew, and whether an unpaid
 * membership order is outstanding.
 *
 * A PENDING ORDER OUTRANKS EVERYTHING. With one outstanding the status reads
 * "Payment Pending", both auto-renew notices are suppressed and the only
 * action is View Order — anything else would raise a second order for a
 * membership the member is already part-way through buying.
 *
 * One deliberate departure: while the "card saved" notice is up (back from
 * Stripe, webhook not landed) the Turn On invitation is hidden. GarpAppv1
 * shows both; offering to start a second Stripe session for the card that was
 * just stored is not something worth matching.
 */
export function buildMembershipPresentation(
	account: AccountView,
	autoRenewSetupComplete: boolean,
): MembershipPresentation {
	const { identity, standing } = account

	// `standing` (the Membership contract) wins over `identity` (the Contact)
	// everywhere; the identity values are the fallback when there is no contract.
	const memberType = standing?.memberType ?? identity.membershipType
	const isIndividual =
		memberType === "Individual" ||
		(standing == null && identity.isIndividualMember)
	const isAffiliate =
		memberType === "Affiliate" || (standing == null && identity.isAffiliateMember)
	const memberStatus = standing?.memberStatus ?? identity.membershipStatus
	// Anything not Activated — Expired, Cancelled — is Lapsed on the contract
	// label; the Contact's own "Expired" counts too (GarpAppv1's `isLapsed`).
	const isLapsed =
		standing?.statusLabel === "Lapsed" ||
		memberStatus === "Expired" ||
		identity.membershipStatus === "Expired"
	const autoRenew = standing?.isAutoRenewEnabled ?? identity.autoRenew
	const pendingOrderId = standing?.pendingOrderId ?? null
	const expiryLabel = formatLongDate(
		standing?.expirationDate ?? identity.membershipExpiration,
	)
	const statusLabel =
		standing?.statusLabel ?? (isLapsed ? "Lapsed" : identity.membershipStatus)
	const showCardSaved = autoRenewSetupComplete && !autoRenew

	const action: MembershipFooterAction = pendingOrderId
		? "viewOrder"
		: isAffiliate
			? "upgrade"
			: isIndividual && autoRenew
				? "disable"
				: isIndividual
					? "renewNow"
					: null

	return {
		intro: isAffiliate
			? AFFILIATE_INTRO
			: isLapsed
				? EXPIRED_INTRO
				: INDIVIDUAL_INTRO,
		garpId: standing?.garpId ?? identity.garpId,
		memberType,
		memberSince: formatLongDate(standing?.dateJoined ?? identity.memberSince),
		statusText: statusDisplay({
			pendingOrderId,
			statusLabel,
			isLapsed,
			expiryLabel,
		}),
		statusTone: pendingOrderId ? "warning" : isLapsed ? "danger" : "success",
		expiryLabel,
		isCertHolder: standing?.isCertHolder === true,
		renewAmount: standing?.isCertHolder
			? AUTO_RENEW_USD_CERT_HOLDER
			: AUTO_RENEW_USD_INDIVIDUAL,
		pendingOrderId,
		pendingOrderText: pendingOrderDisplay(standing),
		showTurnOnCallout:
			isIndividual && !pendingOrderId && !autoRenew && !isLapsed && !showCardSaved,
		showOnCallout: isIndividual && !pendingOrderId && autoRenew,
		showCardSaved,
		action,
	}
}
