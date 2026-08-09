import { animated, useSpring } from "@react-spring/web"

import { Skeleton } from "@/components/atoms/skeleton"
import { cn } from "@/lib/utils"

const METER_SPRING = { mass: 0.9, tension: 280, friction: 28 }

type ProfileCompletenessMeterProps = {
	percent: number
	missing?: string[]
	className?: string
}

function ProfileCompletenessMeterSkeleton({ className }: { className?: string }) {
	return (
		<div className={cn("space-y-2", className)} aria-hidden>
			<Skeleton className="h-6 w-full rounded-lg" />
			<Skeleton className="h-3 w-3/4 max-w-xs rounded-sm" />
		</div>
	)
}

function ProfileCompletenessMeter({
	percent,
	missing,
	className,
}: ProfileCompletenessMeterProps) {
	const clamped = Math.max(0, Math.min(100, Math.round(percent)))

	const enter = useSpring({
		from: { opacity: 0, transform: "translateY(6px)" },
		to: { opacity: 1, transform: "translateY(0px)" },
		config: METER_SPRING,
	})

	const fill = useSpring({
		from: { width: "0%" },
		to: { width: `${clamped}%` },
		config: { mass: 1, tension: 180, friction: 26 },
	})

	return (
		<animated.div className={cn("space-y-2", className)} style={enter}>
			<div
				className="relative h-6 w-full overflow-hidden rounded-lg bg-muted"
				role="progressbar"
				aria-valuenow={clamped}
				aria-valuemin={0}
				aria-valuemax={100}
				aria-label="Profile completeness"
			>
				<animated.div className="h-full bg-primary" style={fill} />
				<span className="absolute inset-y-0 right-2 flex items-center text-xs font-bold text-foreground">
					{clamped}%
				</span>
			</div>

			{missing && missing.length > 0 ? (
				<p className="text-xs text-muted-foreground">
					Still needed: {missing.slice(0, 3).join(", ")}
					{missing.length > 3 ? ` and ${missing.length - 3} more` : null}
				</p>
			) : null}
		</animated.div>
	)
}

export { ProfileCompletenessMeter, ProfileCompletenessMeterSkeleton }
