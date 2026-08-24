import { Pencil, Trash2, TriangleAlert } from "lucide-react"

import type { WorkExperience } from "@/api/work-experience"
import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { CV_ZERO_STATE } from "@/config/work-experience"
import { buildCvRowPresentation } from "@/lib/work-experience-presentation"
import { cn } from "@/lib/utils"

const TONE_CLASS = {
	valid: "text-success-green",
	warning: "text-garp-saffron",
	invalid: "text-destructive",
	neutral: "text-muted-foreground",
} as const

function CvEmptyState() {
	const Icon = CV_ZERO_STATE.icon
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-10 text-center">
			<Icon className="size-9 text-muted-foreground" aria-hidden />
			<p className="mt-3 font-heading text-base font-semibold tracking-wide text-foreground">
				{CV_ZERO_STATE.title}
			</p>
			<p className="mt-1 max-w-sm text-sm text-muted-foreground">
				{CV_ZERO_STATE.message}
			</p>
		</div>
	)
}

type CvExperienceListProps = {
	experiences: WorkExperience[]
	/** Omitted once the CV is submitted — the rows become read-only. */
	onEdit?: (experience: WorkExperience) => void
	onDelete?: (experience: WorkExperience) => void
	className?: string
}

/**
 * The logged roles.
 *
 * Per-row notes are rendered as text, not tooltips. The legacy hid both the
 * validation sentence and the overlap warning behind `matTooltip`, so on touch
 * a member could see a row worth zero months with no way to find out why.
 */
function CvExperienceList({
	experiences,
	onEdit,
	onDelete,
	className,
}: CvExperienceListProps) {
	if (experiences.length === 0) return <CvEmptyState />

	const hasActions = Boolean(onEdit || onDelete)

	return (
		<Card className={cn("gap-0 px-5 py-4 shadow-none", className)}>
			<ul className="divide-y divide-border/80">
				{experiences.map((experience, index) => {
					const row = buildCvRowPresentation(experience)
					return (
						<li
							key={row.id ?? `experience-${index}`}
							className="py-4 first:pt-0 last:pb-0"
						>
							<div className="flex flex-wrap items-start justify-between gap-x-4 gap-y-2">
								<div className="min-w-0 flex-1 space-y-0.5">
									<p className="font-heading text-base leading-snug tracking-wide text-foreground">
										{row.title}
									</p>
									{row.subtitle ? (
										<p className="text-sm text-muted-foreground">
											{row.subtitle}
										</p>
									) : null}
									<p className="text-sm text-muted-foreground">{row.period}</p>
								</div>

								<div className="flex shrink-0 items-center gap-3">
									<span
										className={cn(
											"text-sm font-semibold tabular-nums",
											TONE_CLASS[row.tone],
										)}
									>
										{row.monthsLabel}
									</span>
									{hasActions ? (
										<span className="flex items-center gap-1">
											{onEdit ? (
												<Button
													type="button"
													variant="ghost"
													size="icon-sm"
													aria-label={`Edit ${row.title}`}
													onClick={() => onEdit(experience)}
												>
													<Pencil className="size-4" />
												</Button>
											) : null}
											{onDelete ? (
												<Button
													type="button"
													variant="ghost"
													size="icon-sm"
													aria-label={`Delete ${row.title}`}
													className="text-muted-foreground hover:text-destructive"
													onClick={() => onDelete(experience)}
												>
													<Trash2 className="size-4" />
												</Button>
											) : null}
										</span>
									) : null}
								</div>
							</div>

							{row.overlapNote ? (
								<p className="mt-2 flex items-start gap-1.5 text-sm text-garp-saffron">
									<TriangleAlert className="mt-0.5 size-4 shrink-0" aria-hidden />
									{row.overlapNote}
								</p>
							) : null}

							{row.note ? (
								<p
									className={cn(
										"mt-1 text-sm",
										row.tone === "invalid"
											? "text-destructive"
											: "text-muted-foreground",
									)}
								>
									{row.note}
								</p>
							) : null}

							{row.needsDocuments ? (
								<p className="mt-1 text-sm text-destructive">
									Supporting documents are needed for this role.
								</p>
							) : null}
						</li>
					)
				})}
			</ul>
		</Card>
	)
}

export { CvExperienceList }
