import { act, fireEvent, screen } from "@testing-library/react"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import { GarpIdChip } from "@/components/molecules/garp-id-chip"
import { renderWithProviders } from "@/testing/render"
import { skipSpringAnimations } from "@/testing/springs"

/**
 * The icon swap is a `useTransition` with `exitBeforeEnter`, so with real
 * springs the tick only lands after real animation frames — flaky under a
 * loaded worker. The chip's springs get no fresh to/interpolation props per
 * render, so the skip is safe here (see the warning in testing/springs.ts).
 */
skipSpringAnimations()

/**
 * Same recipe as `use-debounced-value.test.ts`: fake ONLY setTimeout /
 * clearTimeout so microtasks (the clipboard promise) stay real.
 */
beforeEach(() => {
	vi.useFakeTimers({ toFake: ["setTimeout", "clearTimeout"] })
})
afterEach(() => {
	vi.clearAllTimers()
	vi.useRealTimers()
	vi.unstubAllGlobals()
})

function stubClipboard() {
	const writeText = vi.fn().mockResolvedValue(undefined)
	vi.stubGlobal("navigator", { ...window.navigator, clipboard: { writeText } })
	return writeText
}

const chip = () =>
	screen.getByRole("button", { name: "Copy GARP ID 123456" })

/** The tick icon is the only visible confirmation the copy landed. */
const showsTick = (container: HTMLElement) =>
	container.querySelector(".lucide-check") !== null

async function clickChip() {
	await act(async () => {
		fireEvent.click(chip())
	})
}

async function advance(ms: number) {
	await act(async () => {
		await vi.advanceTimersByTimeAsync(ms)
	})
}

describe("copying", () => {
	it("writes the GARP ID to the clipboard", async () => {
		const writeText = stubClipboard()
		renderWithProviders(<GarpIdChip garpId="123456" />)

		await clickChip()
		expect(writeText).toHaveBeenCalledExactlyOnceWith("123456")
	})

	it("confirms with a tick, then reverts after the hold", async () => {
		stubClipboard()
		const { container } = renderWithProviders(<GarpIdChip garpId="123456" />)
		expect(showsTick(container)).toBe(false)

		await clickChip()
		expect(showsTick(container)).toBe(true)

		// One ms short of the hold: still confirming.
		await advance(1599)
		expect(showsTick(container)).toBe(true)

		await advance(1)
		expect(showsTick(container)).toBe(false)
	})

	it("stays quiet when the environment offers no clipboard", async () => {
		vi.stubGlobal("navigator", { ...window.navigator, clipboard: undefined })
		const { container } = renderWithProviders(<GarpIdChip garpId="123456" />)

		// Must not throw, and must not claim a copy happened.
		await clickChip()
		expect(showsTick(container)).toBe(false)
	})
})
