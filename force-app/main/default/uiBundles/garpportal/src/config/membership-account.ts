/**
 * Static membership URLs and display rates — same as legacy UtilitiesService /
 * MembershipInfoCard. Not returned by Apex.
 */

/** Legacy `navigateToRegistrationWithCTA('membership', 'PortalMyAccountPage')`. */
export const MEMBERSHIP_REGISTRATION_URL =
	"/sfdcApp?track_cta=PortalMyAccountPage#!/registration/membership"

export const MEMBERSHIP_STRIPE_SETUP_PATH = "/stripe_checkout"

/**
 * Display-only Individual renewal amounts from garpApp (not from Apex).
 * Cert holders use MEMC ($150); everyone else MEMI ($195).
 */
export const AUTO_RENEW_USD_INDIVIDUAL = "195"
export const AUTO_RENEW_USD_CERT_HOLDER = "150"

export const AUTO_RENEW_SETUP_COMPLETE_STATUS = "autorenewsetupcomplete"

/** Matches garpApp: `/stripe_checkout?mode=setup&id=` + orderId. */
export function stripeSetupCheckoutUrl(orderId: string | null | undefined): string {
	return `${MEMBERSHIP_STRIPE_SETUP_PATH}?mode=setup&id=${orderId}`
}
