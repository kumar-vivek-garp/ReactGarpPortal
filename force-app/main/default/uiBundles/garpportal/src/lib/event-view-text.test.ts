import { describe, expect, it } from "vitest"

import { eventView } from "@/testing/factories/event"
import { plainTextEventView } from "./event-view-text"

describe("plainTextEventView", () => {
	it("strips the rich-text wrapper the org sends around activity details, and touches nothing else", () => {
		// Regression: RSVP_Activity_Details__c reached the screen as the
		// literal text "<p>detail detail</p>".
		const view = eventView({
			rsvpActivityName: "Activity",
			rsvpActivityDetails: "<p>detail detail</p>",
			rsvpActivityLocation: "new york city",
		})

		expect(plainTextEventView(view)).toEqual({
			...view,
			rsvpActivityDetails: "detail detail",
		})
	})

	it("converts every rich-text field, keeping paragraph breaks and decoding entities", () => {
		const view = plainTextEventView(
			eventView({
				description: "<p>Keynote &amp; panel</p><p>Doors at 6</p>",
				cancellationPolicy: "<p>No refunds<br>after 1 March.</p>",
				paymentPolicy: "<div>Due&nbsp;at registration.</div>",
				rsvpCopy: "<p><strong>Join us</strong> for dinner.</p>",
				rsvpWaitlistCopy: "<p>We are full.</p>",
				eventQuestionDetail: "<p>Tell us about your <em>role</em>.</p>",
			}),
		)

		expect(view.description).toBe("Keynote & panel\nDoors at 6")
		expect(view.cancellationPolicy).toBe("No refunds\nafter 1 March.")
		expect(view.paymentPolicy).toBe("Due at registration.")
		expect(view.rsvpCopy).toBe("Join us for dinner.")
		expect(view.rsvpWaitlistCopy).toBe("We are full.")
		expect(view.eventQuestionDetail).toBe("Tell us about your role.")
	})

	it("turns an editor-emptied value into null and leaves null alone", () => {
		const view = plainTextEventView(
			eventView({ rsvpActivityDetails: "<p><br></p>", paymentPolicy: null }),
		)

		expect(view.rsvpActivityDetails).toBeNull()
		expect(view.paymentPolicy).toBeNull()
	})

	it("passes already-plain text through unchanged", () => {
		const view = plainTextEventView(
			eventView({ description: "Two days of talks.\nDoors at 8." }),
		)

		expect(view.description).toBe("Two days of talks.\nDoors at 8.")
	})
})
