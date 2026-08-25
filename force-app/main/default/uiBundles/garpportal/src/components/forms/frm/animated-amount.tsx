import { animated, useSpring } from "@react-spring/web"

import { formatMoney } from "@/lib/account-format"
import { cn } from "@/lib/utils"

/** Slow enough that the figure reads as counting, not glitching. */
const COUNT_SPRING = { mass: 1, tension: 170, friction: 30 } as const
/** While waiting: no bounce, just a soft settle into the unsettled look. */
const SETTLE_SPRING = { mass: 0.8, tension: 280, friction: 26 } as const
/** On arrival: low friction so the scale overshoots and springs back. */
const POP_SPRING = { mass: 0.7, tension: 380, friction: 13 } as const

type AnimatedAmountProps = {
	amount: number | null | undefined
	currency: string
	/** True while a newer total is in flight and this figure is the old one. */
	pending: boolean
	className?: string
}

/**
 * A price that changes while you watch it.
 *
 * Three things happen, each doing a different job:
 *
 * - **It counts.** Jumping straight to the new figure gives no sense of which
 *   way it moved or by how much; travelling there does.
 * - **It blurs while waiting.** For a few hundred milliseconds the number is
 *   stale, and saying so is more honest than freezing it (which implies it is
 *   current) or blanking it (which loses the anchor and makes the panel jump).
 * - **It pops on arrival.** The scale eases up while pending and springs back
 *   with a low-friction config, so it overshoots slightly and settles. That
 *   overshoot is what pulls the eye to a figure in the corner of the screen.
 *
 * The blur and the pop are purely visual, so callers pair this with a written
 * "Updating…" and `aria-live` — nobody should have to see an animation to know
 * the total moved.
 */
function AnimatedAmount({
	amount,
	currency,
	pending,
	className,
}: AnimatedAmountProps) {
	const count = useSpring({ n: amount ?? 0, config: COUNT_SPRING })

	const emphasis = useSpring({
		blur: pending ? 3.5 : 0,
		opacity: pending ? 0.55 : 1,
		scale: pending ? 1.05 : 1,
		config: pending ? SETTLE_SPRING : POP_SPRING,
	})

	return (
		<animated.span
			// `inline-block` because a transform does nothing to an inline box.
			className={cn("inline-block tabular-nums", className)}
			style={{
				opacity: emphasis.opacity,
				filter: emphasis.blur.to((value) => `blur(${value}px)`),
				transform: emphasis.scale.to((value) => `scale(${value})`),
			}}
		>
			{count.n.to((value) => formatMoney(value, currency) ?? "")}
		</animated.span>
	)
}

export { AnimatedAmount }
