/** Static copy and policy links for the public registration forms. */

export const AFFILIATE_REGISTRATION = {
	title: "Affiliate Membership",
	/** Ported from the legacy affiliate card's own wording. */
	byline:
		"Get easy access to future events and stay informed with news updates, risk insights, industry-sponsored webcasts and more. Become an Affiliate GARP Member today — for free.",
	submitLabel: "Register",
} as const

export const POLICY_LINKS = {
	privacyNotice: "https://www.garp.org/privacy-notice",
	codeOfConduct: "https://www.garp.org/code-of-conduct",
	limitationOfLiability: "https://www.garp.org/limitation-of-liability",
	releaseAndWaiver: "https://www.garp.org/release-and-waiver-policy",
} as const

/** Field limits, matching the Contact fields the registration writes to. */
export const REGISTRATION_LIMITS = {
	emailMaxLength: 80,
	nameMinLength: 2,
	nameMaxLength: 40,
} as const

export const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

/** 7–15 digits, matching GarpAppv1's `PHONE_RE`. */
export const PHONE_PATTERN = /^[0-9]{7,15}$/

/** The two SMS notices GarpAppv1 renders under the mobile number. */
export const SMS_COPY = {
	notice:
		"By providing your mobile number, you agree that GARP may send you important, time-sensitive text messages (SMS) regarding your scheduled exam, including exam location changes or cancellations. Message and data rates may apply. Reply STOP to opt out. Text HELP for assistance.",
	promotionalHeading: "Promotional SMS Messages",
	promotionalOptIn:
		"I agree to receive occasional promotional text messages (SMS) from GARP about risk education programs, membership, and events. Message frequency varies. Message and data rates may apply. Reply STOP to opt out. Text HELP for assistance.",
} as const

/**
 * The legacy `englishNameValidation` directive, ported verbatim as the
 * rejection test it is: doubled hyphens, doubled whitespace, doubled
 * apostrophes, or any character outside letters, hyphen, space and apostrophe.
 *
 * Kept as a reject-pattern rather than rewritten as an allow-pattern because
 * the doubling rules cannot be expressed as a character class, and because it
 * is the rule the legacy form enforced on the same two fields — a name this
 * accepts where the legacy refused would diverge silently.
 */
const NON_ENGLISH_NAME = /-{2,}|\s{2,}|'{2,}|[^a-z\-\s']/i

export function isEnglishName(value: string): boolean {
	return !NON_ENGLISH_NAME.test(value)
}

/* ===================== exam registration ===================== */

/** Notices the exam form shows in specific situations. */
export const EXAM_REGISTRATION_COPY = {
	bothPartsAlert:
		"Exam centres may not be in the same location. If you sit both parts on the same day, plan for travel between centres — late arrivals cannot sit the exam.",
	ostaSiteNotice:
		"You can choose Simplified Chinese or American English as your exam language during scheduling, which happens after you register here.",
} as const
