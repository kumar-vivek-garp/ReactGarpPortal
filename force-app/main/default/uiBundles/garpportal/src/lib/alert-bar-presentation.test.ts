import { describe, expect, it } from "vitest"

import type { AlertBarView } from "@/api/alert-bar"
import { ALERT_BAR_COPY } from "@/config/alert-bar"
import { toAlertBarModel } from "@/lib/alert-bar-presentation"

/** A payload as `GARP_Portal_AlertBarService` writes it. */
function view(overrides: Partial<AlertBarView> = {}): AlertBarView {
	return {
		statusMessage: "Success",
		statusCode: 200,
		examType: "FRM",
		examPart: "II",
		alertStatus: "Scheduling Incomplete",
		deadline: "2026-11-07",
		orderId: null,
		route: "Exam Scheduling",
		...overrides,
	}
}

describe("toAlertBarModel — nothing to show", () => {
	it.each([
		["a null payload", null],
		["an undefined payload", undefined],
	])("returns null for %s", (_label, payload) => {
		expect(toAlertBarModel(payload)).toBeNull()
	})

	it.each([
		["null", null],
		["empty", ""],
		["whitespace", "   "],
	])("returns null when alertStatus is %s", (_label, alertStatus) => {
		expect(toAlertBarModel(view({ alertStatus }))).toBeNull()
	})
})

describe("toAlertBarModel — the eight statuses", () => {
	/**
	 * Every rung gets its own copy and tone. Driven off the config so a new
	 * status cannot be added there without a matching entry proving out here.
	 */
	it.each(Object.keys(ALERT_BAR_COPY))("resolves copy for %s", (status) => {
		const copy = ALERT_BAR_COPY[status as keyof typeof ALERT_BAR_COPY]
		const model = toAlertBarModel(view({ alertStatus: status }))

		expect(model?.message).toBe(copy.message)
		expect(model?.tone).toBe(copy.tone)
	})

	it("marks the three urgent payment/scheduling rungs urgent", () => {
		expect(ALERT_BAR_COPY["Exam Unpaid"].tone).toBe("urgent")
		expect(ALERT_BAR_COPY["Modification Order Pending"].tone).toBe("urgent")
		expect(ALERT_BAR_COPY["Scheduling Incomplete"].tone).toBe("urgent")
	})

	it("keeps the two soft nudges quiet", () => {
		expect(ALERT_BAR_COPY["Enrollment Expiring Soon"].tone).toBe("notice")
		expect(ALERT_BAR_COPY["CV Submission Expiring Soon"].tone).toBe("notice")
	})
})

describe("toAlertBarModel — the programme label", () => {
	it("names the FRM part, because FRM is the only two-part programme", () => {
		expect(toAlertBarModel(view())?.programme).toBe("FRM Part II")
	})

	it("drops the part when it is Full", () => {
		const model = toAlertBarModel(
			view({ examType: "RAI", examPart: "Full", route: null }),
		)
		expect(model?.programme).toBe("RAI")
	})

	it("falls back when Apex names no programme", () => {
		const model = toAlertBarModel(view({ examType: null, route: null }))
		expect(model?.programme).toBe("Your exam")
	})
})

describe("toAlertBarModel — the deadline", () => {
	it("leads the date with the status's own prefix", () => {
		// "Book by", not the generic "Deadline" the legacy uses for everything
		// that is not scheduling.
		expect(toAlertBarModel(view())?.deadlineLabel).toMatch(/^Book by /)
	})

	it("uses a different prefix for a payment deadline", () => {
		const model = toAlertBarModel(
			view({ alertStatus: "Exam Unpaid", route: null }),
		)
		expect(model?.deadlineLabel).toMatch(/^Pay by /)
	})

	it("is null for the four statuses that carry no date", () => {
		const model = toAlertBarModel(view({ deadline: null }))
		expect(model?.deadlineLabel).toBeNull()
	})

	it("parses the ISO date as local, so it cannot slip a day", () => {
		const model = toAlertBarModel(view({ deadline: "2026-11-07" }))
		expect(model?.deadlineLabel).toContain("2026")
		expect(model?.deadlineLabel).toContain("7")
	})
})

