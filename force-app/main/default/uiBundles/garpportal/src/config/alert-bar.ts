import type { AlertRoute, AlertStatus } from "@/api/alert-bar"

/**
 * Static copy for the portal-wide exam alert.
 *
 * This lives here rather than inside the component on purpose. GarpAppv1 keeps
 * the same table welded into `AlertBar.tsx` alongside a `destinationFor`
 * switch, which makes every one of the eight statuses testable only by
 * rendering. Held as data, `toAlertBarModel` resolves them with no DOM.
 *
 * Copy is ours. The legacy buries the deadline in a sentence and says
 * "enrollment" throughout; the rules it describes are unchanged.
 */

/** How loud the banner is. Maps to the `Alert` atom's two variants. */
export type AlertTone = "urgent" | "notice"

type AlertCopy = {
	message: string
	tone: AlertTone
	/**
	 * Leads the date when one is present. Per-status rather than per-route,
	 * because the same route can carry very different deadlines — `Exam
	 * Registration` is a registration cut-off from one status and nothing at
	 * all from two others.
	 */
	deadlinePrefix: string
}

export const ALERT_BAR_COPY: Record<AlertStatus, AlertCopy> = {
	"Exam Unpaid": {
		message: "Your exam registration is not complete until its order is paid.",
		tone: "urgent",
		deadlinePrefix: "Pay by",
	},
	"Enrollment Expiring Soon": {
		message: "Your programme enrolment is coming to an end.",
		tone: "notice",
		deadlinePrefix: "Register by",
	},
	"CV Submission Expiring Soon": {
		message: "Submit your work experience to complete your certification.",
		tone: "notice",
		deadlinePrefix: "Submit by",
	},
	"Enrollment Expired": {
		message: "Your programme enrolment has expired.",
		tone: "urgent",
		deadlinePrefix: "Register by",
	},
	"Modification Order Pending": {
		message:
			"You have an unpaid exam change. It will not take effect until it is paid.",
		tone: "urgent",
		deadlinePrefix: "Pay by",
	},
	"Results Available": {
		message: "Your exam result is ready to view.",
		tone: "notice",
		deadlinePrefix: "Available until",
	},
	"Scheduling Incomplete": {
		message: "You have not booked a seat for your exam yet.",
		tone: "urgent",
		deadlinePrefix: "Book by",
	},
	"Scheduling Expired": {
		message: "The window to book a seat for that exam has closed.",
		tone: "urgent",
		deadlinePrefix: "Closed",
	},
}

/**
 * The call to action, keyed by route rather than by status.
 *
 * Five routes serve eight statuses — `Complete Payment` and `Exam
 * Registration` each cover more than one — and the label describes where the
 * member lands, which does not vary with the status that sent them there.
 */
export const ALERT_BAR_ACTION_LABEL: Record<AlertRoute, string> = {
	"Complete Payment": "Complete payment",
	"Exam Registration": "Register for an exam",
	"Submit CV": "Submit work experience",
	"Exam Detail": "View results",
	"Exam Scheduling": "Schedule your exam",
}

/** Shown on the toolbar trigger. Apex raises at most one alert portal-wide. */
export const ALERT_BAR_COLLAPSED_LABEL = "1 alert"
export const ALERT_BAR_COLLAPSE_LABEL = "Minimise alert"
/**
 * Contains the trigger's visible text on purpose: an accessible name that
 * drops it would leave voice control with no way to say the button's label
 * (WCAG 2.5.3).
 */
export const ALERT_BAR_EXPAND_LABEL = "Show 1 alert"
