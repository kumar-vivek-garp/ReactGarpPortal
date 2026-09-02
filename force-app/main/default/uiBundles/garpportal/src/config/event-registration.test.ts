import { describe, expect, it } from "vitest"

import { eventRegistrationSearchSchema } from "./event-registration"

describe("eventRegistrationSearchSchema", () => {
	it("keeps every payment param as a string, even when all digits", () => {
		// The router JSON-parses search values, so ?checkout_cancelled=1&oid=8013
		// arrives as NUMBERS; a bare z.string() would drop them silently — which
		// for the cancel leg means the rollback never gets its order id.
		const parsed = eventRegistrationSearchSchema.parse({
			stripe_return: 1,
			oid: 8013,
			on: 12345,
			checkout_cancelled: 1,
		})
		expect(parsed).toEqual({
			stripe_return: "1",
			oid: "8013",
			on: "12345",
			checkout_cancelled: "1",
		})
	})

	it("leaves absent params absent", () => {
		expect(eventRegistrationSearchSchema.parse({})).toEqual({
			stripe_return: undefined,
			oid: undefined,
			on: undefined,
			checkout_cancelled: undefined,
		})
	})

	it("silently ignores reg codes — events have no B2B pricing", () => {
		const parsed = eventRegistrationSearchSchema.parse({ regCode: "TEAM24" })
		expect("regCode" in parsed).toBe(false)
	})
})
