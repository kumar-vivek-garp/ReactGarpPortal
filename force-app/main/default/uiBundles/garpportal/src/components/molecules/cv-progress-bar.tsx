import { animated, useSpring } from "@react-spring/web"

import type { CvProgressPresentation } from "@/lib/work-experience-presentation"
import { cn } from "@/lib/utils"

/** Matches the other meters in the app. */
const FILL_SPRING = { mass: 1, tension: 180, friction: 26 }
const COUNT_SPRING = { mass: 1, tension: 170, friction: 26 }

type CvProgressBarProps = {
	progress: CvProgressPresentation
	className?: string
}

/**
 * Months logged against the 24 the certification requires.
 *
 * Hand-rolled rather than an atom, matching `profile-completeness-meter` —
 * the bar paints from a token so dark mode needs no second palette, and
 * reduced motion is handled globally in `__root.tsx`.
 */
function CvProgressBar({ progress, className }: CvProgressBarProps) {
	const met = progress.remaining === 0

	const fill = useSpring({
		from: { width: "0%" },
		to: { width: `${progress.percent}%` },
		config: FILL_SPRING,
	})

	const count = useSpring({
		from: { value: 0 },
		to: { value: progress.logged },
		config: COUNT_SPRING,
	})

	return (
		<section
			className={cn(
				"rounded-xl border border-border bg-muted/30 p-5 shadow-sm",
				className,
			)}
		>
			<div className="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
				<p className="font-heading text-lg tracking-wide text-foreground">
					<animated.span className="tabular-nums">
						{count.value.to((value) => Math.round(value))}
					</animated.span>
					{met
						? " months logged"
						: ` of ${progress.required} months logged`}
				</p>
				<p
					className={cn(
						"text-sm font-semibold",
						met ? "text-success-green" : "text-muted-foreground",
					)}
				>
					{met
						? "Requirement met"
						: `${progress.remaining} to go`}
				</p>
			</div>

			<div
				className="mt-3 h-2 w-full overflow-hidden rounded-full bg-muted"
				role="progressbar"
				aria-valuenow={progress.logged}
				aria-valuemin={0}
				aria-valuemax={progress.required}
				aria-label="Work experience months logged"
			>
				<animated.div
					className={cn("h-full", met ? "bg-success-green" : "bg-primary")}
					style={fill}
				/>
			</div>
		</section>
	)
}

export { CvProgressBar }
