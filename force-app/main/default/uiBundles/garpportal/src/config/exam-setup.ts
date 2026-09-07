/**
 * Static config for the exam-setup wizard.
 *
 * The flow this drives mirrors GarpAppv1's `PortalExamSetup` — the app the
 * backend team built against the new REST API — so its three steps, its field
 * gating and its validation copy are the reference, not the older sfdcApp form.
 * Option lists that Apex does not serve are transcribed from that page.
 */

export const EXAM_SETUP_TITLE = "Exam setup"

/**
 * The provider push in `examSetupAuthorize` is an OUTBOUND INTEGRATION —
 * `ExamRegistrationsStatusCls.updateRegistration` talks to Pearson / PSI / ATA
 * for real, from whichever org runs it.
 *
 * ON since Sep 2026. It was held off on the theory that a sandbox should not
 * push at a live vendor, but GarpAppv1 — which drives the same action from the
 * same org — was observed calling it against `devjuly25a` in the ordinary
 * course, so the push is being incurred either way and holding it here only
 * made this app behave differently for no protection.
 *
 * Turning it back off is this one line, and the outcome screen still carries
 * the MyGarp hand-off for that case.
 */
export const EXAM_SETUP_AUTHORIZE_ENABLED = true

/**
 * How long to wait before the single authorisation retry.
 *
 * Authorisation reaches a third party and is not instant. The legacy asks once,
 * waits, and asks once more before giving up — one retry, not a poll.
 */
export const EXAM_SETUP_AUTH_RETRY_MS = 20000

/* ===================== option lists ===================== */

/**
 * The two documents the test centre accepts.
 *
 * Values are the lowercase strings the wire expects. Apex normalises anything
 * containing `driver` to `Driver's License` on write, and reads it back as
 * `Driver License` — `normalizeIdType` maps that reply onto these values so a
 * stored licence still selects its radio.
 */
export const EXAM_SETUP_ID_TYPES = [
	{ value: "passport", label: "Passport" },
	{ value: "driver license", label: "Driver's License" },
] as const

/**
 * The wizard offers two, where the registration form offers three.
 * Not an oversight: this is the set the reference implementation presents, and
 * it is what the exam provider's own record accepts.
 */
export const EXAM_SETUP_GENDERS = ["Male", "Female"] as const

/**
 * Picklist API names on `Contact`, served by `GET /memberportal/options`.
 *
 * Fetched rather than hardcoded: these are org picklists and a stale copy here
 * would write a value the org does not recognise.
 */
export const EXAM_SETUP_WORKING_STATUS_PICKLIST = "Currently_Working_Status__c"
export const EXAM_SETUP_SCHOOL_STATUS_PICKLIST = "Currently_in_School_Status__c"

/* ===================== copy ===================== */

export const EXAM_SETUP_SECTIONS = {
	sitting: {
		title: "Choose your sitting",
		description: "Pick the exam administration and the site you want to sit at.",
	},
	identity: {
		title: "Confirm your ID",
		description:
			"The name and document you give here must match the photo ID you bring on exam day.",
	},
	osta: {
		title: "Your exam centre needs a little more",
		description:
			"Mainland-China centres require these details before you can be scheduled.",
	},
} as const

/** The rail's second card — the flow, told before the member commits to it. */
export const EXAM_SETUP_NEXT_STEPS = {
	title: "What happens next",
	steps: [
		"We save your sitting and your ID details.",
		"If your exam date moved, a change fee applies — you'll pay it on the next screen.",
		"Then you book your seat with the exam provider.",
	],
} as const

export const EXAM_SETUP_RAIL_TITLE = "Your sitting"
export const EXAM_SETUP_SUBMIT_LABEL = "Save exam setup"

export const EXAM_SETUP_CONSENT_LABEL =
	"I agree to GARP sharing my driver's license or passport number, and the details below, with OSTA."

export const EXAM_SETUP_MOBILE_HINT =
	"We'll contact you at this number should we need to reach you about the exam."

export const EXAM_SETUP_NO_SITES_YET =
	"You'll choose your exam location once scheduling opens for this administration."

/** Validation copy, verbatim from GarpAppv1 so the two apps read alike. */
export const EXAM_SETUP_MESSAGES = {
	selectAdmin: "Choose when you plan to sit the exam.",
	selectAdminPart2: "Choose when you plan to sit Part II.",
	idName: "Name as it appears on your ID is required.",
	mobile: "A country code and mobile number are both required.",
	idType: "ID Type is required.",
	idNumber: "ID Number is required.",
	idNumberConfirm: "The two ID numbers do not match.",
	idExpireDate: "ID Expiration Date is required.",
	ostaIDLocation: "ID Location Issued is required.",
	ostaConsent: "You must agree before we can share your details with OSTA.",
	ostaFullNameInChinese: "Your name in Chinese is required.",
	ostaDateOfBirth: "Date of Birth is required.",
	ostaGender: "Gender is required.",
	ostaPhoneNumber: "Phone Number is required.",
	saveFailed: "Your exam setup could not be saved.",
} as const

/** The states the page can refuse in, keyed by the Apex status code. */
export const EXAM_SETUP_REFUSALS = {
	unsupported: {
		title: "Exam setup isn't available",
		message: "This program isn't open for exam setup.",
	},
	pendingReschedule: {
		title: "Exam setup isn't available",
		message: "You already have a pending exam reschedule.",
		ctaLabel: "View your orders",
	},
	noAdmins: {
		title: "Nothing to set up right now",
		message:
			"Scheduling isn't open for this program. Your program page shows when it opens.",
	},
	unavailable: {
		title: "We couldn't load exam setup",
		message:
			"Please try again, or contact Member Services if this continues.",
	},
} as const

export const EXAM_SETUP_OUTCOMES = {
	payFees: {
		title: "There's a fee for this change",
		message:
			"Your exam change is saved but not yet confirmed. Complete the payment to finish it.",
		ctaLabel: "Pay Fees",
		totalLabel: "Total",
	},
	authorising: {
		title: "Authorising your registration",
		message: "We're confirming your details with the exam provider. This can take a moment.",
	},
	authorized: {
		title: "Your exam setup was successful.",
		message:
			"Proceed to your exam provider to complete your exam scheduling.",
		ctaLabel: "Schedule Exam",
		ctaLabelPart1: "Schedule Exam Part I",
		ctaLabelPart2: "Schedule Exam Part II",
	},
	notCompleted: {
		title: "Your exam setup was not completed.",
		message:
			"Your authorisation has not yet completed. Please check your email for notifications, check back in 24 hours, or contact member services for more information.",
		ctaLabel: "Contact member services",
	},
	/**
	 * Only reachable with `EXAM_SETUP_AUTHORIZE_ENABLED` off, when the provider
	 * was never asked. The details are saved; only the seat booking is left.
	 */
	schedulingDisabled: {
		title: "One more step, in MyGarp",
		message:
			"Your details are saved. Booking your seat with the exam provider isn't available here yet — finish in MyGarp.",
		ctaLabel: "Continue in MyGarp",
	},
	complete: {
		title: "Thank you",
		message: "Your exam setup is complete.",
	},
} as const
