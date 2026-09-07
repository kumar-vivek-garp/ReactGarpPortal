import { CalendarCheck, CalendarDays, ListChecks, MapPin } from "lucide-react"
import type { LucideIcon } from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Separator } from "@/components/atoms/separator"
import { StatusBadge } from "@/components/molecules/status-badge"
import { EXAM_SETUP_NEXT_STEPS, EXAM_SETUP_RAIL_TITLE } from "@/config/exam-setup"
import { programBrandSurface } from "@/config/program-brand"
import type { SittingPartSummary } from "@/lib/exam-setup-presentation"
import { cn } from "@/lib/utils"

/** Container geometry is coupled to `REGISTRATION_RAIL_COLUMN`'s `top-22` — see registration-shell.ts. */
const RAIL =
	"flex max-h-[calc(100vh-13.5rem)] flex-col gap-4 overflow-y-auto [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"

function Fact({
	icon: Icon,
	label,
	value,
	was,
}: {
	icon: LucideIcon
	label: string
	value: string | null
	/** The value on record, when the choice differs from it. */
	was: string | null
}) {
	return (
		<div className="flex items-start gap-3 text-sm text-foreground">
			<Icon className="mt-0.5 size-4 shrink-0 text-muted-foreground" aria-hidden />
			<div className="flex min-w-0 flex-1 flex-col gap-0.5">
				<span className="text-caption text-muted-foreground">{label}</span>
				<span className="flex flex-wrap items-center gap-2">
					<span className={cn("font-medium", !value && "text-muted-foreground italic")}>
						{value ?? "Not chosen yet"}
					</span>
					{was ? <StatusBadge tone="warning" label="Changed" /> : null}
				</span>
				{was ? (
					<span className="text-caption text-muted-foreground">was {was}</span>
				) : null}
			</div>
		</div>
	)
}

/** The shape of the summary before anything is chosen, so the card does not read as a failed load. */
function GhostFacts() {
	return (
		<div className="flex flex-col gap-3" aria-hidden>
			{["Exam date", "Exam site"].map((label) => (
				<div
					key={label}
					className="flex items-center justify-between gap-4 text-body text-muted-foreground/60"
				>
					<span>{label}</span>
					<span>&mdash;</span>
				</div>
			))}
		</div>
	)
}

type ExamSetupRailProps = {
	programType: string
	parts: SittingPartSummary[]
	className?: string
}

/**
 * The pinned summary beside the form: where the member will sit, live, with
 * every departure from the record called out — and the three things that
 * happen after Save, told before they commit to it. The fee lives here now:
 * nothing prices a change before the save, so the rail is where a member
 * learns that moving their date costs money.
 */
function ExamSetupRail({ programType, parts, className }: ExamSetupRailProps) {
	const brand = programBrandSurface(programType)

	return (
		<div className={cn(RAIL, className)}>
			<Card className="overflow-hidden">
				<CardHeader className={cn("-mt-6 pt-6 pb-4", brand.surface)}>
					<CardTitle className="flex items-center gap-2 text-base">
						<CalendarCheck className="size-4 text-muted-foreground" aria-hidden />
						{EXAM_SETUP_RAIL_TITLE}
					</CardTitle>
				</CardHeader>
				<CardContent className="flex flex-col gap-4">
					{parts.map((part, index) => (
						<div key={part.label} className="flex flex-col gap-3">
							{index > 0 ? <Separator /> : null}
							{parts.length > 1 ? (
								<p className="text-caption font-semibold tracking-wider text-muted-foreground uppercase">
									{part.label}
								</p>
							) : null}
							{part.admin.chosen ? (
								<>
									<Fact
										icon={CalendarDays}
										label="Exam date"
										value={part.admin.chosen}
										was={part.admin.changed ? part.admin.current : null}
									/>
									<Fact
										icon={MapPin}
										label="Exam site"
										value={part.site.chosen}
										was={part.site.changed ? part.site.current : null}
									/>
								</>
							) : (
								<GhostFacts />
							)}
						</div>
					))}
				</CardContent>
			</Card>

			<Card>
				<CardHeader>
					<CardTitle className="flex items-center gap-2 text-base">
						<ListChecks className="size-4 text-muted-foreground" aria-hidden />
						{EXAM_SETUP_NEXT_STEPS.title}
					</CardTitle>
				</CardHeader>
				<CardContent>
					<ol className="flex flex-col gap-3">
						{EXAM_SETUP_NEXT_STEPS.steps.map((step, index) => (
							<li key={step} className="flex items-start gap-3 text-sm">
								<span
									className="flex size-7 shrink-0 items-center justify-center rounded-full bg-primary/15 text-xs font-semibold text-primary tabular-nums"
									aria-hidden
								>
									{index + 1}
								</span>
								<span className="pt-1 text-foreground">{step}</span>
							</li>
						))}
					</ol>
				</CardContent>
			</Card>
		</div>
	)
}

export { ExamSetupRail }
