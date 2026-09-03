import { createElement } from "react"
import { renderToString } from "react-dom/server"
import { renderHook } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { useMediaQuery } from "@/hooks/use-media-query"
import { stubMatchMedia } from "@/testing/match-media"

const QUERY = "(min-width: 64rem)"

const media = stubMatchMedia()

function Probe() {
	return createElement("span", null, String(useMediaQuery(QUERY)))
}

describe("useMediaQuery", () => {
	it("answers correctly on the very first render", () => {
		media.matches = true
		const { result } = renderHook(() => useMediaQuery(QUERY))
		expect(result.current).toBe(true)
	})

	it("tracks a viewport change live", () => {
		const { result } = renderHook(() => useMediaQuery(QUERY))
		expect(result.current).toBe(false)

		media.set(true)
		expect(result.current).toBe(true)

		media.set(false)
		expect(result.current).toBe(false)
	})

	it("assumes the narrow layout when rendered without a DOM", () => {
		media.matches = true
		// Server rendering takes the getServerSnapshot arm — the safe default.
		expect(renderToString(createElement(Probe))).toContain("false")
	})
})
