import { z } from "zod"
import type { MegaMenuHeading } from "@/config/navigation/types"

/** Static copy and policy links for the public registration forms. */

export const AFFILIATE_REGISTRATION = {
	title: "Affiliate Membership",
	/** Ported from the legacy affiliate card's own wording. */
	byline:
		"Get easy access to future events and stay informed with news updates, risk insights, industry-sponsored webcasts and more. Become an Affiliate GARP Member today — for free.",
	submitLabel: "Register",
} as const

/**
 * The Affiliate form's title, and the word inside it that carries the tint.
 *
 * Deliberately *not* a `MegaMenuHeading` like the exam programmes' headings: that
 * shape requires a registered-symbol acronym (`®`/`™`), and Affiliate
 * membership is a membership tier, not a certification — it has neither. It is
 * rendered with the same typography and the same brand token so the two forms'
 * header bars still read as one family.
 */
export const AFFILIATE_REGISTRATION_HEADING = {
	highlight: "Affiliate",
	suffix: " Membership Registration",
} as const

/** The document title, and the h1, read the same. */
export const AFFILIATE_REGISTRATION_TITLE =
	`${AFFILIATE_REGISTRATION_HEADING.highlight}${AFFILIATE_REGISTRATION_HEADING.suffix}` as const

/**
 * What the rail lists as included.
 *
 * Unpacked from `AFFILIATE_REGISTRATION.byline` — the same promise the legacy
 * card made in one paragraph, split so the rail can list it the way the exam
 * rail lists a cart. Nothing here carries a price: the affiliate programme's
 * only order line is AFREE, a zero-price product, which is why the summary
 * below it is a fixed "Free" rather than a figure that has to be fetched.
 */
export const AFFILIATE_BENEFITS = [
	"Invitations to future GARP events",
	"News updates and risk insights",
	"Industry-sponsored webcasts",
	"A GARP ID, so you can register for any GARP programme",
] as const

