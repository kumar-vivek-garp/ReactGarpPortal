/**
 * Static config for the exam-setup wizard.
 *
 * Every option list here is transcribed from the legacy sfdcApp form
 * (`modules/exam-setup/components/exam-setup-*-id-info-card`), not guessed:
 * Apex supplies only `mobilePhoneLocations` and leaves the rest to the client,
 * so a wrong value here writes a picklist the org will not recognise.
 */

export const EXAM_SETUP_TITLE = "Exam setup"

/**
 * The provider push in `examSetupAuthorize` is an OUTBOUND INTEGRATION —
 * `ExamRegistrationsStatusCls.updateRegistration` talks to Pearson / PSI / ATA
 * for real, from whichever org runs it. Firing that from a sandbox pushes test
 * data at a live vendor.
 *
 * Off until the backend team confirms the sandbox path is safe. With it off the
 * outcome screen explains the position and links to MyGarp; nothing is called.
 * Turning it on is this one line.
 */
export const EXAM_SETUP_AUTHORIZE_ENABLED = false

/** How many times the outcome screen re-asks when the provider says "unprocessed". */
export const EXAM_SETUP_AUTHORIZE_MAX_RETRIES = 3

/* ===================== fee literals ===================== */

/**
 * Mirrors `GARP_Portal_ExamSetupFees`, which holds these as literals rather
 * than resolving a pricebook — there is nothing to look up, so the gate can
 * decide client-side before writing anything.
 *
 * Kept in sync by the tests in `exam-setup-presentation.test.ts`; if Apex ever
 * grows real pricing these move behind `examSetupFees` and the gate calls it.
 */
export const EXAM_SETUP_FEES = {
	/** Moving an FRM sitting. */
	frmDeferral: 250,
	/** Moving an SCR, RAIJ or Risk AI sitting. */
	singlePartDeferral: 150,
	/** Per exam part sat in mainland China. */
	ostaLocation: 40,
	/** One-off, charged when the account has no OSTA program yet. */
	ostaData: 10,
} as const

/* ===================== option lists ===================== */

/**
 * Only two, deliberately.
 *
 * `OSTA_ID_TYPES` in `config/osta` offers four, but the exam-setup form offers
 * exactly these — the test centre accepts nothing else as photo ID. Do not
 * substitute the OSTA list here.
 */
export const EXAM_SETUP_ID_TYPES = ["Passport", "Driver's License"] as const

export const EXAM_SETUP_ID_LOCATIONS = ["China", "Non-China"] as const

export const EXAM_SETUP_GENDERS = ["Male", "Female", "Other"] as const

export const EXAM_SETUP_WORKING_STATUSES = ["Working", "Not Working"] as const

export const EXAM_SETUP_SCHOOL_STATUSES = ["In School", "Not In School"] as const

/**
 * A passport number is nine characters, letters and digits only, and excludes
 * `I` and `O` because they are indistinguishable from `1` and `0` on a scanned
 * document. Transcribed from the legacy's own inline validation.
 *
 * No equivalent rule exists for a driver's licence — the legacy checks only
 * that something was entered.
 */
export const EXAM_SETUP_PASSPORT_PATTERN = /^[ABCDEFGHJKLMNPQRSTUVWXYZ0-9]{9}$/i
/**
 * Shown when a number is already stored.
 *
 * The read hands back only the last five characters, so the box starts empty
 * rather than showing a partial number the member might "correct" — and an
 * empty box means "keep what you have", not "erase it".
 */
export const EXAM_SETUP_ID_ON_FILE_HINT =
	"We already have your ID number on file. Leave this blank to keep it, or type the full number to replace it."

export const EXAM_SETUP_PASSPORT_HINT =
	"A passport number is 9 characters, letters and numbers only, and cannot contain I or O."

/* ===================== copy ===================== */

export const EXAM_SETUP_SECTIONS = {
	selection: {
		title: "Choose your sitting",
		description: "Pick the exam date and the location you want to sit at.",
	},
	identity: {
		title: "Confirm your ID",
		description:
			"The name and document you give here must match the photo ID you bring on exam day.",
	},
} as const

/**
 * Shown when both parts are at the same administration.
 *
 * The legacy raises this because candidates assume one booking means one
 * building. It does not, and arriving late to the second is not recoverable.
 */
export const EXAM_SETUP_SAME_DAY_WARNING =
	"Exam sites may not be at the same location. If you sit both parts on the same day, plan for travel between sites — late arrivals are not admitted."

/** The states the page can refuse in, keyed by the Apex status code. */
export const EXAM_SETUP_REFUSALS = {
	unsupported: {
		title: "Exam setup isn't available",
		message: "This programme doesn't use the exam setup wizard.",
	},
	pendingReschedule: {
		title: "You already have a reschedule in progress",
		message:
			"There's an unpaid reschedule order on your account. Settle or cancel it before starting another change.",
		ctaLabel: "View your orders",
	},
	noAdmins: {
		title: "No exam dates are open",
		message:
			"There are no exam administrations open to you right now. Check back when registration for the next sitting opens.",
	},
	unavailable: {
		title: "Exam setup isn't available",
		message:
			"We couldn't load your exam setup. Please try again, or contact Member Services if this continues.",
	},
} as const

export const EXAM_SETUP_OUTCOMES = {
	complete: {
		title: "Your exam setup is complete",
		message: "Nothing further is needed. We've saved your details.",
	},
	scheduling: {
		title: "Now book your seat",
		message:
			"Your registration has been sent to the exam provider. Use the link below to choose your date and time.",
		ctaLabel: "Schedule your exam",
	},
	schedulingDisabled: {
		title: "One more step, in MyGarp",
		message:
			"Your details are saved. Booking your seat with the exam provider isn't available here yet — finish in MyGarp.",
		ctaLabel: "Continue in MyGarp",
	},
	schedulingPending: {
		title: "Still processing",
		message:
			"The exam provider hasn't confirmed your registration yet. This usually clears within a few minutes.",
		ctaLabel: "Check again",
	},
} as const

/**
 * The fee gate.
 *
 * Not a payment screen — a stop. `examSetupFees` prices a change but returns no
 * order and no checkout URL, and `examSetupAuthorize` refuses any sitting whose
 * Opportunity is not already Closed. Nothing in the portal API raises that
 * Opportunity, so a member who paid here would have paid into nothing.
 *
 * Stopping BEFORE `examSetupId` matters: that call raises an
 * `Exam_Registration_Modification__c` as a side effect, and one left Pending
 * here would collide with the one MyGarp raises when they finish there.
 */
export const EXAM_SETUP_FEE_GATE = {
	title: "This change has a fee",
	message:
		"Changing your exam date moves your registration to a different administration, which carries a fee. Payment isn't available in this portal yet — you can complete the change in MyGarp.",
	ctaLabel: "Continue in MyGarp",
	resetLabel: "Keep my current date",
} as const
