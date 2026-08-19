import { describe, expect, it } from "vitest"

import { caseStatusPresentation } from "./case-status"

describe("caseStatusPresentation", () => {
	it("treats a missing status as a neutral em dash", () => {
		expect(caseStatusPresentation(null)).toEqual({
			label: "—",
			tone: "neutral",
		})
		expect(caseStatusPresentation("   ")).toEqual({
			label: "—",
			tone: "neutral",
		})
	})

	it("trims the Apex picklist label", () => {
		expect(caseStatusPresentation("  In Progress  ")).toEqual({
			label: "In Progress",
			tone: "info",
		})
	})

	it("tones closed and solved as success", () => {
		expect(caseStatusPresentation("Closed")).toEqual({
			label: "Closed",
			tone: "success",
		})
		expect(caseStatusPresentation("Solved")).toEqual({
			label: "Solved",
			tone: "success",
		})
	})

	it("tones escalated as danger", () => {
		expect(caseStatusPresentation("Escalated")).toEqual({
			label: "Escalated",
			tone: "danger",
		})
	})

	it("tones on-hold as warning", () => {
		expect(caseStatusPresentation("On Hold")).toEqual({
			label: "On Hold",
			tone: "warning",
		})
	})
})
