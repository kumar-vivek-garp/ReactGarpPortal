import type {
	EventCountry,
	EventRates,
	EventRegistrationLoad,
	EventVariant,
	EventView,
} from "@/api/registration/event-types"

/**
 * Every rule that decides what the event registration screens show, pure and
 * tested. A rule buried in JSX cannot be tested and gets re-derived slightly
 * differently by the next form — this file is the single copy.
 *
 * The behaviors here are the PORTED GarpAppv1 contract (which sections exist,
 * for which variant, gated on which flags), with its verified client bugs
 * fixed: the country required-flags are honored, the webcast postal code is
 * actually validated as digits, and a decline gets its own screen.
 */

export type EventRegistrationScreen =
	| "notFound"
	| "alreadyRegistered"
	| "notEligible"
	| "rsvpGate"
	| "form"

/**
 * Which screen the panel shows, in the ported precedence: a missing record
 * beats everything; an existing registration beats eligibility (there is
 * nothing to fix); refusal beats the RSVP gate; and an invite-only event keeps
 * its form behind the gate until Accept flips `rsvpAccepted` client-side.
 */
export function resolveEventScreen(
	load: Pick<EventRegistrationLoad, "event_x" | "alreadyRegistered" | "eligibility">,
	options: { rsvpAccepted: boolean },
): EventRegistrationScreen {
	if (!load.event_x) return "notFound"
	if (load.alreadyRegistered) return "alreadyRegistered"
	if (load.eligibility.isEligible === false) return "notEligible"
	if (load.event_x.isInviteOnly && !options.rsvpAccepted) return "rsvpGate"
	return "form"
}

/** Capacity flips the accept action into a waitlist join, nothing else. */
export function rsvpAcceptLabel(maxCapacityMet: boolean): string {
	return maxCapacityMet ? "Join the Waitlist" : "Accept"
}

export function rsvpGateCopy(
	event: Pick<EventView, "maxCapacityMet" | "rsvpCopy" | "rsvpWaitlistCopy">,
): string {
	if (event.maxCapacityMet) {
		return (
			event.rsvpWaitlistCopy?.trim() ||
			event.rsvpCopy?.trim() ||
			"This event is at capacity. Accept to join the waitlist, and we will let you know if a place opens up."
		)
	}
	return (
		event.rsvpCopy?.trim() ||
		"This event is by invitation. Let us know whether you will attend."
	)
}

/**
 * Job title and company. Chapter meetings ask only when the chapter requires
 * it; the other kinds always ask (both fields stay optional either way).
 */
export function showProfessionalFields(
	variant: EventVariant,
	event: Pick<EventView, "professionalDetailsRequired">,
): boolean {
	return variant !== "chaptermeeting" || event.professionalDetailsRequired
}

export function showAttendanceSelect(event: Pick<EventView, "isHybrid">): boolean {
	return event.isHybrid
}

/**
 * Only a webcast asks for a location — its registration object carries the
 * address fields. Deliberately keyed on the variant, not `hideAddressFields`:
 * the deployed client does the same and the flag is not consumed anywhere.
 */
export function showAddressCard(variant: EventVariant): boolean {
	return variant === "webcast"
}

export function showActivityCard(
	variant: EventVariant,
	event: Pick<EventView, "rsvpActivityName">,
): boolean {
	return variant === "event" && Boolean(event.rsvpActivityName?.trim())
}

export function showDietary(
	event: Pick<EventView, "rsvpActivityAskDiet">,
): boolean {
	return event.rsvpActivityAskDiet
}

export function showActivityQuestion(
	event: Pick<EventView, "rsvpActivityQuestion">,
): boolean {
	return Boolean(event.rsvpActivityQuestion?.trim())
}

export function showQuestionCard(
	variant: EventVariant,
	event: Pick<EventView, "eventQuestionTitle">,
): boolean {
	return variant === "event" && Boolean(event.eventQuestionTitle?.trim())
}

/** The legacy shows Valuable Content OR the sponsor consent — never both. */
export function consentKind(
	event: Pick<EventView, "isSponsored">,
): "sponsor" | "garp" {
	return event.isSponsored ? "sponsor" : "garp"
}

/**
 * `Webcast_Registration__c.Zip_Code__c` is a Salesforce NUMBER field — a
 * letter-bearing postcode cannot be stored. The deployed client only labels
 * this; we enforce it.
 */
export const POSTAL_DIGITS_PATTERN = /^[0-9]+$/

export function isPostalCodeRequired(
	country: Pick<EventCountry, "postalCodeRequired"> | null | undefined,
): boolean {
	return country?.postalCodeRequired === true
}

export function isProvinceRequired(
	country: Pick<EventCountry, "provinceRequired"> | null | undefined,
): boolean {
	return country?.provinceRequired === true
}

/**
 * GDPR handling is on when either the event says so or the selected billing
 * country is a compliance country. Event and chapter forms carry no country
 * field, so for them the event flag decides alone.
 */
export function resolveIsGdpr(
	country: Pick<EventCountry, "compliance"> | null | undefined,
	event: Pick<EventView, "isGdprEvent">,
): boolean {
	return country?.compliance === true || event.isGdprEvent
}

/**
 * The rail's date and time lines, rendered in the event's own published zone
 * (re-basing to the browser's locale would disagree with everywhere else GARP
 * advertises the event). Either line is null when its parts don't parse — a
 * missing line beats a wrong one.
 */
export function eventWhenLabels(
	event: Pick<EventView, "startDate" | "endDate" | "timeZone">,
): { dateLabel: string | null; timeLabel: string | null } {
	const start = event.startDate ? new Date(event.startDate) : null
	if (!start || Number.isNaN(start.getTime())) {
		return { dateLabel: null, timeLabel: null }
	}
	const end = event.endDate ? new Date(event.endDate) : null
	const hasEnd = Boolean(end && !Number.isNaN(end.getTime()))
	const timeZone = event.timeZone ?? undefined

	try {
		const dateFmt = new Intl.DateTimeFormat(undefined, {
			year: "numeric",
			month: "long",
			day: "numeric",
			timeZone,
		})
		const sameDay = !hasEnd || dateFmt.format(start) === dateFmt.format(end!)
		const dateLabel = sameDay
			? dateFmt.format(start)
			: dateFmt.formatRange(start, end!)

		const timeFmt = new Intl.DateTimeFormat(undefined, {
			hour: "numeric",
			minute: "2-digit",
			timeZone,
			timeZoneName: "short",
		})
		// A time range only reads within one day; across days the date line
		// already carries the span, so the start time alone is honest.
		const timeLabel =
			sameDay && hasEnd && end!.getTime() > start.getTime()
				? timeFmt.formatRange(start, end!)
				: timeFmt.format(start)

		return { dateLabel, timeLabel }
	} catch {
		return { dateLabel: null, timeLabel: null }
	}
}

export function submitLabel(amountDue: number): string {
	return amountDue > 0 ? "Continue to Payment" : "Complete Registration"
}

export function showFeeLine(rates: Pick<EventRates, "amountDue"> | null): boolean {
	return (rates?.amountDue ?? 0) > 0
}
