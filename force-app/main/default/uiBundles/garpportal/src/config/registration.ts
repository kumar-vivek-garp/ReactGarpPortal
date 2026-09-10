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
	/**
	 * The full document title, when `${abbrevName} Registration` is not it —
	 * "Membership Registration" is not what GarpAppv1 calls the page.
	 */
	documentTitle?: string
	/** Shown to guests under the title, never to members. */
	publicByLine: string
	examPolicyUrl: string
	/**
	 * The programme's Exam Prep Providers page, for the Exam Preparation
	 * Assistance card.
	 *
	 * Optional, and the card does not render without it — GARP only publishes
	 * one for FRM, SCR and RAI. Note the slugs genuinely differ: FRM and SCR use
	 * `exam-preparation-providers`, RAI uses `exam-prep-providers`. All three
	 * verified against the live site; do not "regularise" them.
	 */
	examPrepProvidersUrl?: string
}

/** The document title for a programme's registration page. */
export function registrationDocumentTitle(program: ExamProgramConfig): string {
	return program.documentTitle ?? `${program.abbrevName} Registration`
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
		examPrepProvidersUrl: "https://www.garp.org/frm/exam-preparation-providers",
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
		examPrepProvidersUrl: "https://www.garp.org/scr/exam-preparation-providers",
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
		examPrepProvidersUrl: "https://www.garp.org/rai/exam-prep-providers",
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

	/*
	 * Individual membership. Keyed by its URL slug (`/registration/membership`,
	 * GarpAppv1's and the legacy app's address) with the wire type `mem` that
	 * `GARP_ExamReg_Program__mdt` keys it by; `registration-programs` aliases
	 * the one to the other. `kind: "membership"` on the payload: no exam, no
	 * course, no attestations — the MEMI/MEMC line is the whole order, plus the
	 * Risk.net add-on. Not a certification, so no ®/™ and no mega-menu hue to
	 * borrow: `garp-cyan`, like the courses and the affiliate form.
	 *
	 * The byline is the upfront half of `mustSignIn`: the programme does not
	 * allow a member to register publicly, so a guest whose email belongs to a
	 * member is refused at submit — better said before anything is typed.
	 */
	membership: {
		registrationType: "mem",
		heading: {
			prefix: "",
			highlight: "Member",
			highlightToken: "garp-cyan",
			suffix: " Registration",
		},
		abbrevName: "Membership",
		documentTitle: "Member Registration",
		publicByLine:
			"Already a member? Sign in to renew against your existing record.",
		examPolicyUrl: "https://www.garp.org/membership",
	},
}

/**
 * The `?track_cta=` tags the portal's own membership links carry — GarpAppv1's
 * values, kept so attribution reads the same whichever app the sale came
 * through. Sent on `verifyCustomer` only; Apex writes
 * `Form_Data__c.Track_CTA__c`. The gated-content page has its own in
 * `config/gated-content`.
 */
export const REGISTRATION_TRACK_CTA = {
	myAccount: "PortalMyAccountPage",
	membershipPage: "PortalMembershipPage",
} as const

/**
 * The Risk.net add-on card, membership form only. Copy is GarpAppv1's — and
 * its "12 months" is literal there too: the PRICE tracks the member's
 * remaining cover, the sentence does not.
 */
export const RISK_NET_OFFER_COPY = {
	title: "Exclusive Offer for Members",
	optional: "(optional)",
	brand: "Risk.net",
	tagline: "GARP-Risk.net Content Hub — One Hub. Three Resources.",
	body: "Participating members will be given 12 months of online access to a content hub containing three resources: 80+ Books, nine Journals, and a hand-picked selection of in-depth news and analysis each week.",
	privacyIntro: "To learn more about how Risk.net will use your data, please refer to their",
	privacyLabel: "privacy policy",
	privacyUrl: "https://www.infopro-digital.com/privacy-policy/",
} as const

/**
 * Copy the membership form swaps in for the exam wording. The auto-renew
 * consent renews the membership being paid for — `OFFLINE_PAYMENT_COPY`'s
 * line says "complimentary", which is only true of the exam and course carts.
 */
export const MEMBERSHIP_REGISTRATION_COPY = {
	autoRenew:
		"Enrol in Membership Automatic Renewal: your GARP Individual Membership renews each year at the then-current rate using your saved payment method, until you cancel. You can cancel any time from your account.",
} as const

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
	/* Submit-time messages for the exam choice, which react-hook-form does not own. */
	choosePart: "Please choose an exam.",
	chooseSitting: "Please choose a sitting.",
	chooseSite: "Please choose where you will sit.",
	noSittingAvailable:
		"There is no exam sitting available to register for at the moment.",
	notPricedYet:
		"Your order has not been priced yet. Please try again in a moment.",
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

/**
 * The four confirmations the 2027 designs put on every registration.
 *
 * They replace the old split, where a GDPR/CASL country got three separate
 * attestations and everyone else got a single "by selecting Register you
 * agree…" line. Now everybody ticks the same four, which is both simpler and
 * strictly better consent — the implicit variant recorded agreement from
 * people who had never been shown the statements.
 */
export const ACKNOWLEDGEMENT_COPY = {
	title: "Candidate Acknowledgements",
	/** Apex refuses the whole registration unless both of these are ticked. */
	candidateResponsibility: "I confirm that I have read and agree to the",
	candidateResponsibilityLink: "Candidate Responsibility Statement",
	examPolicy: "I confirm that I have read and agree to the",
	examPolicyLink: "Exam Policies",
	policiesRequired: "Please confirm you have read our policies.",
	marketingEmails:
		"I agree to receiving emails from GARP and select third party providers with news, special offers, promotions and future messages that may be of interest to me.",
} as const

