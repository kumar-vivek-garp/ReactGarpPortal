/**
 * Static membership URLs and display rates — same as legacy UtilitiesService /
 * MembershipInfoCard. Not returned by Apex.
 */

import { REGISTRATION_TRACK_CTA } from "@/config/registration"
import { MEMBERSHIP_MEMBER_REGISTRATION_ROUTE } from "@/lib/registration-paths"

/**
 * The Individual membership form, for the My Account card's Upgrade and
 * Renew Now — the member twin, since anyone on this card has a session.
 * GarpAppv1's `navigateToRegistrationWithCTA('membership',
 * 'PortalMyAccountPage')`: the tag survives as `?track_cta=` so the sale is
 * attributed to this card.
 */
export const MEMBERSHIP_REGISTRATION_LINK = {
	to: MEMBERSHIP_MEMBER_REGISTRATION_ROUTE,
	search: { track_cta: REGISTRATION_TRACK_CTA.myAccount },
} as const

/**
 * Display-only Individual renewal amounts from garpApp (not from Apex).
 * Cert holders use MEMC ($150); everyone else MEMI ($195).
 */
export const AUTO_RENEW_USD_INDIVIDUAL = "195"
export const AUTO_RENEW_USD_CERT_HOLDER = "150"

export const AUTO_RENEW_SETUP_COMPLETE_STATUS = "autorenewsetupcomplete"

/**
 * Where Stripe sends the member back once a card is stored — the page that
 * started the flow, tagged so the card can say "saved" while the webhook
 * flips the contract. Same shape GarpAppv1 posts as `returnUrl`.
 */
export function buildAutoRenewReturnUrl(location: {
	origin: string
	pathname: string
}): string {
	return `${location.origin}${location.pathname}?status=${AUTO_RENEW_SETUP_COMPLETE_STATUS}`
}
