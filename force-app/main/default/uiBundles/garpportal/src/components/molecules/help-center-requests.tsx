import type { CaseSummary } from "@/api/help-center"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { StatusBadge } from "@/components/molecules/status-badge"
import { HELP_CENTER_BUCKET_META } from "@/config/help-center"
import {
	buildCasePresentation,
	type CasePresentation,
} from "@/lib/help-center-presentation"
import { cn } from "@/lib/utils"

const ROW_GRID =
	"sm:grid-cols-[minmax(0,7rem)_minmax(0,1fr)_minmax(0,8rem)_minmax(0,12rem)]"

function CaseRequestRow({ item }: { item: CasePresentation }) {
	return (
		<div
			className={cn(
				"grid grid-cols-1 gap-3 rounded-xl border border-border bg-card px-5 py-4 shadow-none",
				ROW_GRID,
				"sm:items-center sm:gap-4",
			)}
		>
			<div className="min-w-0">
				<p className="text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:hidden">
					Case
				</p>
				<p className="truncate text-sm font-semibold tabular-nums text-primary">
					{item.caseNumber}
				</p>
			</div>

			<div className="min-w-0">
				<p className="text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:hidden">
					Subject
				</p>
				<p className="text-sm text-foreground">{item.subject}</p>
			</div>

			<div className="min-w-0">
				<p className="text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:hidden">
					Status
				</p>
				<StatusBadge
					label={item.statusLabel}
					tone={item.statusTone}
					className="max-w-full truncate"
				/>
			</div>

			<div className="min-w-0">
				<p className="text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:hidden">
					Raised
				</p>
				{/* Age leads, exact timestamp supports it — see `caseAgeLabel`. */}
				<p className="text-sm text-foreground">{item.agoLabel ?? "—"}</p>
				{item.raisedLabel ? (
					<p className="text-xs text-muted-foreground">{item.raisedLabel}</p>
				) : null}
			</div>
		</div>
	)
}

function HelpCenterRequestsEmpty() {
	const { icon: Icon, emptyTitle, emptyMessage } =
		HELP_CENTER_BUCKET_META.requests
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-16 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{emptyTitle}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">
				{emptyMessage}
			</p>
		</div>
	)
}

function HelpCenterRequests({
	cases,
	className,
	showHeading = true,
}: {
	cases: CaseSummary[]
	className?: string
	/** Hidden when the tab pill already names the section. */
	showHeading?: boolean
}) {
	const { icon: Icon, heading } = HELP_CENTER_BUCKET_META.requests
	const items = cases.map((item, index) => buildCasePresentation(item, index))

	return (
		<section className={cn("space-y-4", className)}>
			{showHeading ? (
				<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
					<Icon className="size-5 shrink-0 text-primary" aria-hidden />
					{heading}
					<span className="text-base font-normal text-muted-foreground">
						({items.length})
					</span>
				</h2>
			) : null}

			{items.length === 0 ? (
				<HelpCenterRequestsEmpty />
			) : (
				<div className="space-y-3">
					<div
						className={cn(
							"hidden gap-4 px-5 text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:grid",
							ROW_GRID,
						)}
						aria-hidden
					>
						<span>Case</span>
						<span>Subject</span>
						<span>Status</span>
						<span>Raised</span>
					</div>
					<StaggerReveal className="space-y-3">
						{items.map((item) => (
							<CaseRequestRow key={item.key} item={item} />
						))}
					</StaggerReveal>
				</div>
			)}
		</section>
	)
}

export { HelpCenterRequests }
