import { z } from "zod"

import type { EventVariant } from "@/api/registration/event-types"
import { looseSearchString } from "@/config/registration"

/**
 * Search params the six event registration routes accept.
 *
 * No `regCode`/`teamCode` — events have no B2B or team pricing, and the
 * deployed GarpAppv1 accepts-and-ignores a path code; we accept nothing.
 *
 * `stripe_return` is the payment success leg; `checkout_cancelled` is the
 * cancel leg, and it matters that it carries `oid`: the abandoned order must
 * be rolled back, or its orphaned registration row reports `alreadyRegistered`
 * on the next load and locks the person out. Both legs suppress the guards'
 * redirects, because a bounce drops those params.
 */
export const eventRegistrationSearchSchema = z.object({
	stripe_return: looseSearchString(),
	oid: looseSearchString(),
	on: looseSearchString(),
	checkout_cancelled: looseSearchString(),
})

export type EventRegistrationSearch = z.infer<
	typeof eventRegistrationSearchSchema
>

/** Document titles per variant — `pageTitle(...)` wraps them with "| GARP". */
export const EVENT_REGISTRATION_TITLES: Record<EventVariant, string> = {
	event: "Event Registration",
	webcast: "Webcast Registration",
	chaptermeeting: "Chapter Meeting Registration",
}

export type EventRegistrationOutcomeKind =
	| "registered"
	| "paid"
	| "cancelled"
	| "declined"
	| "alreadyRegistered"

/**
 * Outcome copy, one entry per way a registration run can end.
 *
 * `declined` exists because GarpAppv1 reuses its "You're registered" screen
 * for an RSVP decline — a ported bug this table deliberately does not carry.
 * No watch/join link on any confirmation: the API returns none (backend gap
 * A13 in doc/tell_to_backend_dev.md).
 */
export const EVENT_REGISTRATION_OUTCOMES: Record<
	EventRegistrationOutcomeKind,
	{ title: string; message: string }
> = {
	registered: {
		title: "You're registered",
		message:
			"Your place is confirmed. A confirmation email is on its way to you.",
	},
	paid: {
		title: "Payment received",
		message:
			"Your registration is complete. A confirmation email is on its way to you.",
	},
	cancelled: {
		title: "Registration not completed",
		message:
			"The payment was cancelled, so nothing was charged and no place was held. You can start again whenever you like.",
	},
	declined: {
		title: "Thanks for letting us know",
		message: "We've recorded that you won't be attending.",
	},
	alreadyRegistered: {
		title: "You're already registered",
		message: "We have your place. There's nothing more to do here.",
	},
}

/** The hybrid-event attendance choices — values are what the Apex stores. */
export const EVENT_ATTENDANCE_OPTIONS = [
	{ value: "In-Person", label: "In person" },
	{ value: "Virtual", label: "Virtually" },
] as const
