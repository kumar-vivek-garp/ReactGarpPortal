import {
	EXAMREG_UNREACHABLE,
	examregFetch,
} from "@/api/registration/examreg-fetch"
import type {
	EventOptions,
	EventRegisterRequest,
	EventRegisterResult,
	EventRegistrationLoad,
	EventVariant,
} from "@/api/registration/event-types"
import { plainTextEventView } from "@/lib/event-view-text"

/**
 * Event / webcast / chapter-meeting registration endpoints.
 *
 * All under the same Apex `examreg` module as the exam forms, so the shared
 * transport — guest probe and CSRF fallback included — is reused untouched.
 * The variant rides in the query string, never the body: the body must stay
 * exactly the DTO Apex deserializes, which throws on any undeclared field.
 */

/** `eventType` is omitted for plain events — the Apex default. */
function eventPath(
	action: string,
	variant: EventVariant,
	params: Record<string, string> = {},
): string {
	const query = new URLSearchParams(params)
	if (variant !== "event") query.set("eventType", variant)
	const qs = query.toString()
	return qs ? `/event/${action}?${qs}` : `/event/${action}`
}

/**
 * Opens a registration. An unknown id does NOT fail the request — it comes
 * back 200 with `event_x: null`, so the caller renders not-found rather than
 * an error. Ineligibility likewise arrives as data (`eligibility`).
 */
export async function fetchEventRegistration(
	eventId: string,
	variant: EventVariant,
): Promise<EventRegistrationLoad> {
	const load = await examregFetch<EventRegistrationLoad>(
		eventPath("info", variant, { eventId }),
		{ method: "GET" },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to open the registration form. Please try again.",
		},
	)
	// Rich-text org fields arrive as HTML; converted once here so every
	// render site downstream can stay a plain `{value}`.
	return {
		...load,
		event_x: load.event_x ? plainTextEventView(load.event_x) : null,
	}
}

/**
 * Countries with their compliance/required-field flags, plus picklists this
 * form does not render. Only the webcast address card consumes this.
 */
export function fetchEventOptions(): Promise<EventOptions> {
	return examregFetch<EventOptions>(
		"/event/options",
		{ method: "GET" },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to load country options.",
		},
	)
}

/**
 * Writes the registration. A paid event answers `isFree: false` with the
 * staged `orderId` to take to checkout; a free one is complete on return.
 */
export function registerForEvent(
	request: EventRegisterRequest,
	variant: EventVariant,
): Promise<EventRegisterResult> {
	return examregFetch<EventRegisterResult>(
		eventPath("register", variant),
		{ method: "POST", body: JSON.stringify(request) },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Registration failed. Please try again.",
		},
	)
}

/** Records an invite-only RSVP decline. */
export function declineEventRsvp(args: {
	eventId: string
	userEmail: string
}): Promise<unknown> {
	return examregFetch<unknown>(
		"/event/rsvpDecline",
		{ method: "POST", body: JSON.stringify(args) },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "We could not record your reply. Please try again.",
		},
	)
}

/**
 * Cancels a paid registration that was never paid for — the abandoned-checkout
 * case. Without this, the orphaned registration row makes the next load report
 * `alreadyRegistered` and locks the person out of trying again.
 */
export function rollbackEventRegistration(
	orderId: string,
	reason = "Cancel Registration",
): Promise<unknown> {
	return examregFetch<unknown>(
		"/event/rollback",
		{ method: "POST", body: JSON.stringify({ orderId, reason }) },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to release the registration.",
		},
	)
}

/**
 * Checkout is the exam module's own endpoint — one `/checkout` serves every
 * registration kind, so events re-export rather than duplicate it.
 */
export { startExamCheckout as startRegistrationCheckout } from "@/api/registration/exam-registration"
