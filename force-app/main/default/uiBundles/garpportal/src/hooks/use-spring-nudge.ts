import { useState } from "react"
import { useSpring } from "@react-spring/web"

/**
 * Direction the nudge travels on hover / focus.
 * `backward` for return links (leading arrow), `forward` for CTAs (trailing arrow).
 */
export type SpringNudgeDirection = "forward" | "backward"

/** Shared physics — matches the original Programs back-button feel. */
const NUDGE_SPRING = { mass: 0.85, tension: 340, friction: 22 } as const

/**
 * Container shifts and scales; the icon shifts *further* in the same direction so
 * the gap between icon and label opens up. Forward is gentler than backward —
 * CTAs are small inline text, not a page-level back link.
 */
const NUDGE_MOTION = {
	backward: { containerX: -5, iconX: -3, scale: 1.04 },
	forward: { containerX: 4, iconX: 3, scale: 1.03 },
} as const

type UseSpringNudgeOptions = {
	direction?: SpringNudgeDirection
	/** Skip the springs entirely (e.g. a disabled CTA). */
	disabled?: boolean
}

/**
 * Physics-based hover/focus nudge for links and CTAs.
 *
 * Spread `bind` onto the interactive element itself (`<a>` / `<Link>`), not onto a
 * child — focus events do not bubble down, so a handler on a nested span would
 * never fire for keyboard users.
 *
 * Reduced motion is handled globally by `useReducedMotion()` in `pages/__root.tsx`.
 */
export function useSpringNudge({
	direction = "forward",
	disabled = false,
}: UseSpringNudgeOptions = {}) {
	const [active, setActive] = useState(false)
	const motion = NUDGE_MOTION[direction]
	const engaged = active && !disabled

	const containerStyle = useSpring({
		x: engaged ? motion.containerX : 0,
		scale: engaged ? motion.scale : 1,
		config: NUDGE_SPRING,
	})

	const iconStyle = useSpring({
		x: engaged ? motion.iconX : 0,
		config: NUDGE_SPRING,
	})

	const bind = {
		onMouseEnter: () => setActive(true),
		onMouseLeave: () => setActive(false),
		onFocus: () => setActive(true),
		onBlur: () => setActive(false),
	} as const

	return { bind, containerStyle, iconStyle, direction }
}
