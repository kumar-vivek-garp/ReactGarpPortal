import { useState } from "react"
import { animated, useSpring } from "@react-spring/web"
import { ChevronDown, ExternalLink } from "lucide-react"

import type { CpdActivity } from "@/api/cpd"
import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { buildActivityCardPresentation } from "@/lib/cpd-presentation"
import { cn } from "@/lib/utils"

const DETAIL_SPRING = { mass: 0.9, tension: 320, friction: 30 }

type CpdActivityCardProps = {
	activity: CpdActivity
	onSubmitCredits: (activity: CpdActivity) => void
	className?: string
}

/** One catalogue row, with details that expand in place. */
function CpdActivityCard({
	activity,
	onSubmitCredits,
	className,
}: CpdActivityCardProps) {
	const [open, setOpen] = useState(false)
	const presentation = buildActivityCardPresentation(activity)
	const hasDetail = Boolean(presentation.description || presentation.url)

	const detail = useSpring({
		opacity: open ? 1 : 0,
		maxHeight: open ? 400 : 0,
		config: DETAIL_SPRING,
	})

	const chevron = useSpring({
		rotate: open ? 180 : 0,
		config: DETAIL_SPRING,
	})

	return (
		<Card className={cn("gap-3 p-5 shadow-none", className)}>
			<div className="flex flex-wrap items-baseline justify-between gap-2">
				<p className="text-xs font-semibold tracking-wider text-primary uppercase">
					{activity.activityType}
				</p>
				<p className="text-sm font-semibold tabular-nums text-foreground">
					{presentation.creditsLabel}
				</p>
			</div>

			<div className="space-y-1">
				<h3 className="font-heading text-base leading-snug tracking-wide text-foreground">
					{presentation.title}
				</h3>
				{presentation.areasOfStudy ? (
					<p className="text-sm text-muted-foreground">
						{presentation.areasOfStudy}
					</p>
				) : null}
				{presentation.metaLine ? (
					<p className="text-sm text-muted-foreground">{presentation.metaLine}</p>
				) : null}
			</div>

			{hasDetail ? (
				<>
					<button
						type="button"
						onClick={() => setOpen((current) => !current)}
						aria-expanded={open}
						className="flex w-fit items-center gap-1.5 text-sm font-semibold text-primary hover:underline"
					>
						{open ? "Hide Details" : "View Details"}
						<animated.span
							className="inline-flex"
							style={{
								transform: chevron.rotate.to((value) => `rotate(${value}deg)`),
							}}
						>
							<ChevronDown className="size-4" aria-hidden />
						</animated.span>
					</button>

					<animated.div className="overflow-hidden" style={detail}>
						<div className="space-y-3 border-t border-border/60 pt-3">
							{presentation.description ? (
								<p className="text-sm text-muted-foreground">
									{presentation.description}
								</p>
							) : null}
							{presentation.url ? (
								<a
									href={presentation.url}
									target="_blank"
									rel="noreferrer noopener"
									className="inline-flex items-center gap-1.5 text-sm font-semibold text-primary hover:underline"
								>
									Visit Website
									<ExternalLink className="size-4" aria-hidden />
								</a>
							) : null}
						</div>
					</animated.div>
				</>
			) : null}

			<div className="flex justify-end pt-1">
				<Button type="button" size="sm" onClick={() => onSubmitCredits(activity)}>
					Submit Credits
				</Button>
			</div>
		</Card>
	)
}

export { CpdActivityCard }
