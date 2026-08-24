import type { MemberPortalEnvelope } from "@/api/account/types"

/**
 * Types mirroring `GARP_Portal_AlertBarService`.
 *
 * The banner across the top of every portal page. It answers one question —
 * is there a single thing this member must do about an exam right now? — and
 * **at most one alert exists portal-wide**, not one per programme.
 *
 * Programmes are tried in a fixed order and the first that produces a status
 * wins: FRM (Part II before Part I) -> SCR -> RAIJ -> RiskAI. So there is
 * nothing to stack, sort or paginate here; the payload is one row or nothing.
 */

/**
 * The eight rungs of the ladder, in the order Apex tries them.
 *
 * `Modification Order Pending` is the odd one: it does not *win* the ladder,
 * it **overwrites** whatever the four above it decided, on the reasoning that
 * an unpaid deferral is the more urgent thing to say. Three of the eight
 * (`Enrollment Expiring Soon`, `CV Submission Expiring Soon`,
 * `Enrollment Expired`) are raised for FRM only.
 */
export type AlertStatus =
	| "Exam Unpaid"
	| "Enrollment Expiring Soon"
	| "CV Submission Expiring Soon"
	| "Enrollment Expired"
	| "Modification Order Pending"
	| "Results Available"
	| "Scheduling Incomplete"
	| "Scheduling Expired"

/**
 * Which call to action the banner offers.
 *
 * **A route names an intention, not a path.** The legacy's destination for the
 * same intention differs per programme, and ours differs again — two of these
 * still leave for MyGarp. Resolve them through `alert-bar-presentation`, never
 * by building a path at the call site.
 */
export type AlertRoute =
	| "Complete Payment"
	| "Exam Registration"
	| "Submit CV"
	| "Exam Detail"
	| "Exam Scheduling"

/**
 * `GET alertBar` — the whole payload.
 *
 * `alertStatus` and `route` are typed as the unions widened with `string`, on
 * purpose: Apex owns this ladder and may grow a ninth rung without us. Anything
 * unrecognised must degrade to plain text rather than throw — see
 * `toAlertBarModel`.
 */
export type AlertBarView = {
	statusMessage: string | null
	statusCode: number
	/** `FRM` | `SCR` | `RAIJ` | `RAI` — RiskAI is relabelled `RAI` on the way out. */
	examType: string | null
	/** `I` | `II` for FRM, `Full` for everything else. */
	examPart: string | null
	alertStatus: AlertStatus | (string & {}) | null
	/** ISO date (yyyy-MM-dd), or null — four of the eight statuses carry none. */
	deadline: string | null
	/** An **Opportunity** Id, set only by the two `Complete Payment` statuses. */
	orderId: string | null
	route: AlertRoute | (string & {}) | null
}

export type { MemberPortalEnvelope }
