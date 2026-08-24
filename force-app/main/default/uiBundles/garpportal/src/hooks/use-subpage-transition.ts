import { useCallback, useRef, useState } from "react"
import { useSpring } from "@react-spring/web"

/** The entrance every programme subpage already uses. */
export const SUBPAGE_SPRING = { mass: 0.9, tension: 320, friction: 26 }

const OFFSCREEN = { opacity: 0, transform: "translateX(18px)" }
const ONSCREEN = { opacity: 1, transform: "translateX(0px)" }

/**
 * Never leave a member stranded on a page they asked to leave.
 *
 * `onRest` is the happy path, but a spring that is interrupted — or a browser
 * that throttles a background tab — may never rest, and the navigation is
 * queued behind it. This is the ceiling, comfortably longer than the spring.
 */
const EXIT_FALLBACK_MS = 400

/**
 * Slide-and-fade for a programme subpage, in both directions.
 *
 * Entry matches what `/programs/$programType` and its results page already do.
 * Exit is its mirror: the page slides back out the way it came in before the
 * route changes, so Back reads as reversing the journey rather than as a cut.
 *
 * Navigation is deferred until the exit settles, which is why `exit` takes the
 * navigation as a callback rather than a destination — the caller keeps its
 * own typed `Link`/`navigate` and this only decides *when* it runs.
 *
 * Reduced motion needs no branch here: `useReducedMotion()` in `__root.tsx`
 * makes springs settle immediately, so `onRest` fires at once and Back stays
 * instant.
 */
export function useSubpageTransition() {
	const pendingRef = useRef<(() => void) | null>(null)
	const [isExiting, setIsExiting] = useState(false)

	const runPending = useCallback(() => {
		const run = pendingRef.current
		pendingRef.current = null
		run?.()
	}, [])

	const style = useSpring({
		from: OFFSCREEN,
		to: isExiting ? OFFSCREEN : ONSCREEN,
		config: SUBPAGE_SPRING,
		onRest: () => {
			if (pendingRef.current) runPending()
		},
	})

	const exit = useCallback(
		(run: () => void) => {
			// A second click while already leaving must not queue a second
			// navigation behind the same animation.
			if (pendingRef.current) return
			pendingRef.current = run
			setIsExiting(true)
			window.setTimeout(runPending, EXIT_FALLBACK_MS)
		},
		[runPending],
	)

	return { style, exit, isExiting }
}
