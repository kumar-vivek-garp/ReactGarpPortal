import { describe, expect, it } from "vitest"

import { cpdActivitiesSearchSchema, cpdSearchSchema } from "./cpd"

describe("cpdSearchSchema", () => {
	it("passes a cycle name through", () => {
		expect(cpdSearchSchema.parse({ cycle: "2026/2027" }).cycle).toBe(
			"2026/2027",
		)
	})

	it("leaves an absent cycle undefined so the server's current cycle applies", () => {
		expect(cpdSearchSchema.parse({}).cycle).toBeUndefined()
	})

	it("degrades a non-string cycle instead of throwing", () => {
		expect(cpdSearchSchema.parse({ cycle: 2026 }).cycle).toBeUndefined()
	})
})

describe("cpdActivitiesSearchSchema", () => {
	it("accepts a fully-specified search", () => {
		expect(
			cpdActivitiesSearchSchema.parse({
				activityId: "a0X5d000001",
				type: ["Webcast", "Course"],
				area: ["Climate"],
				provider: ["GARP"],
				sort: "Credits High to Low",
				page: 3,
			}),
		).toEqual({
			activityId: "a0X5d000001",
			type: ["Webcast", "Course"],
			area: ["Climate"],
			provider: ["GARP"],
			sort: "Credits High to Low",
			page: 3,
		})
	})

	it("leaves everything undefined on an empty search", () => {
		expect(cpdActivitiesSearchSchema.parse({})).toEqual({
			activityId: undefined,
			type: undefined,
			area: undefined,
			provider: undefined,
			sort: undefined,
			page: undefined,
		})
	})

	it("coerces a string page number", () => {
		expect(cpdActivitiesSearchSchema.parse({ page: "3" }).page).toBe(3)
	})

	it("drops a page below 1, fractional, or non-numeric", () => {
		expect(cpdActivitiesSearchSchema.parse({ page: 0 }).page).toBeUndefined()
		expect(cpdActivitiesSearchSchema.parse({ page: -2 }).page).toBeUndefined()
		expect(cpdActivitiesSearchSchema.parse({ page: 1.5 }).page).toBeUndefined()
		expect(cpdActivitiesSearchSchema.parse({ page: "abc" }).page).toBeUndefined()
	})

	it("only accepts facets as arrays — repeated params, not a lone value", () => {
		// `?type=A&type=B` is the wire shape; a single bare string is not an
		// array and the whole facet degrades to undefined rather than throwing.
		expect(
			cpdActivitiesSearchSchema.parse({ type: "Webcast" }).type,
		).toBeUndefined()
	})

	it("drops a facet array containing a non-string element", () => {
		// A numeric-looking facet value would be JSON-parsed to a number by the
		// router; the array then fails as a whole. Facet values are picklist
		// labels, so digits-only values do not occur in practice.
		expect(
			cpdActivitiesSearchSchema.parse({ area: ["Climate", 2024] }).area,
		).toBeUndefined()
	})

	it("drops an unknown sort label", () => {
		// The legacy initialised its control to a label the server never
		// recognised; unknown labels now degrade to the client default instead.
		expect(
			cpdActivitiesSearchSchema.parse({ sort: "Date: Descending" }).sort,
		).toBeUndefined()
	})
})
