import { LockKeyhole } from "lucide-react"

/**
 * Static config for the members-only content paywall (`/content`).
 *
 * A member clicks a gated article on garp.org; that site drops the cookie below
 * and sends them here. This is the only page in the portal whose job is to
 * convert.
 */

/** Set by garp.org on the parent domain, carrying the article they wanted. */
export const GATED_URL_COOKIE = "garp_gated_url"

/** The domain the cookie is set on, and so the one it must be cleared on. */
export const GATED_COOKIE_DOMAIN = "garp.org"

/**
 * Hosts a gated URL may point at.
 *
 * The cookie is attacker-writable in principle, and this page's whole job is to
 * send a signed-in member somewhere — so an unvalidated value is an open
 * redirect aimed at exactly the moment a member is expecting to be forwarded.
 * Matched as an exact host or a subdomain, over https only.
 */
export const GATED_ALLOWED_HOSTS = ["garp.org"] as const

/** Attribution tag, so this upsell is distinguishable from the others. */
export const GATED_TRACK_CTA = "PortalGatedContent"

/** Membership purchase still lives in the legacy app. */
export const GATED_MEMBERSHIP_URL =
	"/sfdcApp?track_cta=" + GATED_TRACK_CTA + "#!/registration/membership"

export const GATED_CONTENT_TITLE = "GARP Content"

export const GATED_CONTENT_COPY = {
	allowed: {
		body: "Your membership gives you access to this content.",
		cta: "Continue to your content",
	},
	refused: {
		body: "This content is for members in good standing.",
		renew: "Renew your membership",
		upgrade: "Upgrade your membership",
	},
	expired: {
		icon: LockKeyhole,
		title: "This link has expired",
		body: "Please return to the GARP website and open the article again.",
		cta: "Back to garp.org",
		href: "https://www.garp.org",
	},
} as const
