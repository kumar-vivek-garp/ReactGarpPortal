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
			{/*
			 * A rail down the side on a phone, a stepper across the card on a
			 * desktop — the same markup, re-laid-out. Four or five one-word steps
			 * stacked vertically left the right two-thirds of this card empty and
			 * pushed the exam cards below the fold (UI/UX request, Sep 2026).
			 *
			 * `auto-cols-fr` rather than a fixed column count: a journey is four
			 * steps normally and five once it reaches Certification or Work
			 * experience, and the columns have to stay even either way.
			 */}
			<ol className="mt-4 space-y-0 app:grid app:grid-flow-col app:auto-cols-fr">
				{milestones.map((step, index) => {
					const Icon = STATUS_ICON[step.status]
					const isLast = index === milestones.length - 1
					return (
						<li
							key={step.id}
							className={cn(
								"relative flex gap-3 pb-5 last:pb-0",
								"app:flex-col app:items-center app:gap-2 app:pb-0 app:text-center",
							)}
						>
							{!isLast ? (
								/*
								 * Runs from this step's centre to the next one's, so it
								 * is a full column wide starting at the halfway mark.
								 * It passes UNDER both icons, which are opaque and
								 * raised, so no end ever shows.
								 */
								<span
									className={cn(
										"absolute bg-border",
										"top-9 bottom-0 left-[1.05rem] w-px",
										"app:top-[1.125rem] app:bottom-auto app:left-1/2 app:h-px app:w-full",
									)}
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
							{/*
							 * The columns sit flush so the rail can reach across them,
							 * so the breathing room between two steps' text is padding
							 * here rather than a grid gap.
							 */}
							<div className="min-w-0 pt-1.5 app:px-2 app:pt-0">
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
