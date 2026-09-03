import type { EventView } from "@/api/registration/event-types"
import { calendarPlainText } from "@/lib/event-calendar"

/**
 * The `EventView` keys whose org fields are rich-text areas — they arrive as
 * HTML, not text. Verified against the object describes: `Overview__c` /
 * `Short_Description__c` (behind `description`), `Cancellation_Policy__c`,
 * `Payment_Policy__c`, `RSVP_Copy__c`, `RSVP_Waitlist_Copy__c`,
 * `RSVP_Activity_Details__c` and `Event_Question_Detail__c`. The activity
 * name, location and question are plain strings and stay untouched.
 */
type RichTextField =
	| "description"
	| "cancellationPolicy"
	| "paymentPolicy"
	| "rsvpCopy"
	| "rsvpWaitlistCopy"
	| "rsvpActivityDetails"
	| "eventQuestionDetail"

const RICH_TEXT_FIELDS: readonly RichTextField[] = [
	"description",
	"cancellationPolicy",
	"paymentPolicy",
	"rsvpCopy",
	"rsvpWaitlistCopy",
	"rsvpActivityDetails",
	"eventQuestionDetail",
]

/**
 * Rich-text org copy → plain text, applied once at the load boundary so no
 * render site has to remember. This codebase injects no HTML, and forgetting
 * the conversion at a single `<p>{value}</p>` put the literal string
 * `<p>detail detail</p>` on the activity card — normalising the view here
 * makes that impossible to repeat. Paragraphs and `<br>` become newlines
 * (render with `whitespace-pre-line`); an empty rich-text value becomes
 * `null`, so `value ? … : null` gates keep working.
 */
export function plainTextEventView(view: EventView): EventView {
	const out = { ...view }
	for (const key of RICH_TEXT_FIELDS) {
		out[key] = calendarPlainText(view[key]) || null
	}
	return out
}
