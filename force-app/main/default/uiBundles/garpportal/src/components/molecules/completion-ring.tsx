import type { ReactNode } from "react"
import { animated, useSpring } from "@react-spring/web"

import { Skeleton } from "@/components/atoms/skeleton"
import { cn } from "@/lib/utils"

/** Slow enough that the sweep reads as a fill, not a flicker. */
const RING_SPRING = { mass: 1, tension: 180, friction: 26 }

/*
 * The SVG works in a fixed 100-unit viewBox and scales to whatever box the
 * caller sizes, so stroke width and radius stay proportional at every size and
 * nothing needs an inline style.
 */
const VIEWBOX = 100
const STROKE = 5
const RADIUS = (VIEWBOX - STROKE) / 2
const CIRCUMFERENCE = 2 * Math.PI * RADIUS

/** Default footprint. Callers override with their own size utilities. */
const RING_SIZE = "size-22 app:size-28"

type CompletionRingProps = {
	/** 0–100. Clamped and rounded here so callers can pass raw Apex values. */
	percent: number
	/** Rendered inside the ring — normally the avatar. */
	children: ReactNode
	/** Sizing lives here; the SVG scales to whatever box it is given. */
	className?: string
	/** Accessible name for the progressbar role. */
	label?: string
}

/**
 * Radial profile-completeness meter that frames the avatar.
 *
 * Both circles paint with `stroke="currentColor"` driven by a Tailwind text
 * token, so light/dark comes for free and no colour is hardcoded.
 * Reduced motion is handled globally by `useReducedMotion()` in `pages/__root.tsx`.
 */
function CompletionRing({
	percent,
	children,
	className,
	label = "Profile completeness",
}: CompletionRingProps) {
	const clamped = Math.max(0, Math.min(100, Math.round(percent)))

	const ring = useSpring({
		from: { p: 0 },
		to: { p: clamped / 100 },
		config: RING_SPRING,
	})

	return (
		<div
			className={cn("relative shrink-0", RING_SIZE, className)}
			role="progressbar"
			aria-valuenow={clamped}
			aria-valuemin={0}
			aria-valuemax={100}
			aria-label={label}
		>
			<svg
				className="absolute inset-0 size-full -rotate-90"
				viewBox={`0 0 ${VIEWBOX} ${VIEWBOX}`}
				aria-hidden
			>
				<circle
					className="text-muted"
					cx={VIEWBOX / 2}
					cy={VIEWBOX / 2}
					r={RADIUS}
					fill="none"
					stroke="currentColor"
					strokeWidth={STROKE}
				/>
				<animated.circle
					className="text-primary"
					cx={VIEWBOX / 2}
					cy={VIEWBOX / 2}
					r={RADIUS}
					fill="none"
					stroke="currentColor"
					strokeWidth={STROKE}
					strokeLinecap="round"
					strokeDasharray={CIRCUMFERENCE}
					strokeDashoffset={ring.p.to((p) => CIRCUMFERENCE * (1 - p))}
				/>
			</svg>

			{/* Inset past the track so the avatar never sits under the stroke. */}
			<div className="absolute inset-[9%] flex items-center justify-center overflow-hidden rounded-full">
				{children}
			</div>

			<span className="absolute -bottom-1 left-1/2 -translate-x-1/2 rounded-full bg-primary px-2 py-0.5 text-xs font-bold text-primary-foreground shadow-sm">
				{clamped}%
			</span>
		</div>
	)
}

function CompletionRingSkeleton({ className }: { className?: string }) {
	return (
		<Skeleton
			className={cn("shrink-0 rounded-full", RING_SIZE, className)}
			aria-hidden
		/>
	)
}

export { CompletionRing, CompletionRingSkeleton, RING_SIZE }
