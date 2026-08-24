import { useCallback, useEffect, useRef } from "react"
import { useSpring } from "@react-spring/web"

import { scrollParent } from "@/lib/scroll-parent"

/** Matches the footer back-to-top glide. `clamp` stops any overshoot past the target. */
const SCROLL_SPRING = { mass: 1, tension: 170, friction: 28, clamp: true }

/** Breathing room above the target so it does not butt against the container edge. */
const SCROLL_OFFSET_PX = 12

/**
 * Spring-driven scroll to an element inside its own scroll container.
 *
 * The panel body is an `overflow-y-auto` div rather than the document, so
 * `window.scrollTo` would not move it. Finding the scroll parent from the
 * target avoids threading a ref through the tab-transition boundary.
 *
 * Reduced motion is handled globally by `useReducedMotion()` in `pages/__root.tsx`,
 * which makes the spring resolve immediately — an instant jump, not a broken one.
 */
export function useSpringScrollTo() {
	const containerRef = useRef<HTMLElement | null>(null)
	const [, api] = useSpring(() => ({ y: 0, config: SCROLL_SPRING }))

	useEffect(() => {
		// A deliberate user scroll should win over an in-flight glide.
		const interrupt = () => api.stop()
		window.addEventListener("wheel", interrupt, { passive: true })
		window.addEventListener("touchstart", interrupt, { passive: true })
		return () => {
			window.removeEventListener("wheel", interrupt)
			window.removeEventListener("touchstart", interrupt)
		}
	}, [api])

	const scrollTo = useCallback(
		(target: HTMLElement | null) => {
			if (!target) return

			const container = scrollParent(target)
			if (!container) {
				target.scrollIntoView({ block: "start" })
				return
			}

			const from = container.scrollTop
			const delta =
				target.getBoundingClientRect().top -
				container.getBoundingClientRect().top -
				SCROLL_OFFSET_PX
			const max = container.scrollHeight - container.clientHeight
			const to = Math.max(0, Math.min(max, from + delta))
			if (Math.abs(to - from) < 1) return

			containerRef.current = container
			void api.start({
				from: { y: from },
				to: { y: to },
				onChange: ({ value }) => {
					const node = containerRef.current
					if (node) node.scrollTop = (value as { y: number }).y
				},
			})
		},
		[api],
	)

	/** Cancels an in-flight glide — a bento drag takes over the scroll container. */
	const stop = useCallback(() => {
		api.stop()
	}, [api])

	return { scrollTo, stop }
}
