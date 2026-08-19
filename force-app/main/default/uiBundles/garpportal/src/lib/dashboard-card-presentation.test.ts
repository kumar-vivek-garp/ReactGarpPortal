import { afterEach, describe, expect, it, vi } from "vitest"

import type { PortalCard } from "@/api/dashboard"
import {
	buildDashboardCardPresentation,
	registrationWindowLine,
} from "./dashboard-card-presentation"
import { DASHBOARD_PROVIDER } from "./compose-dashboard-cards"

function card(overrides: Partial<PortalCard> = {}): PortalCard {
	return {
		key: "c1",
		page: "Dashboard",
		provider: DASHBOARD_PROVIDER.exam,
		rank: 5,
		title: "Register for the FRM Exam",
		body: null,
		ctaLabel: "Register",
		ctaUrl: "/programs",
		ctaIsExternal: false,
		imageUrl: null,
		eyebrow: null,
		badge: null,
		locked: false,
		dismissible: false,
		bullets: null,
		meta: {},
		...overrides,
	}
}

afterEach(() => {
	vi.useRealTimers()
})

describe("registrationWindowLine", () => {
	it("counts down inside the closing window", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(registrationWindowLine(true, "2026-08-24")).toEqual({
			icon: "expiringSoon",
			text: "Registration closes in 6 days",
		})
	})

	it("uses today / tomorrow at the boundary", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(registrationWindowLine(true, "2026-08-18")?.text).toBe(
			"Registration closes today",
		)
		expect(registrationWindowLine(true, "2026-08-19")?.text).toBe(
			"Registration closes tomorrow",
		)
	})

	it("states the date when the deadline is far off", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const line = registrationWindowLine(true, "2027-01-15")
		expect(line?.icon).toBe("registrationOpen")
		expect(line?.text).toContain("Registration open until")
	})

	it("reports a closed window", () => {
		expect(registrationWindowLine(false, null)).toEqual({
			icon: "opensLater",
			text: "Registration is not open",
		})
	})

	it("says nothing when Apex omits the flag", () => {
		// Rendering "not open" for a missing flag would assert a state we do not know.
		expect(registrationWindowLine(undefined, "2026-08-24")).toBeNull()
		expect(registrationWindowLine(undefined, null)).toBeNull()
	})

	it("still reports open without a deadline", () => {
		expect(registrationWindowLine(true, null)).toEqual({
			icon: "registrationOpen",
			text: "Registration is open",
		})
	})
})

describe("buildDashboardCardPresentation", () => {
	it("surfaces the badge that was previously composed and dropped", () => {
		// `profileCard` sets badge to the completeness percentage.
		const result = buildDashboardCardPresentation(
			card({ provider: DASHBOARD_PROVIDER.profile, badge: "27%" }),
		)
		expect(result.badgeLabel).toBe("27%")
		expect(result.badgeTone).toBe("info")
	})

	it("treats a blank badge as absent", () => {
		const result = buildDashboardCardPresentation(card({ badge: "   " }))
		expect(result.badgeLabel).toBeNull()
		expect(result.badgeTone).toBeNull()
	})

	it("combines exam type and administration into one sitting line", () => {
		const result = buildDashboardCardPresentation(
			card({
				meta: { examType: "FRM Part I", administrationName: "November 2026" },
			}),
		)
		expect(result.metaLines[0]).toEqual({
			icon: "administration",
			text: "FRM Part I · November 2026",
		})
	})

	it("falls back to period when there is no administration name", () => {
		const result = buildDashboardCardPresentation(
			card({ meta: { examType: "SCR", period: "Early registration" } }),
		)
		expect(result.metaLines[0].text).toBe("SCR · Early registration")
	})

	it("renders nothing for exam cards whose meta Apex did not populate", () => {
		// The exam fields are not set by client composition, so an empty bag must
		// produce no lines rather than placeholders.
		expect(buildDashboardCardPresentation(card()).metaLines).toEqual([])
	})

	it("ignores exam meta on non-exam providers", () => {
		const result = buildDashboardCardPresentation(
			card({
				provider: DASHBOARD_PROVIDER.events,
				meta: { examType: "FRM", isRegistrationOpen: true },
			}),
		)
		expect(result.metaLines).toEqual([])
	})

	it("combines the sitting line with the registration window", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const result = buildDashboardCardPresentation(
			card({
				meta: {
					examType: "FRM Part I",
					administrationName: "November 2026",
					isRegistrationOpen: true,
					registrationEnd: "2026-08-24",
				},
			}),
		)
		expect(result.metaLines).toHaveLength(2)
		expect(result.metaLines[1].text).toBe("Registration closes in 6 days")
	})

	it("tolerates a null meta bag", () => {
		const result = buildDashboardCardPresentation(card({ meta: null as never }))
		expect(result.metaLines).toEqual([])
	})
})
