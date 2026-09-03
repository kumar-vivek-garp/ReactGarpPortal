import { describe, expect, it } from "vitest"

import { toEventFormValues } from "@/components/forms/event-registration/event-form-values"
import { eventContact } from "@/testing/factories/event"
import { personalInfoEditData } from "@/testing/factories/personal-info"

describe("toEventFormValues", () => {
	it("seeds a guest with the empty set — nothing prefilled anywhere", () => {
		const values = toEventFormValues(null, null)

		expect(values.email).toBe("")
		expect(values.firstName).toBe("")
		expect(values.lastName).toBe("")
		expect(values.jobTitle).toBe("")
		expect(values.company).toBe("")
		expect(values.workPhone).toBe("")
		expect(values.attendanceMethod).toBe("")
		expect(values.country).toBe("")
		expect(values.attendingActivity).toBe(false)
		expect(values.dietaryRestriction).toBe(false)
	})

	it("seeds identity and professional fields from the event load's contact", () => {
		const values = toEventFormValues(
			eventContact({
				email: "ada@example.test",
				firstName: "Ada",
				lastName: "Lovelace",
				title: "Analyst",
				company: "Analytical Engines",
			}),
		)

		expect(values.email).toBe("ada@example.test")
		expect(values.firstName).toBe("Ada")
		expect(values.lastName).toBe("Lovelace")
		expect(values.jobTitle).toBe("Analyst")
		expect(values.company).toBe("Analytical Engines")
		// The phone is asked fresh every time — never seeded.
		expect(values.workPhone).toBe("")
	})

	it("falls back to the member profile when the load has no contact (local dev's admin gateway)", () => {
		const values = toEventFormValues(
			null,
			personalInfoEditData({
				email: "grace@example.test",
				firstName: "Grace",
				lastName: "Hopper",
			}),
		)

		expect(values.email).toBe("grace@example.test")
		expect(values.firstName).toBe("Grace")
		expect(values.lastName).toBe("Hopper")
		// The profile carries no professional fields — they stay empty.
		expect(values.jobTitle).toBe("")
		expect(values.company).toBe("")
	})

	it("prefers the contact over the profile field by field", () => {
		const values = toEventFormValues(
			eventContact({ email: "ada@example.test", firstName: "Ada" }),
			personalInfoEditData({ email: "grace@example.test", firstName: "Grace" }),
		)

		expect(values.email).toBe("ada@example.test")
		expect(values.firstName).toBe("Ada")
	})

	it("fills a null contact field from the profile rather than dropping to empty", () => {
		const values = toEventFormValues(
			eventContact({ email: null }),
			personalInfoEditData({ email: "grace@example.test" }),
		)

		expect(values.email).toBe("grace@example.test")
	})

	it("always starts every consent and the attestation unticked, even for a known member", () => {
		const values = toEventFormValues(eventContact(), personalInfoEditData())

		expect(values.agreeToGarpContent).toBe(false)
		expect(values.agreeToSponsorContact).toBe(false)
		expect(values.privacyPolicyAttestation).toBe(false)
	})
})
