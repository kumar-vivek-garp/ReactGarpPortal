import { describe, expect, it } from "vitest"

import {
	computeFlightPose,
	flightFade,
	resolveAnchorRect,
	type FlightRect,
} from "@/lib/alert-bar-flight"

/** A card in the bottom-right corner of a 1280x800 viewport. */
const CARD: FlightRect = { top: 620, left: 900, width: 368, height: 100 }
/** The trigger in the toolbar, up and slightly right of the card's edge. */
const ANCHOR: FlightRect = { top: 24, left: 1000, width: 96, height: 32 }

function stubElement(width: number): HTMLElement {
	return {
		getBoundingClientRect: () => ({ top: 24, left: 1000, width, height: 32 }),
	} as unknown as HTMLElement
}

describe("computeFlightPose", () => {
	it("lands the card's top-right corner on the anchor's centre", () => {
		const pose = computeFlightPose(CARD, ANCHOR)

		// anchor centre x 1048 - card right edge 1268
		expect(pose.x).toBe(-220)
		// anchor centre y 40 - card top 620
		expect(pose.y).toBe(-580)
		expect(pose.scale).toBeLessThan(1)
	})

	it("travels upward, since the toolbar is always above the card", () => {
		expect(computeFlightPose(CARD, ANCHOR).y).toBeLessThan(0)
	})

	it("lifts and fades on the spot when there is no toolbar to aim at", () => {
		const pose = computeFlightPose(CARD, null)

		expect(pose.x).toBe(0)
		expect(pose.y).toBeLessThan(0)
		// Barely shrinks: nothing is going to swallow it, so it must not vanish
		// into a point and look like a rendering fault.
		expect(pose.scale).toBeGreaterThan(0.5)
	})
})

describe("flightFade", () => {
	it("is fully opaque at rest", () => {
		expect(flightFade(0)).toBe(1)
	})

	it("is still fully opaque at the midpoint", () => {
		// The point of the whole curve: the card must be *seen* travelling, not
		// dissolve into a ghost a third of the way across.
		expect(flightFade(0.5)).toBe(1)
	})

	it("has faded out by the time it lands", () => {
		expect(flightFade(1)).toBe(0)
	})

	it("falls monotonically once the fade starts", () => {
		const samples = [0.6, 0.7, 0.8, 0.9, 1].map(flightFade)

		for (let i = 1; i < samples.length; i++) {
			expect(samples[i]).toBeLessThan(samples[i - 1])
		}
	})

	it("clamps the spring's overshoot rather than going negative", () => {
		// Springs genuinely pass their target; an unclamped ramp would flicker.
		expect(flightFade(1.08)).toBe(0)
		expect(flightFade(-0.05)).toBe(1)
	})
})

describe("resolveAnchorRect", () => {
	it("skips the hidden toolbar, which measures zero-wide", () => {
		const rect = resolveAnchorRect([stubElement(0), stubElement(96)])

		expect(rect?.width).toBe(96)
	})

	it("ignores unmounted anchors", () => {
		expect(resolveAnchorRect([null, stubElement(96)])?.width).toBe(96)
	})

	it("returns null when neither toolbar is on screen", () => {
		expect(resolveAnchorRect([null, stubElement(0)])).toBeNull()
	})
})
