import { act } from "@testing-library/react"
import { afterEach, beforeEach } from "vitest"

/**
 * The vitest.setup.ts matchMedia shim always reports `matches: false` and
 * swallows listeners, so breakpoint-driven hooks can never see the two-column
 * layout or a change event. This swaps in a controllable implementation:
 * assign `matches` before render for the initial state, call `set()` after to
 * fire a change the way a real viewport resize would.
 *
 * Registers its own beforeEach/afterEach (restoring the global shim and
 * resetting to `matches: false`) — call once at the top level of a test file.
 */
export type MatchMediaControl = {
	matches: boolean
	set: (matches: boolean) => void
}

type ChangeListener = (event: MediaQueryListEvent) => void

export function stubMatchMedia(): MatchMediaControl {
	const listeners = new Set<ChangeListener>()
	const control: MatchMediaControl = {
		matches: false,
		set(matches) {
			control.matches = matches
			act(() => {
				for (const listener of [...listeners]) {
					listener({ matches } as MediaQueryListEvent)
				}
			})
		},
	}

	let original: typeof window.matchMedia

	beforeEach(() => {
		original = window.matchMedia
		control.matches = false
		listeners.clear()
		window.matchMedia = ((query: string) => ({
			get matches() {
				return control.matches
			},
			media: query,
			onchange: null,
			addListener: () => undefined,
			removeListener: () => undefined,
			addEventListener: (_type: string, listener: EventListener) => {
				listeners.add(listener as unknown as ChangeListener)
			},
			removeEventListener: (_type: string, listener: EventListener) => {
				listeners.delete(listener as unknown as ChangeListener)
			},
			dispatchEvent: () => false,
		})) as unknown as typeof window.matchMedia
	})

	afterEach(() => {
		window.matchMedia = original
	})

	return control
}
