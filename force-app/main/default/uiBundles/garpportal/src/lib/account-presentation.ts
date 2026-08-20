import type { AccountView, Completeness } from "@/api/account/types"
import type { AccountSection } from "@/config/account-sections"
import {
	AUTO_RENEW_USD_CERT_HOLDER,
	AUTO_RENEW_USD_INDIVIDUAL,
} from "@/config/membership-account"
import { formatLongDate } from "@/lib/account-format"
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

export type MembershipPresentation = {
	intro: string
	garpId: string | null
	memberType: string | null
	statusText: string | null
	statusTone: StatusTone
	expiryLabel: string | null
	renewAmount: string
	isAutoRenewPending: boolean
	showTurnOnCallout: boolean
	showOnCallout: boolean
	showUpgrade: boolean
	showViewOrder: boolean
	/** Opportunity Id when a membership order is unpaid — for `/my-account/orders/$orderNumber`. */
	pendingOrderId: string | null
	showDisable: boolean
	showRenewNow: boolean
}

function statusDisplay(options: {
	pendingOrderId: string | null
	statusLabel: string | null
	isExpired: boolean
	expiryLabel: string | null
}): string | null {
	if (options.pendingOrderId) return "Payment Pending"
	if (!options.statusLabel) return null
	if (!options.expiryLabel) return options.statusLabel
	if (options.isExpired) {
		return `${options.statusLabel} (expired ${options.expiryLabel})`
	}
	return `${options.statusLabel} (Until ${options.expiryLabel})`
}

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
	const isExpired = memberStatus === "Expired"
	const autoRenew = standing?.isAutoRenewEnabled ?? identity.autoRenew
	const pendingOrderId = standing?.pendingOrderId ?? null
	const expiryLabel = formatLongDate(
		standing?.expirationDate ?? identity.membershipExpiration,
	)
	const statusLabel =
		standing?.statusLabel ?? (isExpired ? "Lapsed" : identity.membershipStatus)
	const isAutoRenewPending = autoRenewSetupComplete && !autoRenew

	return {
		intro: isAffiliate
			? AFFILIATE_INTRO
			: isExpired
				? EXPIRED_INTRO
				: INDIVIDUAL_INTRO,
		garpId: standing?.garpId ?? identity.garpId,
		memberType,
		statusText: statusDisplay({
			pendingOrderId,
			statusLabel,
			isExpired,
			expiryLabel,
		}),
		statusTone: pendingOrderId ? "warning" : isExpired ? "danger" : "success",
		expiryLabel,
		renewAmount: standing?.isCertHolder
			? AUTO_RENEW_USD_CERT_HOLDER
			: AUTO_RENEW_USD_INDIVIDUAL,
		isAutoRenewPending,
		showTurnOnCallout:
			!isAutoRenewPending &&
			isIndividual &&
			!autoRenew &&
			!pendingOrderId &&
			!isExpired,
		showOnCallout: isIndividual && autoRenew && !pendingOrderId,
		showUpgrade: isAffiliate && !pendingOrderId,
		showViewOrder: Boolean(pendingOrderId),
		pendingOrderId,
		showDisable: isIndividual && autoRenew && !pendingOrderId,
		showRenewNow: isIndividual && !autoRenew && !pendingOrderId,
	}
}
