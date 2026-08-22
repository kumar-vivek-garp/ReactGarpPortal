import { animated, useSpring } from "@react-spring/web"

import { Skeleton } from "@/components/atoms/skeleton"
import { CPD_DESIGNATION_META } from "@/config/cpd"
import type { CpdCreditBarRow } from "@/lib/cpd-presentation"
import { cn } from "@/lib/utils"

/** Matches `CompletionRing` — slow enough to read as a fill, not a flicker. */
const BAR_SPRING = { mass: 1, tension: 180, friction: 26 }

/*
 * Each bar is its own 100-unit-wide viewBox stretched to the column, so widths
 * are plain percentages of a shared maximum and nothing needs an inline style.
 * `preserveAspectRatio="none"` is what lets one flat coordinate space stretch;
 * it also rules out rounded corners, which it would visibly distort.
 */
const VIEWBOX_WIDTH = 100
const VIEWBOX_HEIGHT = 8

type CpdCreditBarProps = {
	row: CpdCreditBarRow
	/** Shared across every bar so 20/20 reads as half of 40/40. */
	scale: number
}

/**
 * One designation's bar. A separate component rather than a `.map` body so the
 * spring hook count stays static when the row list changes.
 */
function CpdCreditBar({ row, scale }: CpdCreditBarProps) {
	const meta = CPD_DESIGNATION_META[row.designation]
	const approved = Math.max(0, Math.min(row.approved, scale))
	const remaining = Math.max(0, row.required - row.approved)

	const fill = useSpring({
		from: { w: 0 },
		to: { w: (approved / scale) * VIEWBOX_WIDTH },
		config: BAR_SPRING,
	})

	return (
		<li className="grid grid-cols-[2.75rem_minmax(0,1fr)_auto] items-center gap-3">
			<span className="text-xs font-semibold tracking-wide text-muted-foreground">
				{meta.label}
			</span>

			<svg
				className="h-2 w-full"
				viewBox={`0 0 ${VIEWBOX_WIDTH} ${VIEWBOX_HEIGHT}`}
				preserveAspectRatio="none"
				aria-hidden
			>
				{/*
				 * The remainder is drawn only when credits are still owed — the
				 * legacy pushed a null for `required - approved <= 0`, so a met
				 * requirement shows a solid bar with no grey tail.
				 */}
				{remaining > 0 ? (
					<animated.rect
						className="text-muted"
						x={fill.w}
						y={0}
						width={fill.w.to((w) =>
							Math.max(0, (row.required / scale) * VIEWBOX_WIDTH - w),
						)}
						height={VIEWBOX_HEIGHT}
						fill="currentColor"
					/>
				) : null}
				<animated.rect
					className={meta.barClassName}
					x={0}
					y={0}
					width={fill.w}
					height={VIEWBOX_HEIGHT}
					fill="currentColor"
				/>
			</svg>

			<span className="text-xs font-semibold tabular-nums text-foreground">
				{row.approved} / {row.required}
			</span>
		</li>
	)
}

type CpdCreditBarsProps = {
	rows: CpdCreditBarRow[]
	className?: string
}

/**
 * Credits approved against credits required, one bar per certification.
 *
 * Every bar shares one x-scale, so a 20-credit SCR requirement is visibly half
 * a 40-credit FRM one. Normalising each row to its own 100% — the obvious
 * shortcut — would render the same 20 approved credits at two different
 * lengths and misstate the member's position.
 *
 * Colour comes from `fill="currentColor"` over a Tailwind brand token, the
 * same trick `CompletionRing` uses, so dark mode needs no second palette.
 * Reduced motion is handled globally by `useReducedMotion()` in `__root.tsx`.
 */
function CpdCreditBars({ rows, className }: CpdCreditBarsProps) {
	if (rows.length === 0) return null

	const scale = Math.max(
		...rows.flatMap((row) => [row.required, row.approved]),
		1,
	)

	return (
		<ul className={cn("space-y-3", className)}>
			{rows.map((row) => (
				<CpdCreditBar key={row.designation} row={row} scale={scale} />
			))}
		</ul>
	)
}

function CpdCreditBarsSkeleton({
	rows = 2,
	className,
}: {
	rows?: number
	className?: string
}) {
	return (
		<div className={cn("space-y-3", className)} aria-hidden>
			{Array.from({ length: rows }, (_, index) => (
				<Skeleton key={index} className="h-2 w-full rounded-sm" />
			))}
		</div>
	)
}

export { CpdCreditBars, CpdCreditBarsSkeleton }
