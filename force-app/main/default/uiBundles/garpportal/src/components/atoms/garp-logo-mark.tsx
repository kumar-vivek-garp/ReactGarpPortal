import type * as React from "react"
import { useRef } from "react"
import { animated, useSpring } from "@react-spring/web"

import { usePrefersReducedMotion } from "@/hooks/use-prefers-reduced-motion"
import { cn } from "@/lib/utils"

/*
 * The GARP mark, inline so its colour follows the surface it sits on: every
 * shape inherits `currentColor` and only the hurricane's eye keeps brand cyan.
 * That replaces the knockout/colour PNG pair, which made each surface pick a
 * variant by hand — and the footer picked wrong in dark mode.
 *
 * Hovering spins the hurricane, as www.garp.org does. There it is a CSS
 * keyframe (0 → -25deg → 395deg → 360deg over 830ms, ease-in-out); here it is
 * two springs, so the wind-up and the overshoot are physics rather than fixed
 * stops, and an interrupted spin resolves instead of snapping back to 0.
 */

/** Degrees of anticipation before the mark whips round. */
const WIND_UP_DEG = 25
/** Brisk and settled — this leg only covers 25 degrees. */
const WIND_UP_SPRING = { mass: 0.5, tension: 520, friction: 26 }
/*
 * Underdamped, so the mark overshoots a full turn and eases back onto it.
 * Friction is solved, not guessed: overshoot is T·exp(-piZ/sqrt(1-Z^2)) for
 * travel T with Z = friction / 2*sqrt(tension*mass), and 18 puts the peak on
 * 395 degrees — where www.garp.org's own 75% keyframe sits.
 */
const SPIN_SPRING = { mass: 1.1, tension: 200, friction: 18 }
/*
 * viewBox units. This matches www.garp.org rather than the hurricane's true
 * centre (24.14, 22.04) — the ~2-unit offset gives the spin the slight orbit
 * the live mark has. `transformBox` is explicit because its initial value
 * changed from `border-box` to `view-box` partway through the spec.
 */
const HURRICANE_ORIGIN = "22px 22px"

type GarpLogoMarkProps = Omit<React.SVGProps<SVGSVGElement>, "children"> & {
	/** Accessible name. Pass `null` when an ancestor link already names it. */
	label?: string | null
	/** Spin the hurricane on hover. */
	spinOnHover?: boolean
}

