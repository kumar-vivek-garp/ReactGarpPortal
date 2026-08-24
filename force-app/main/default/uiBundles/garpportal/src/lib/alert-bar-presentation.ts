import type { AlertBarView, AlertRoute, AlertStatus } from "@/api/alert-bar"
import type { AlertTone } from "@/config/alert-bar"
import {
	ALERT_BAR_ACTION_LABEL,
	ALERT_BAR_COPY,
} from "@/config/alert-bar"
import { formatLongDate } from "@/lib/account-format"
import {
	programExamSetupHref,
	programOrderHref,
	programRegistrationHref,
	programResultsPath,
	programWorkExperiencePath,
} from "@/lib/program-card-links"

/**
 * Turns the one alert Apex returns into something a component can render
 * without deciding anything.
 *
 * The whole point of this module is that the banner holds no `switch`. Every
 * rung of the ladder, every route, and every degrade case resolves here, where
 * it can be tested with no DOM.
 */

export type AlertBarAction = {
	label: string
	href: string
	/** True when the href leaves the portal for MyGarp. */
	isExternal: boolean
}

export type AlertBarModel = {
	/** `FRM Part II`, `RAI`, or a fallback when Apex names no programme. */
	programme: string
	message: string
	/** `Book by 7 November 2026`, or null — four statuses carry no deadline. */
	deadlineLabel: string | null
	tone: AlertTone
	/** Null when the destination is unknown or unavailable to this member. */
	action: AlertBarAction | null
}

const FALLBACK_PROGRAMME = "Your exam"

/**
 * `FRM` + `II` -> `FRM Part II`; anything `Full` is just the programme.
 *
 * FRM is the only two-part programme, and it is also the only one Apex asks
 * about twice, so this is the only place a part ever appears.
 */
function programmeLabel(view: AlertBarView): string {
	const type = view.examType?.trim()
	if (!type) return FALLBACK_PROGRAMME
	const part = view.examPart?.trim()
	if (!part || part === "Full") return type
	return `${type} Part ${part}`
}

/**
 * Route -> destination.
 *
 * Every one of these delegates to `program-card-links`, which already owns the
 * `rai`/`riskai` slug handling and the MyGarp origin. Building a path here
 * would fork that, and the two that still leave the portal are exactly the two
 * that will become in-app routes later — going through the helpers means they
 * switch over for free.
 *
 * A helper returning `null` is not an error: `Submit CV` on a programme with no
 * CV requirement genuinely has nowhere to go. The caller drops the button and
 * keeps the message.
 */
function actionFor(view: AlertBarView): AlertBarAction | null {
	const route = view.route?.trim()
	if (!route) return null

	const label = ALERT_BAR_ACTION_LABEL[route as AlertRoute]
	if (!label) return null

	const programType = view.examType?.trim() ?? ""

	switch (route as AlertRoute) {
		case "Complete Payment": {
			// An Opportunity Id, which is what the order detail route resolves.
			const href = programOrderHref(view.orderId)
			return href ? { label, href, isExternal: false } : null
		}
		case "Submit CV": {
			const href = programWorkExperiencePath(programType)
			return href ? { label, href, isExternal: false } : null
		}
		case "Exam Detail": {
			const href = programResultsPath(programType)
			return href ? { label, href, isExternal: false } : null
		}
		case "Exam Scheduling": {
			// In-app since the exam-setup wizard landed. This is the alert the
			// legacy shows most — "You have not booked a seat for your exam yet."
			const href = programExamSetupHref(programType)
			return href ? { label, href, isExternal: false } : null
		}
		case "Exam Registration": {
			// The payload carries no registrationPath, so this derives from type.
			const href = programRegistrationHref(null, programType)
			return href ? { label, href, isExternal: true } : null
		}
		default:
			return null
	}
}

/**
 * The view model, or `null` when there is nothing to show.
 *
 * Unrecognised values degrade rather than throw, the same posture the
 * dashboard manifest takes. Apex owns this ladder and may grow a ninth rung
 * without us; a status we do not know renders its own raw text with no button,
 * which is worse than bespoke copy but far better than a blank page.
 */
export function toAlertBarModel(
	view: AlertBarView | null | undefined,
): AlertBarModel | null {
	const status = view?.alertStatus?.trim()
	if (!view || !status) return null

	const copy = ALERT_BAR_COPY[status as AlertStatus]
	const formatted = formatLongDate(view.deadline)

	return {
		programme: programmeLabel(view),
		message: copy?.message ?? status,
		deadlineLabel:
			formatted && copy ? `${copy.deadlinePrefix} ${formatted}` : formatted,
		tone: copy?.tone ?? "notice",
		action: actionFor(view),
	}
}
