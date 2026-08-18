import { Check, Circle, CircleDot, OctagonAlert } from "lucide-react"

import type { JourneyMilestone } from "@/lib/program-detail-presentation"
import { cn } from "@/lib/utils"

type ProgramJourneyProps = {
	milestones: JourneyMilestone[]
	className?: string
}

const STATUS_ICON = {
	complete: Check,
	current: CircleDot,
	upcoming: Circle,
	blocked: OctagonAlert,
} as const

const STATUS_CLASS = {
	complete: "bg-success-green/15 text-success-green",
	current: "bg-primary/15 text-primary",
	upcoming: "bg-muted text-muted-foreground",
	blocked: "bg-pink text-pink-foreground",
} as const

function ProgramJourney({ milestones, className }: ProgramJourneyProps) {
	if (milestones.length === 0) return null

	return (
		<section
			className={cn(
				"rounded-xl border border-border bg-card p-5 shadow-none",
				className,
			)}
			aria-label="Program journey"
		>
			<h2 className="font-heading text-lg tracking-wide text-foreground">
				Your journey
			</h2>
			<ol className="mt-4 space-y-0">
				{milestones.map((step, index) => {
					const Icon = STATUS_ICON[step.status]
					const isLast = index === milestones.length - 1
					return (
						<li key={step.id} className="relative flex gap-3 pb-5 last:pb-0">
							{!isLast ? (
								<span
									className="absolute top-9 bottom-0 left-[1.05rem] w-px bg-border"
									aria-hidden
								/>
							) : null}
							<span
								className={cn(
									"relative z-10 flex size-9 shrink-0 items-center justify-center rounded-full",
									STATUS_CLASS[step.status],
								)}
							>
								<Icon className="size-4" aria-hidden />
							</span>
							<div className="min-w-0 pt-1.5">
								<p className="text-sm font-semibold text-foreground">
									{step.label}
									<span className="sr-only"> — {step.status}</span>
								</p>
								{step.detail ? (
									<p className="mt-0.5 text-sm text-muted-foreground">
										{step.detail}
									</p>
								) : null}
							</div>
						</li>
					)
				})}
			</ol>
		</section>
	)
}

export { ProgramJourney }
