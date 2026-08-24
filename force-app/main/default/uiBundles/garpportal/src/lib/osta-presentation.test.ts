import { describe, expect, it } from "vitest"

import { toDateInputValue, toUsDateString } from "./osta-presentation"

describe("toUsDateString", () => {
	it("converts the date input's ISO value to what Apex parses", () => {
		expect(toUsDateString("2030-04-09")).toBe("04/09/2030")
	})

	/**
	 * Converted by hand rather than through `Date`. `new Date("2030-01-01")`
	 * reads as UTC and renders as 31 December for anyone west of Greenwich —
	 * on an expiry date that is the difference between a valid ID and an
	 * expired one.
	 */
	it("does not shift the day across a month or year boundary", () => {
		expect(toUsDateString("2030-01-01")).toBe("01/01/2030")
		expect(toUsDateString("2030-12-31")).toBe("12/31/2030")
	})

	it("passes through a value that is already MM/dd/yyyy", () => {
		expect(toUsDateString("04/09/2030")).toBe("04/09/2030")
	})

	it("passes rubbish through so Apex's own parse error surfaces", () => {
		expect(toUsDateString("not a date")).toBe("not a date")
		expect(toUsDateString("")).toBe("")
	})
})

describe("toDateInputValue", () => {
	it("converts what GET osta returns into what the date input binds to", () => {
		expect(toDateInputValue("07/03/2031")).toBe("2031-07-03")
	})

	it("round-trips with toUsDateString without shifting the day", () => {
		expect(toUsDateString(toDateInputValue("01/01/2030"))).toBe("01/01/2030")
		expect(toUsDateString(toDateInputValue("12/31/2030"))).toBe("12/31/2030")
	})

	it("returns empty for nothing on file", () => {
		expect(toDateInputValue(null)).toBe("")
		expect(toDateInputValue(undefined)).toBe("")
		expect(toDateInputValue("2031-07-03")).toBe("")
	})
})
