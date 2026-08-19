import type { Identity } from "@/api/account/types"
import type { Benefit, PortalCard } from "@/api/membership/types"
import { formatLongDate } from "@/lib/account-format"
import { daysUntil } from "@/lib/days-until"
import type { StatusTone } from "@/lib/status-tone"

/** Keeps every card in a row a similar height without hiding content behind a scrollbar. */
const MAX_VISIBLE_BULLETS = 3

export type MembershipCtaLink = {
	label: string
	url: string
	isExternal: boolean
	newWindow: boolean
}

export type BenefitPresentation = {
	id: string
	title: string
	/** Paragraphs joined — the card clamps this, so structure is not needed. */
	body: string | null
	bullets: string[]
	/** How many bullets were trimmed, so the card can say so honestly. */
	hiddenBulletCount: number
	promoCode: string | null
	imageUrl: string | null
	locked: boolean
	statusLabel: string | null
	statusTone: StatusTone | null
	cta: MembershipCtaLink | null
}

export type MembershipHeroPresentation = {
	eyebrow: string | null
	badgeLabel: string | null
	body: string | null
	bullets: string[]
	cta: MembershipCtaLink | null
}

function cleanList(values: string[] | null | undefined): string[] {
	return (values ?? []).map((value) => value.trim()).filter(Boolean)
}

function ctaFrom(source: {
	ctaLabel: string | null
	ctaUrl: string | null
	ctaIsExternal: boolean
	opensInNewWindow?: boolean
}): MembershipCtaLink | null {
	const label = source.ctaLabel?.trim()
	const url = source.ctaUrl?.trim()
	if (!label || !url) return null
	return {
		label,
		url,
		isExternal: source.ctaIsExternal,
		newWindow: source.opensInNewWindow ?? false,
	}
}

/**
 * Maps one benefit into everything the card renders.
 *
 * Body copy is capped rather than scrolled: the card previously pinned itself to
 * a fixed height and hid the overflow behind a scrollbar-less scroll area, so
 * longer benefits silently lost their tail with no affordance saying so.
 */
export function buildBenefitPresentation(benefit: Benefit): BenefitPresentation {
	const paragraphs = cleanList(benefit.paragraphs)
	const allBullets = cleanList(benefit.bullets)
	const bullets = allBullets.slice(0, MAX_VISIBLE_BULLETS)

	return {
		id: benefit.id,
		title: benefit.title?.trim() || "Benefit",
		body: paragraphs.length > 0 ? paragraphs.join(" ") : null,
		bullets,
		hiddenBulletCount: allBullets.length - bullets.length,
		promoCode: benefit.promoCode?.trim() || null,
		imageUrl: benefit.imageUrl?.trim() || null,
		locked: benefit.locked,
		// `locked` is the flag that already gates access; it reads as information
		// rather than a problem, so it takes the info tone.
		statusLabel: benefit.locked ? "Members only" : null,
		statusTone: benefit.locked ? "info" : null,
		cta: ctaFrom(benefit),
	}
}

/**
 * Maps the membership hero card.
 *
 * `eyebrow`, `badge` and `bullets` all arrive in the payload and were previously
 * dropped — only `body` and the CTA were rendered.
 */
export function buildMembershipHeroPresentation(
	hero: PortalCard | null | undefined,
): MembershipHeroPresentation {
	if (!hero) {
		return { eyebrow: null, badgeLabel: null, body: null, bullets: [], cta: null }
	}
	return {
		eyebrow: hero.eyebrow?.trim() || null,
		badgeLabel: hero.badge?.trim() || null,
		body: hero.body?.trim() || null,
		bullets: cleanList(hero.bullets),
		cta: ctaFrom(hero),
	}
}

/** Sentence for the locked-benefit count, or null when nothing is locked. */
export function lockedBenefitsNotice(lockedCount: number): string | null {
	if (lockedCount <= 0) return null
	if (lockedCount === 1) {
		return "1 of the benefits below unlocks with Individual Membership."
	}
	return `${lockedCount} of the benefits below unlock with Individual Membership.`
}


/** Inside this window a membership expiry is worth flagging rather than dating. */
const RENEWAL_SOON_DAYS = 60

export type MembershipIdentityPresentation = {
	statusLabel: string | null
	statusTone: StatusTone | null
	/** "Member since August 2026", when Apex supplies the date. */
	memberSinceLabel: string | null
	/** Either a plain expiry date or a countdown once renewal is near. */
	expiryLabel: string | null
	expiryTone: StatusTone | null
	autoRenewLabel: string | null
}

/**
 * Maps membership identity into the hero facts.
 *
 * This reads `identity`, not the `hero` PortalCard — Apex returns `hero: null`
 * for this org, so anything keyed off that card renders nothing. `memberSince`
 * and `autoRenew` arrive here and were previously dropped.
 */
export function buildMembershipIdentityPresentation(
	identity: Identity,
): MembershipIdentityPresentation {
	const status = identity.membershipStatus?.trim() || null
	// Only "Active" is unambiguously good; anything else is worth a neutral chip
	// rather than a guess about severity.
	const statusTone: StatusTone | null = status
		? status.toLowerCase() === "active"
			? "success"
			: "neutral"
		: null

	const since = formatLongDate(identity.memberSince?.slice(0, 10))

	const expiryIso = identity.membershipExpiration?.slice(0, 10) ?? null
	const remaining = expiryIso ? daysUntil(expiryIso) : null
	const expiryDate = formatLongDate(expiryIso)

	let expiryLabel: string | null = expiryDate
		? `Renews ${expiryDate}`
		: null
	let expiryTone: StatusTone | null = null

	if (remaining !== null && remaining < 0) {
		expiryLabel = expiryDate ? `Expired ${expiryDate}` : "Membership expired"
		expiryTone = "danger"
	} else if (remaining !== null && remaining <= RENEWAL_SOON_DAYS) {
		expiryLabel =
			remaining === 0
				? "Expires today"
				: remaining === 1
					? "Expires tomorrow"
					: `Expires in ${remaining} days`
		expiryTone = "warning"
	}

	return {
		statusLabel: status,
		statusTone,
		memberSinceLabel: since ? `Member since ${since}` : null,
		expiryLabel,
		expiryTone,
		// Only worth saying when it is on — "off" is the state a renewal notice covers.
		autoRenewLabel: identity.autoRenew ? "Auto-renew on" : null,
	}
}
