import { afterEach, describe, expect, it, vi } from "vitest"

import type { CaseSummary } from "@/api/help-center"
import {
	HELP_CENTER_BUCKET_META,
	HELP_CENTER_TAB_ITEMS,
	HELP_RESOURCE_GROUPS,
	HELP_RESOURCE_LINKS,
} from "@/config/help-center"
import {
	buildCasePresentation,
	caseAgeLabel,
	caseKey,
} from "./help-center-presentation"

function supportCase(overrides: Partial<CaseSummary> = {}): CaseSummary {
	return {
		id: "500gP00000MjKR2QAN",
		caseNumber: "00848454",
		subject: "Sample Subject",
		status: "New",
		createdDate: "2026-08-18T18:09:00.000Z",
		...overrides,
	}
}

afterEach(() => {
	vi.useRealTimers()
})

describe("help-center config", () => {
	it("initialises without a temporal dead zone error", () => {
		// Tab items derive from the bucket meta at module scope, so a declaration
		// order regression throws on import rather than failing a type check.
		expect(HELP_CENTER_TAB_ITEMS).toHaveLength(2)
		expect(HELP_CENTER_TAB_ITEMS[1].label).toBe(
			HELP_CENTER_BUCKET_META.requests.label,
		)
	})

	it("assigns every resource link to a declared group", () => {
		const groups = new Set(HELP_RESOURCE_GROUPS.map((g) => g.key))
		for (const link of HELP_RESOURCE_LINKS) {
			expect(groups.has(link.group), link.title).toBe(true)
		}
	})

	it("renders every resource group non-empty", () => {
		for (const group of HELP_RESOURCE_GROUPS) {
			expect(
				HELP_RESOURCE_LINKS.some((l) => l.group === group.key),
				group.key,
			).toBe(true)
		}
	})
})

describe("caseAgeLabel", () => {
	it("uses today and yesterday at the boundary", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(caseAgeLabel("2026-08-18T18:09:00.000Z")).toBe("Raised today")
		expect(caseAgeLabel("2026-08-17T18:09:00.000Z")).toBe("Raised yesterday")
	})

	it("counts days inside the first month", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(caseAgeLabel("2026-08-12T13:27:04.000Z")).toBe("Raised 6 days ago")
	})

	it("switches to months once older", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(caseAgeLabel("2026-06-18T00:00:00.000Z")).toBe("Raised 2 months ago")
		expect(caseAgeLabel("2026-07-14T00:00:00.000Z")).toBe("Raised last month")
	})

	it("says nothing for a future-dated case rather than narrating a data problem", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(caseAgeLabel("2026-09-01T00:00:00.000Z")).toBeNull()
	})

	it("returns null with no date", () => {
		expect(caseAgeLabel(null)).toBeNull()
		expect(caseAgeLabel("")).toBeNull()
	})
})

describe("caseKey", () => {
	it("prefers the record id, then the case number, then the index", () => {
		expect(caseKey(supportCase(), 0)).toBe("500gP00000MjKR2QAN")
		expect(caseKey(supportCase({ id: null }), 0)).toBe("00848454")
		expect(caseKey(supportCase({ id: null, caseNumber: null }), 3)).toBe("case-3")
	})
})

describe("buildCasePresentation", () => {
	it("carries number, subject, status tone and recency", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const result = buildCasePresentation(supportCase())
		expect(result.caseNumber).toBe("00848454")
		expect(result.subject).toBe("Sample Subject")
		// "New" is an open state — informational rather than success or warning.
		expect(result.statusLabel).toBe("New")
		expect(result.statusTone).toBe("info")
		expect(result.agoLabel).toBe("Raised today")
		expect(result.raisedLabel).not.toBeNull()
	})

	it("exposes recency as a meta line for shared rendering", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const result = buildCasePresentation(supportCase())
		expect(result.metaLines).toEqual([
			{ icon: "lastOpened", text: "Raised today" },
		])
	})

	it("falls back to em dashes for missing fields", () => {
		const result = buildCasePresentation(
			supportCase({ caseNumber: null, subject: "   ", createdDate: null }),
		)
		expect(result.caseNumber).toBe("—")
		expect(result.subject).toBe("—")
		expect(result.raisedLabel).toBeNull()
		expect(result.agoLabel).toBeNull()
		expect(result.metaLines).toEqual([])
	})

	it("tones a closed case as success", () => {
		expect(buildCasePresentation(supportCase({ status: "Closed" })).statusTone).toBe(
			"success",
		)
	})
})