describe("toAlertBarModel — routes resolve through the shared helpers", () => {
	it("sends Complete Payment to the in-app order, by Opportunity Id", () => {
		const model = toAlertBarModel(
			view({
				alertStatus: "Exam Unpaid",
				route: "Complete Payment",
				orderId: "006Hs00001abcXYZ",
			}),
		)
		expect(model?.action).toEqual({
			label: "Complete payment",
			href: "/my-account/orders/006Hs00001abcXYZ",
			isExternal: false,
		})
	})

	it("sends Submit CV to the programme's work experience page", () => {
		const model = toAlertBarModel(
			view({
				alertStatus: "CV Submission Expiring Soon",
				route: "Submit CV",
				examType: "FRM",
			}),
		)
		expect(model?.action?.href).toBe("/programs/frm/work-experience")
		expect(model?.action?.isExternal).toBe(false)
	})

	it("sends Exam Detail to results, mapping RAI to the riskai slug", () => {
		const model = toAlertBarModel(
			view({
				alertStatus: "Results Available",
				route: "Exam Detail",
				examType: "RAI",
				examPart: "Full",
			}),
		)
		expect(model?.action?.href).toBe("/programs/riskai/results")
	})

	it("keeps Exam Scheduling in-app now the wizard is built", () => {
		const model = toAlertBarModel(
			view({ examType: "RAI", examPart: "Full", route: "Exam Scheduling" }),
		)
		expect(model?.action?.href).toBe("/programs/riskai/exam-setup")
		expect(model?.action?.isExternal).toBe(false)
	})

	/** Registration is still parked, so this one still leaves the portal. */

	it("sends Exam Registration out to MyGarp registration", () => {
		const model = toAlertBarModel(
			view({
				alertStatus: "Enrollment Expired",
				route: "Exam Registration",
				examType: "RAI",
				examPart: "Full",
			}),
		)
		expect(model?.action?.href).toContain("/sfdcApp#!/registration/rai")
		expect(model?.action?.isExternal).toBe(true)
	})
})

describe("toAlertBarModel — degrades rather than throwing", () => {
	/**
	 * Apex owns this ladder and may grow a ninth rung without us. An unknown
	 * status must still say something.
	 */
	it("renders an unknown status as its own raw text, quietly", () => {
		const model = toAlertBarModel(
			view({ alertStatus: "Certificate Ready", route: null, deadline: null }),
		)
		expect(model?.message).toBe("Certificate Ready")
		expect(model?.tone).toBe("notice")
		expect(model?.action).toBeNull()
	})

	it("still shows an unknown status's date, just without a prefix", () => {
		const model = toAlertBarModel(
			view({ alertStatus: "Certificate Ready", route: null }),
		)
		expect(model?.deadlineLabel).not.toBeNull()
		expect(model?.deadlineLabel).not.toMatch(/^(Book|Pay|Register|Submit) by /)
	})

	it("drops the button for a route it does not recognise", () => {
		expect(toAlertBarModel(view({ route: "Teleport" }))?.action).toBeNull()
	})

	it("drops the button when Complete Payment carries no order", () => {
		const model = toAlertBarModel(
			view({ route: "Complete Payment", orderId: null }),
		)
		expect(model?.message).toBeTruthy()
		expect(model?.action).toBeNull()
	})

	/**
	 * Apex raises this one for FRM only, but a programme with no CV requirement
	 * has genuinely nowhere to send anyone — keep the message, lose the link.
	 */
	it("drops the button for Submit CV on a programme with no CV", () => {
		const model = toAlertBarModel(
			view({ route: "Submit CV", examType: "SCR", examPart: "Full" }),
		)
		expect(model?.action).toBeNull()
	})

	it("drops the button when the payload names no route at all", () => {
		expect(toAlertBarModel(view({ route: null }))?.action).toBeNull()
	})
})
