import { useCallback, useLayoutEffect, useRef } from "react"
import { useSpring } from "@react-spring/web"

/**
 * Underdamped (ratio ~0.77) so the highlight eases and settles rather than
 * sliding linearly and stopping dead, but stiff enough that most of the travel
 * is behind it before a route render can block the main thread — a stall during
 * the slow tail is far less visible than one at peak velocity.
 */
const INDICATOR_SPRING = { mass: 0.8, tension: 380, friction: 27 } as const

/**
 * Base size the `scale` technique multiplies. Fixed so the scale factor is
 * deterministic; 100px keeps the factor near 1 for typical row/pill sizes, which
 * avoids soft edges from scaling a hairline box way up.
 */
const SCALE_BASE_PX = 100

export type SlidingIndicatorAxis = "x" | "y"

/**
 * How the indicator changes size as it travels.
 *
 * - `size` animates `width`/`height`: exact, and safe with a border radius,
 *   but relayouts and repaints every frame.
 * - `scale` animates a transform only, so frames are far cheaper and survive a
 *   busy main thread — but it scales the border radius too, so it is only for
 *   square blocks.
 */
export type SlidingIndicatorTechnique = "size" | "scale"

type UseSlidingIndicatorOptions = {
	/** `x` for a horizontal bar (tabs), `y` for a vertical list (sidebar). */
	axis?: SlidingIndicatorAxis
	/**
	 * Key of the active item. Empty / null means nothing is active, and the
	 * indicator hides rather than parking at zero size — pending shells rely on
	 * this while data loads.
	 */
	value: string | null | undefined
	/**
	 * Changes whenever the item set changes, so nodes get re-observed. Callers
	 * usually pass the joined item keys, since the items array is typically a
	 * fresh literal on every render.
	 */
	itemsKey?: string
	/** Scroll the active item into view when it changes (overflowing tab bars). */
	scrollActiveIntoView?: boolean
	/** Defaults to `size`. Use `scale` for square blocks that must stay smooth. */
	technique?: SlidingIndicatorTechnique
}

/**
 * Measures the active item in a group and glides a single indicator to it.
 *
 * Shared by `PillTabs` (horizontal) and the app sidebar (vertical) so the
 * measure / observe / spring logic exists once. Driven imperatively: measurement
 * happens in a layout effect, so routing it through component state would only
 * add a cascading render on every reflow.
 *
 * Reduced motion is handled globally by `useReducedMotion()` in `pages/__root.tsx`.
 */
export function useSlidingIndicator<C extends HTMLElement = HTMLElement>({
	axis = "x",
	value,
	itemsKey = "",
	scrollActiveIntoView = false,
	technique = "size",
}: UseSlidingIndicatorOptions) {
	const containerRef = useRef<C | null>(null)
	const itemRefs = useRef(new Map<string, HTMLElement>())
	/** Read only inside effects — the first placement jumps, the rest glide. */
	const hasPlaced = useRef(false)

	const [spring, api] = useSpring(() => ({
		x: 0,
		y: 0,
		width: 0,
		height: 0,
		scaleX: 0,
		scaleY: 0,
		opacity: 0,
		config: INDICATOR_SPRING,
	}))

	const registerRef = useCallback((key: string, node: HTMLElement | null) => {
		if (node) itemRefs.current.set(key, node)
		else itemRefs.current.delete(key)
	}, [])

	const measure = useCallback(() => {
		const node = value ? itemRefs.current.get(value) : undefined
		if (!node) {
			void api.start({ opacity: 0 })
			return
		}
		// Offsets are relative to the positioned container, so scrolling the
		// group does not shift the indicator along with it.
		const offset = axis === "x" ? node.offsetLeft : node.offsetTop
		const size = axis === "x" ? node.offsetWidth : node.offsetHeight

		const next =
			technique === "scale"
				? axis === "x"
					? { x: offset, scaleX: size / SCALE_BASE_PX }
					: { y: offset, scaleY: size / SCALE_BASE_PX }
				: axis === "x"
					? { x: offset, width: size }
					: { y: offset, height: size }

		void api.start({ ...next, opacity: 1, immediate: !hasPlaced.current })
		hasPlaced.current = true
	}, [api, axis, technique, value])

	useLayoutEffect(() => {
		measure()

		const container = containerRef.current
		if (!container || typeof ResizeObserver === "undefined") return

		// Re-measure when the group reflows: viewport resize, late font load, or
		// labels changing width once data lands.
		const observer = new ResizeObserver(measure)
		observer.observe(container)
		for (const node of itemRefs.current.values()) observer.observe(node)
		return () => observer.disconnect()
	}, [measure, itemsKey])

	useLayoutEffect(() => {
		if (!scrollActiveIntoView || !value) return
		// No-op when already visible.
		itemRefs.current
			.get(value)
			?.scrollIntoView({ block: "nearest", inline: "nearest" })
	}, [scrollActiveIntoView, value])

	/**
	 * Only the keys the chosen axis and technique need, ready to spread onto
	 * `animated.*`. In `scale` mode the base size ships with it, so callers only
	 * add the matching transform origin (`origin-top` / `origin-left`).
	 */
	const indicatorStyle =
		technique === "scale"
			? axis === "x"
				? {
						width: SCALE_BASE_PX,
						x: spring.x,
						scaleX: spring.scaleX,
						opacity: spring.opacity,
					}
				: {
						height: SCALE_BASE_PX,
						y: spring.y,
						scaleY: spring.scaleY,
						opacity: spring.opacity,
					}
			: axis === "x"
				? { x: spring.x, width: spring.width, opacity: spring.opacity }
				: { y: spring.y, height: spring.height, opacity: spring.opacity }

	return { containerRef, registerRef, indicatorStyle }
}
