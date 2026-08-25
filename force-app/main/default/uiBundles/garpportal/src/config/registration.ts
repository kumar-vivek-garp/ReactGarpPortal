import { z } from "zod"

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
/**
 * Heading copy for the FRM registration form.
 *
 * `programme` is GARP's own name for the certification, taken verbatim from the
 * production mega-menu (`config/navigation/top-nav-items.ts`) rather than
 * invented. It is shown to guests only: someone arriving from a marketing link
 * may know "FRM" purely as an acronym, whereas a signed-in member already has
 * the whole portal around them saying what it is.
 */
export const FRM_REGISTRATION_HEADING = {
	title: "Register for the FRM Exam",
	programme: "Financial Risk Manager (FRM\u00AE) Certification",
} as const

export const EXAM_REGISTRATION_COPY = {
	bothPartsAlert:
		"Exam centres may not be in the same location. If you sit both parts on the same day, plan for travel between centres — late arrivals cannot sit the exam.",
	ostaSiteNotice:
		"You can choose Simplified Chinese or American English as your exam language during scheduling, which happens after you register here.",
} as const

/** Payment options, in the order they are offered. */
export const PAYMENT_TILES = [
	{ value: "Stripe", label: "Card" },
	{ value: "Wire Transfer", label: "Wire transfer" },
	{ value: "ACH", label: "ACH" },
] as const

export const OFFLINE_PAYMENT_COPY = {
	instructions:
		"After you submit, we will email instructions for paying by wire or ACH. They also appear on your invoice and in your account.",
	/** Apex adds this as a PRFEE line, so the cart will show it too. */
	feeNotice: "A USD 50 fee applies to wire and ACH payments.",
	cardNotice: "You will be taken to our payment provider to complete checkout.",
	autoRenew:
		"Enrol in Membership Automatic Renewal: your complimentary GARP Individual Membership renews each year at the then-current rate using your saved payment method, until you cancel. You can cancel any time from your account.",
} as const

export const CANDIDATE_RESPONSIBILITY_URL =
	"https://www.garp.org/candidate-responsibility"

export const ACKNOWLEDGEMENT_COPY = {
	title: "Before you register",
	/** Apex refuses the whole registration unless both of these are ticked. */
	candidateResponsibility: "I have read and agree to the",
	candidateResponsibilityLink: "Candidate Responsibility Statement",
	examPolicy: "I have read and agree to the",
	examPolicyLink: "Exam Policies",
	complianceIntro:
		"Your location requires us to record these separately, so please confirm each one.",
	privacyNotice: "I have read GARP's Privacy Notice and Code of Conduct.",
	limitationOfLiability: "I have read GARP's Limitation of Liability.",
	releaseAndWaiver: "I have read GARP's Waiver and Release.",
	policiesRequired: "Please confirm you have read our policies.",
} as const

/** The China identity block. Shown only when an OSTA exam centre is chosen. */
export const OSTA_COPY = {
	title: "Identity details for your exam centre",
	intro:
		"Your chosen exam centre is in China, which requires GARP to hold these details and to share your ID with the authorities and our exam delivery partner on request.",
	consent:
		"I agree to GARP sharing my passport or driver's licence number as required by any Chinese governmental authority, and to sharing the last five digits with its exam delivery partner to verify my identity at the exam.",
} as const

export const EXAM_REGISTRATION_OUTCOMES = {
	registered: {
		title: "You're registered",
		message:
			"Your registration is confirmed and a confirmation email is on its way.",
	},
	invoiced: {
		title: "Your order has been submitted",
		message:
			"Payment instructions are on their way by email, and are also on your invoice and in your account.",
	},
	paid: {
		title: "Thank you — payment received",
		message:
			"Your payment is being processed and your registration is confirmed. A confirmation email is on its way.",
	},
	cancelled: {
		title: "Payment was not completed",
		message:
			"Your registration was cancelled and nothing has been charged. You can start again whenever you are ready.",
	},
} as const

/**
 * Where the public form points someone who has no account.
 *
 * A guest has no programmes listing and no dashboard to return to — both sit
 * behind the session guard, so linking them would bounce the visitor to Login
 * from a page deliberately built not to need one. The public site they arrived
 * from is the only honest destination.
 */
export const PUBLIC_REGISTRATION_EXIT = {
	href: "https://www.garp.org",
	label: "GARP.org",
} as const

/**
 * A search param that has to survive as a string.
 *
 * The router JSON-parses every search value before validation, so `?oid=8013`
 * or `?stripe_return=1` arrives as a **number**. A bare `z.string()` rejects
 * that, and the `.catch(undefined)` behind it then drops the param without a
 * trace — which is how a payment return quietly became a blank registration
 * form instead of a confirmation, for an order that had already been charged.
 *
 * Every param here can legitimately be all digits (an order number, a team
 * code), so each accepts both shapes and is coerced back to a string.
 */
const looseSearchString = () =>
	z
		.union([z.string(), z.number()])
		.optional()
		.catch(undefined)
		.transform((value) => (value === undefined ? undefined : String(value)))

/**
 * Search params the registration route accepts.
 *
 * `regCode` / `teamCode` are the query-string form of a code that can also
 * arrive as a path segment — legacy links use both shapes, so both resolve.
 *
 * `stripe_return` is the payment return leg. The checkout success URL is built
 * client-side from the current location, so the provider comes back to
 * whichever route served the form, carrying the order it settled.
 */
export const registrationSearchSchema = z.object({
	regCode: looseSearchString(),
	teamCode: looseSearchString(),
	stripe_return: looseSearchString(),
	oid: looseSearchString(),
	on: looseSearchString(),
})

export type RegistrationSearch = z.infer<typeof registrationSearchSchema>