/**
 * The Exam Preparation Assistance card — an OPTIONAL opt-in to GARP passing
 * contact details to its third-party prep providers.
 *
 * Rendered only for a programme with an `examPrepProvidersUrl`, since the link
 * is the whole point of the card and GARP publishes that page for FRM, SCR and
 * RAI only.
 */
export const EXAM_PREP_COPY = {
	title: "Exam Preparation Assistance",
	optIn:
		"I agree to GARP sharing my contact information with its network of third-party Exam Preparation Providers.",
	linkIntro: "View a list of",
	/** `{abbrev}` is the programme code, e.g. "FRM Exam Preparation Providers". */
	linkLabel: "{abbrev} Exam Preparation Providers",
} as const

/** The complimentary membership a programme includes, and its renewal offer. */
export const COMP_MEMBERSHIP_COPY = {
	title: "Complimentary Membership",
	/**
	 * `{term}` comes from `compMembershipTerm` and carries its own "of", so the
	 * no-term case reads "unlocked complimentary Individual Membership".
	 */
	body: "By registering, you've unlocked {term} Individual Membership at no additional cost. Capitalize on this benefit by exploring premium content, discounted rates on products and services, priority registration for Chapter meetings, preferential rates at GARP events, and more.",
	/** Shown in place of the above when the membership is the purchase itself. */
	renewalOnlyTitle: "Automatic Renewal",
	autoRenewTitle: "Automatic Renewal",
	optional: "(optional)",
} as const

/** The China identity block. Shown only when an OSTA exam centre is chosen. */
export const OSTA_COPY = {
	title: "Identity details for your exam centre",
	intro:
		"Your chosen exam centre is in China, which requires GARP to hold these details and to share your ID with the authorities and our exam delivery partner on request.",
	consent:
		"I agree to GARP sharing my passport or driver's licence number as required by any Chinese governmental authority, and to sharing the last five digits with its exam delivery partner to verify my identity at the exam.",
} as const

/** The tone an outcome screen is drawn in — `RegistrationStatusPanel`'s set. */
export type RegistrationOutcomeTone = "muted" | "notice" | "error" | "success"

export type RegistrationOutcomeCopy = {
	title: string
	message: string
	tone: RegistrationOutcomeTone
}

/**
 * Every screen the exam form can end on. The payment-return leg's five come
 * from GarpAppv1's PaymentReturn sequence; the wording is ours.
 */
export const EXAM_REGISTRATION_OUTCOMES = {
	registered: {
		title: "You're registered",
		message:
			"Your registration is confirmed and a confirmation email is on its way.",
		tone: "success",
	},
	invoiced: {
		title: "Your order has been submitted",
		message:
			"Payment instructions are on their way by email, and are also on your invoice and in your account.",
		tone: "success",
	},
	/** The return leg while the provider's webhook is still being waited for. */
	confirming: {
		title: "Payment received",
		message: "Confirming your registration. This usually takes a few seconds.",
		tone: "notice",
	},
	/** Payment confirmed and the order exists. */
	paid: {
		title: "Thank you — payment received",
		message:
			"Your registration is confirmed and a confirmation email is on its way.",
		tone: "success",
	},
	/** Payment confirmed; the records are still being written (deferred flow). */
	finalising: {
		title: "Thank you — payment received",
		message:
			"Your payment is confirmed and your registration is being finalised. A confirmation email with your order details will follow shortly — there is nothing more you need to do.",
		tone: "success",
	},
	/** The status endpoint refused the id, or never saw the registration. */
	paymentIssue: {
		title: "There may have been an issue processing your payment",
		message:
			"Please wait for confirmation by email, try again later, or contact memberservices@garp.com for assistance.",
		tone: "error",
	},
	/** The card was declined. The staged registration is still payable. */
	paymentDeclined: {
		title: "There may have been an issue processing your payment",
		message:
			"You can try again, wait for confirmation by email, or contact memberservices@garp.com for assistance.",
		tone: "error",
	},
	/** Paid, but the registration did not survive — needs a human. */
	registrationFailed: {
		title: "We could not complete your registration",
		message:
			"Your payment went through, but we could not finish setting up your registration. Please contact memberservices@garp.com quoting your reference and we will put it right.",
		tone: "error",
	},
	cancelled: {
		title: "Payment was not completed",
		message:
			"Your registration was cancelled and nothing has been charged. You can start again whenever you are ready.",
		tone: "error",
	},
} as const satisfies Record<string, RegistrationOutcomeCopy>

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
 *
 * Exported for the event registration schema, which carries the same
 * all-digit-capable params (`oid`, `on`, `checkout_cancelled`).
 */
export const looseSearchString = () =>
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
 * whichever route served the form, carrying the order it settled (`oid`).
 * `on` is no longer sent — the status poll answers with the order number —
 * but is still accepted, for links already in flight.
 *
 * `checkout_cancelled` is the cancel leg, carrying the `oid` the rollback
 * depends on. `resume` is the deferred flow's staged id, appended by the
 * server to that same cancel URL: nothing was created, so the form is rebuilt
 * from the saved payload instead of rolled back.
 *
 * `track_cta` is the attribution tag the portal's own membership links carry
 * (`REGISTRATION_TRACK_CTA`); it rides `verifyCustomer` and nothing else.
 */
export const registrationSearchSchema = z.object({
	regCode: looseSearchString(),
	teamCode: looseSearchString(),
	stripe_return: looseSearchString(),
	oid: looseSearchString(),
	on: looseSearchString(),
	checkout_cancelled: looseSearchString(),
	resume: looseSearchString(),
	track_cta: looseSearchString(),
})

export type RegistrationSearch = z.infer<typeof registrationSearchSchema>
