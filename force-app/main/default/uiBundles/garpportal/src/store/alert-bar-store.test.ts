import { beforeEach, describe, expect, it } from "vitest"

import { useAlertBarStore } from "@/store/alert-bar-store"

/**
 * The phase is keyed on the alert it was set on. These tests cover the reason
 * that key exists: a minimised deadline must not silently swallow the *next*
 * deadline when Apex moves on to it.
 */
function phaseFor(key: string | null) {
	const { phase, phaseFor } = useAlertBarStore.getState()
	return key !== null && phaseFor === key ? phase : "expanded"
}

describe("alert bar store", () => {
	beforeEach(() => {
		useAlertBarStore.setState({
			phase: "expanded",
			phaseFor: null,
			anchors: { desktop: null, mobile: null },
		})
	})

	it("holds a phase against the alert it was set on", () => {
		useAlertBarStore.getState().setPhase("minimised", "Scheduling Incomplete")

		expect(phaseFor("Scheduling Incomplete")).toBe("minimised")
	})

	it("re-expands when a different alert takes its place", () => {
		useAlertBarStore.getState().setPhase("minimised", "Scheduling Incomplete")

		expect(phaseFor("Exam Unpaid")).toBe("expanded")
	})

	it("reads as expanded when there is no alert to key on", () => {
		useAlertBarStore.getState().setPhase("minimised", "Scheduling Incomplete")

		expect(phaseFor(null)).toBe("expanded")
	})

	it("keeps one anchor per toolbar so the hidden one can be skipped", () => {
		const element = {} as HTMLElement
		useAlertBarStore.getState().setAnchor("mobile", element)

		expect(useAlertBarStore.getState().anchors).toEqual({
			desktop: null,
			mobile: element,
		})
	})
})
