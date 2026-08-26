import { useCallback, useSyncExternalStore } from "react"

/**
 * Subscribes to a CSS media query.
 *
 * `useSyncExternalStore` rather than `useState` + an effect: the very first
 * render already knows the answer, so a component that branches on breakpoint
 * never paints the wrong branch and then corrects itself — and there is no
 * state write inside an effect for `react-hooks/set-state-in-effect` to object
 * to.
 *
 * `getSnapshot` returns a boolean primitive, so re-reading `matchMedia` on
 * every render is safe: React compares the value, not the MediaQueryList.
 */
export function useMediaQuery(query: string): boolean {
	const subscribe = useCallback(
		(onStoreChange: () => void) => {
			const list = window.matchMedia(query)
			list.addEventListener("change", onStoreChange)
			return () => list.removeEventListener("change", onStoreChange)
		},
		[query],
	)

	return useSyncExternalStore(
		subscribe,
		() => window.matchMedia(query).matches,
		// No-DOM fallback: assume the narrow layout, which degrades safely.
		() => false,
	)
}
