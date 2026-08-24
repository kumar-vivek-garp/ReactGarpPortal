import { useEffect, useState } from "react"

const QUERY = "(prefers-reduced-motion: reduce)"

/**
 * Tracks the OS "reduce motion" preference, live.
 *
 * Deliberately not `useReducedMotion` from `@react-spring/web`: that one flips
 * the library-wide `Globals.skipAnimation`, so calling it from a leaf would
 * silently disable every spring in the app. This only reports the preference
 * and leaves each caller to decide what to do about it.
 */
function usePrefersReducedMotion() {
	const [prefersReducedMotion, setPrefersReducedMotion] = useState(false)

	useEffect(() => {
		const media = window.matchMedia(QUERY)
		const sync = () => setPrefersReducedMotion(media.matches)
		sync()
		media.addEventListener("change", sync)
		return () => media.removeEventListener("change", sync)
	}, [])

	return prefersReducedMotion
}

export { usePrefersReducedMotion }