function GarpLogoMark({
	label = "GARP",
	spinOnHover = true,
	className,
	...props
}: GarpLogoMarkProps) {
	const prefersReducedMotion = usePrefersReducedMotion()
	const [{ rotate }, api] = useSpring(() => ({ rotate: 0, config: SPIN_SPRING }))
	/*
	 * Turns accumulate instead of resetting to 0, so no hover ever starts with a
	 * snap. Touched only from the pointer handler, never during render.
	 */
	const spin = useRef({ busy: false, turns: 0 })

	function handlePointerEnter() {
		if (!spinOnHover || prefersReducedMotion || spin.current.busy) return
		spin.current.busy = true
		const from = spin.current.turns * 360
		spin.current.turns += 1
		const to = spin.current.turns * 360

		void api.start({
			to: async (next) => {
				await next({ rotate: from - WIND_UP_DEG, config: WIND_UP_SPRING })
				await next({ rotate: to, config: SPIN_SPRING })
				// An interrupted step resolves as cancelled rather than throwing, so
				// this always runs and the mark can never wedge itself busy.
				spin.current.busy = false
			},
		})
	}

	return (
		<svg
			xmlns="http://www.w3.org/2000/svg"
			viewBox="0 0 182.1 44.06"
			fill="currentColor"
			// The hurricane sweeps outside the viewBox mid-spin; clipping it looks broken.
			className={cn("overflow-visible", className)}
			role={label ? "img" : undefined}
			aria-label={label ?? undefined}
			aria-hidden={label ? undefined : true}
			onPointerEnter={handlePointerEnter}
			{...props}
		>
			<animated.g
				style={{
					transformBox: "view-box",
					transformOrigin: HURRICANE_ORIGIN,
					transform: rotate.to((deg) => `rotate(${deg}deg)`),
				}}
			>
				<path className="fill-garp-cyan" d="M29.03,21.93c0,2.7-2.18,4.89-4.88,4.89c-2.7,0-4.89-2.19-4.89-4.89c0-2.7,2.19-4.88,4.89-4.88 C26.84,17.05,29.03,19.23,29.03,21.93" />
				<path d="M30.06,43.53c-12.4-1.43-23.2-8.84-23.2-18.33c0-8.31,8.6-14.93,18.75-17.51c0,0,0.34-0.08,0.33-0.32 c-0.01-0.28-0.33-0.24-0.33-0.24C12.73,8.44,0,15.66,0,25.5c0,10.72,15.03,18.57,29.35,18.57c0.24,0,0.48,0,0.71-0.01 c0.38-0.02,0.35-0.28,0.35-0.28C30.41,43.55,30.06,43.53,30.06,43.53z" />
				<path d="M18.21,0.53c12.4,1.43,23.2,8.84,23.2,18.33c0,8.31-8.6,14.93-18.75,17.51c0,0-0.34,0.08-0.33,0.32 c0.01,0.28,0.33,0.24,0.33,0.24c12.88-1.31,25.61-8.53,25.61-18.37C48.27,7.85,33.25,0,18.92,0c-0.24,0-0.48,0-0.71,0.01 c-0.38,0.02-0.35,0.28-0.35,0.28C17.86,0.52,18.21,0.53,18.21,0.53z" />
			</animated.g>
			<g>
				<path d="M71.97,35.69c-3.17,0-5.84-0.58-8.02-1.76c-2.18-1.17-3.84-2.83-4.98-4.99c-1.14-2.15-1.71-4.71-1.71-7.66 c0-2.98,0.58-5.55,1.75-7.72c1.16-2.17,2.84-3.84,5.04-5.03c2.19-1.18,4.82-1.78,7.88-1.78c2,0,3.88,0.29,5.65,0.86 c1.76,0.57,3.22,1.36,4.39,2.37l-1.75,3.99c-1.27-0.98-2.57-1.69-3.9-2.11c-1.33-0.43-2.79-0.64-4.39-0.64 c-3.03,0-5.33,0.87-6.88,2.59c-1.56,1.73-2.34,4.22-2.34,7.46c0,3.27,0.8,5.76,2.4,7.46c1.6,1.7,3.97,2.55,7.11,2.55 c0.89,0,1.81-0.07,2.74-0.22c0.93-0.15,1.86-0.36,2.78-0.66v-6.54h-6.58v-3.79h10.93v13.53c-1.33,0.64-2.9,1.14-4.71,1.52 C75.56,35.5,73.76,35.69,71.97,35.69z" />
				<path d="M85.54,35.29L98.49,7.16h4.26l12.96,28.13h-5.28l-2.84-6.5H93.62l-2.8,6.5H85.54z M100.56,12.7L95.4,24.71 h10.4l-5.16-12.01H100.56z" />
				<path d="M119.33,35.29V7.16h12.43c3.14,0,5.56,0.74,7.27,2.21c1.71,1.48,2.56,3.54,2.56,6.2 c0,2.1-0.56,3.84-1.66,5.21c-1.11,1.37-2.71,2.29-4.79,2.77c1.38,0.43,2.52,1.45,3.41,3.07l4.79,8.66h-5.73l-4.95-8.98 c-0.49-0.88-1.06-1.48-1.73-1.8c-0.66-0.32-1.51-0.48-2.54-0.48h-3.86v11.25H119.33z M124.53,20.24h6.34 c3.79,0,5.69-1.52,5.69-4.55c0-3.01-1.9-4.51-5.69-4.51h-6.34V20.24z" />
				<path d="M149.9,35.29V7.16h12.43c3.14,0,5.56,0.77,7.27,2.31c1.71,1.54,2.56,3.7,2.56,6.46s-0.85,4.93-2.56,6.48 c-1.71,1.56-4.13,2.33-7.27,2.33h-7.23v10.53H149.9z M155.1,20.72h6.42c3.74,0,5.6-1.6,5.6-4.79c0-3.17-1.87-4.75-5.6-4.75h-6.42 V20.72z" />
				<path d="M179.04,13.28c-0.43,0-0.84-0.08-1.21-0.23c-0.37-0.15-0.7-0.37-0.98-0.65c-0.28-0.28-0.49-0.6-0.65-0.97 c-0.15-0.37-0.23-0.78-0.23-1.21c0-0.43,0.08-0.84,0.23-1.21c0.15-0.37,0.37-0.69,0.65-0.97c0.28-0.28,0.61-0.5,0.98-0.65 c0.37-0.15,0.77-0.23,1.21-0.23c0.44,0,0.84,0.08,1.21,0.23c0.37,0.15,0.69,0.37,0.97,0.65c0.28,0.28,0.5,0.6,0.65,0.97 c0.15,0.37,0.23,0.77,0.23,1.21c0,0.43-0.08,0.84-0.23,1.21c-0.15,0.37-0.37,0.7-0.65,0.97c-0.28,0.28-0.6,0.49-0.97,0.65 C179.88,13.2,179.48,13.28,179.04,13.28z M179.04,12.87c0.38,0,0.73-0.07,1.05-0.2c0.32-0.13,0.6-0.32,0.83-0.56 c0.24-0.24,0.42-0.52,0.55-0.85s0.2-0.67,0.2-1.05c0-0.5-0.11-0.95-0.34-1.35c-0.23-0.4-0.54-0.72-0.94-0.95 c-0.4-0.23-0.85-0.35-1.35-0.35c-0.38,0-0.73,0.07-1.04,0.2c-0.32,0.13-0.6,0.32-0.84,0.56c-0.24,0.24-0.43,0.52-0.56,0.84 c-0.13,0.32-0.2,0.67-0.2,1.05c0,0.38,0.07,0.73,0.2,1.05c0.13,0.32,0.32,0.6,0.56,0.85c0.24,0.24,0.52,0.43,0.84,0.56 C178.32,12.8,178.66,12.87,179.04,12.87z M177.78,12V8.43h1.5c0.39,0,0.69,0.09,0.9,0.28c0.21,0.19,0.31,0.44,0.31,0.76 c0,0.26-0.07,0.47-0.2,0.63c-0.13,0.16-0.32,0.27-0.56,0.33c0.1,0.03,0.19,0.09,0.26,0.18c0.07,0.09,0.13,0.21,0.17,0.36 l0.37,1.03h-0.69l-0.37-1.08c-0.05-0.13-0.12-0.22-0.21-0.26c-0.09-0.04-0.21-0.07-0.34-0.07h-0.45V12H177.78z M178.45,10.06 h0.74c0.43,0,0.65-0.19,0.65-0.56c0-0.37-0.22-0.56-0.65-0.56h-0.74V10.06z" />
			</g>
		</svg>
	)
}

export { GarpLogoMark }
