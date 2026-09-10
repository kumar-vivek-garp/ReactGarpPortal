import { useCallback, useEffect, useRef } from "react"
import { useSpring } from "@react-spring/web"

import { scrollParent } from "@/lib/scroll-parent"

/** Matches the footer back-to-top glide. `clamp` stops any overshoot past the target. */
const SCROLL_SPRING = { mass: 1, tension: 170, friction: 28, clamp: true }

/** Breathing room above the target so it does not butt against the container edge. */
const SCROLL_OFFSET_PX = 12

/**
 * How far down the container a target has to sit before `ifNeeded` leaves it
 * alone. A quarter of the visible height clears the registration forms'
 * sticky submit bar (5.5rem, ~8rem where it wraps on a phone) on every
 * viewport that renders one, without this hook knowing the bar exists.
 */
const COMFORTABLE_TOP_FRACTION = 0.25

export type SpringScrollOptions = {
	/**
	 * `start` puts the target at the top of the container with breathing room —
	 * the section-jump behaviour. `center` puts it mid-container, which is what
	 * a control needs when a sticky bar sits inside the same scroller: centred,
	 * it is clear of the bar on every layout without measuring the bar.
	 */
	align?: "start" | "center"
	/**
	 * Skip the glide when the target is already comfortably in view — centring
	 * a control that is right under the pointer reads as a glitch, not help.
	 */
	ifNeeded?: boolean
}

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
		(target: HTMLElement | null, options: SpringScrollOptions = {}) => {
			if (!target) return
			const { align = "start", ifNeeded = false } = options

			const container = scrollParent(target)
			if (!container) {
				// No scrolling ancestor (the document scrolls, or jsdom): let the
				// browser place it, same alignment.
				target.scrollIntoView({ block: align })
				return
			}

			const rect = target.getBoundingClientRect()
			const frame = container.getBoundingClientRect()

			if (ifNeeded) {
				const comfortableTop =
					frame.top + container.clientHeight * COMFORTABLE_TOP_FRACTION
				const inView =
					rect.top >= comfortableTop &&
					rect.bottom <= frame.bottom - SCROLL_OFFSET_PX
				if (inView) return
			}

			const from = container.scrollTop
			const delta =
				align === "center"
					? rect.top - frame.top - (container.clientHeight - rect.height) / 2
					: rect.top - frame.top - SCROLL_OFFSET_PX
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