/** Shown in place of the form once the membership exists. */
export const AFFILIATE_REGISTRATION_OUTCOME = {
	title: "You\u2019re an Affiliate Member",
	message:
		"Your Affiliate membership is active. Check your inbox for the welcome email with your GARP ID.",
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

/**
 * The exam registration form, per programme.
 *
 * One dynamic route and one form serve every exam programme — the server
 * resolves the sittings, sites, materials and prices from the `type` on the
 * wire. These are the only values it does not send: the page's own title, the
 * line shown to guests, and where the exam policies live. Ported from
 * GarpAppv1's `programConfig.ts`, which is the same shape for the same reason.
 *
 * Headings follow the production mega-menu (`config/navigation/top-nav-items`)
 * rather than inventing wording, so they render through the same
 * `MegaMenuHeadingText` component and the tinted acronym matches the nav
 * exactly. RAIJ has no mega-menu entry — it is the Japanese sitting of the
 * same certification, so it borrows RAI's `rai-split` treatment.
 */
export type ExamProgramConfig = {
	/** The `type` the registration module expects — the canonical slug. */
	registrationType: string
	heading: MegaMenuHeading
	/** Short name for the document title. */
	abbrevName: string
	/** Shown to guests under the title, never to members. */
	publicByLine: string
	examPolicyUrl: string
}

export const EXAM_PROGRAMS: Record<string, ExamProgramConfig> = {
	frm: {
		registrationType: "frm",
		heading: {
			prefix: "Financial Risk Manager (",
			highlight: "FRM",
			highlightToken: "garp-cyan",
			symbol: "®",
			suffix: ") Exam Registration",
		},
		abbrevName: "FRM Exam",
		/*
		 * FRM's warns about Part II because a returning candidate's Part I
		 * record lives on an account they have to be signed into. It is the
		 * upfront half of the same conversation the server has at submit via
		 * `mustSignIn`; saying it before the form is filled in is the whole
		 * point, because signing in does not preserve what was typed.
		 */
		publicByLine:
			"Returning candidates registering for the FRM Part II Exam must sign in to continue with registration.",
		examPolicyUrl: "https://www.garp.org/frm/exam-policies",
	},
	scr: {
		registrationType: "scr",
		heading: {
			prefix: "Sustainability and Climate Risk (",
			highlight: "SCR",
			highlightToken: "garp-saffron",
			symbol: "®",
			suffix: ") Exam Registration",
		},
		abbrevName: "SCR Exam",
		/*
		 * SCR's advertises the member rate rather than warning about a part.
		 * Signing in genuinely reprices it: `courseRateType` picks the
		 * `Exam_Rate__c` by the caller's standing, so a member is offered a
		 * different rate record, not a discount line.
		 */
		publicByLine:
			"A Certified FRM® / ERP® / RAI™ Holder or individual member may sign in for a discounted rate.",
		examPolicyUrl: "https://www.garp.org/scr/exam-policies",
	},
	riskai: {
		registrationType: "riskai",
		heading: {
			prefix: "Risk and AI (",
			highlight: "RAI",
			highlightToken: "rai-split",
			symbol: "™",
			suffix: ") Exam Registration",
		},
		abbrevName: "RAI Exam",
		publicByLine:
			"A Certified FRM® / ERP® / SCR™ Holder or individual member may sign in for a discounted rate.",
		/*
		 * Deliberately NOT GarpAppv1's value. Its `riskai` entry points at
		 * `/scr/exam-policies` — the line above it in its own config, so a
		 * copy-paste. `/rai/exam-policies` was checked and serves 200, which
		 * makes sending Risk AI candidates to SCR's policies a defect worth
		 * not porting.
		 */
		examPolicyUrl: "https://www.garp.org/rai/exam-policies",
	},
	raij: {
		registrationType: "raij",
		heading: {
			prefix: "リスクとAI (",
			highlight: "RAI",
			highlightToken: "rai-split",
			symbol: "™",
			suffix: ") 日本語試験登録",
		},
		abbrevName: "RAIJ Exam",
		publicByLine:
			"認定FRM® / ERP® / SCR™ 保有者または個人会員は、割引料金で登録できます。",
		/*
		 * Also not GarpAppv1's value: its `/raij/exam-policies` was checked and
		 * serves 404, as does `/raij` itself. RAIJ is the Japanese sitting of
		 * the same Risk AI certification, so its policies are RAI's.
		 */
		examPolicyUrl: "https://www.garp.org/rai/exam-policies",
	},

	/*
	 * The courses. `kind: "course"` on the payload, so these render without an
	 * exam card, without OSTA and without the candidate acknowledgements — see
	 * `isExamKind` in `lib/registration-presentation`. Neither has a mega-menu
	 * entry to borrow a hue from, so both take `garp-cyan`, the same choice the
	 * Affiliate form already made for a non-certification title.
	 *
	 * The byline is one line shared by all three in GarpAppv1, and it is a
	 * literal promise the server keeps: `courseRateType` picks the member rate
	 * record for a signed-in member in good standing.
	 */
	frr25: {
		registrationType: "frr25",
		heading: {
			prefix: "Financial Risk and Regulation 2025 (",
			highlight: "FRR25",
			highlightToken: "garp-cyan",
			// No ®. The dated course is not a registered mark, unlike `frr`.
			suffix: ") Course Registration",
		},
		/* The portal catalogue's own label for this programme is "FRR Series". */
		abbrevName: "FRR Series",
		publicByLine:
			"Individual members may sign in for a discounted rate. Become an individual member and access the discount by adding membership to your cart below.",
		examPolicyUrl: "https://www.garp.org/frr",
	},
	ffr: {
		registrationType: "ffr",
		heading: {
			prefix: "Foundations of Financial Risk (",
			highlight: "FFR",
			highlightToken: "garp-cyan",
			symbol: "®",
			suffix: ") Course Registration",
		},
		abbrevName: "FFR Course",
		publicByLine:
			"Individual members may sign in for a discounted rate. Become an individual member and access the discount by adding membership to your cart below.",
		examPolicyUrl: "https://www.garp.org/ffr",
	},
	/*
	 * The retired 2019 course. The org answers its load with
	 * `isEligible: false — "This program is not currently available"`, so this
	 * entry exists only so that sentence is what a stale link reaches, rather
	 * than the dispatcher's generic "will be built here" placeholder.
	 */
	frr: {
		registrationType: "frr",
		heading: {
			prefix: "Financial Risk and Regulation (",
			highlight: "FRR",
			highlightToken: "garp-cyan",
			symbol: "®",
			suffix: ") Course Registration",
		},
		abbrevName: "FRR Course",
		publicByLine:
			"Individual members may sign in for a discounted rate. Become an individual member and access the discount by adding membership to your cart below.",
		examPolicyUrl: "https://www.garp.org/frr",
	},
}

/** Notices the exam form shows in specific situations. */
/**
 * The course membership upsell.
 *
 * Ported from GarpAppv1's `MembershipCard`, minus its "Join today and save USD
 * X" line — see `membership-offer-section.tsx` for why that number is not
 * repeated here.
 */
export const MEMBERSHIP_OFFER_COPY = {
	title: "Membership",
	optional: "(optional)",
	body: "Connect with the world's largest community of risk professionals. GARP supports members at every stage of their careers with premium content, discounted rates on products and services, complimentary Chapter meetings and preferential rates at GARP events.",
	term: "for one year",
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
