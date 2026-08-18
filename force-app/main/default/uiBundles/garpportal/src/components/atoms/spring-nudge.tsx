import type { ReactNode } from "react"
import { animated } from "@react-spring/web"

import type { useSpringNudge } from "@/hooks/use-spring-nudge"
import { cn } from "@/lib/utils"

/** Value returned by `useSpringNudge` — thread it straight into `SpringNudge`. */
export type SpringNudgeState = ReturnType<typeof useSpringNudge>

type SpringNudgeProps = {
	/** From `useSpringNudge()`. Spread its `bind` onto the interactive parent. */
	nudge: SpringNudgeState
	/** The icon that leads the motion. Sized by the caller. */
	icon: ReactNode
	iconPosition?: "leading" | "trailing"
	/** Label and any static adornments (e.g. a lock glyph). */
	children: ReactNode
	className?: string
}

/**
 * Animated inner content for a link or CTA: the whole run of content shifts and
 * scales while the icon travels a little further, opening the gap between icon
 * and label.
 *
 * Presentational only — it renders spans, never an `<a>` or `<Link>`, so callers
 * keep full control of navigation. `origin-left` on both directions keeps text
 * left-anchored while it grows.
 */
function SpringNudge({
	nudge,
	icon,
	iconPosition = "trailing",
	children,
	className,
}: SpringNudgeProps) {
	const animatedIcon = (
		<animated.span
			className="inline-flex shrink-0 will-change-transform"
			style={{ x: nudge.iconStyle.x }}
			aria-hidden
		>
			{icon}
		</animated.span>
	)

	return (
		<animated.span
			className={cn(
				"inline-flex origin-left items-center gap-2 will-change-transform",
				className,
			)}
			style={{
				x: nudge.containerStyle.x,
				scale: nudge.containerStyle.scale,
			}}
		>
			{iconPosition === "leading" ? animatedIcon : null}
			{children}
			{iconPosition === "trailing" ? animatedIcon : null}
		</animated.span>
	)
}

export { SpringNudge }
