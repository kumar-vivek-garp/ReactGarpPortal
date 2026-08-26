import type { CaseSummary } from "@/api/help-center"
import { Card } from "@/components/atoms/card"
import { Skeleton } from "@/components/atoms/skeleton"
import { EmptyState } from "@/components/molecules/empty-state"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { StatusBadge } from "@/components/molecules/status-badge"
import { HELP_REQUESTS_EMPTY } from "@/config/help-center"
import {
	buildCasePresentation,
	type CasePresentation,
} from "@/lib/help-center-presentation"
import { cn } from "@/lib/utils"

/** Single source for the row columns — the skeleton below reuses it. */
const CASE_ROW_GRID =
	"sm:grid-cols-[minmax(0,7rem)_minmax(0,1fr)_minmax(0,8rem)_minmax(0,12rem)]"

const MOBILE_CELL_LABEL =
	"text-xs font-semibold tracking-wide text-muted-foreground uppercase sm:hidden"

function CaseRequestRow({ item }: { item: CasePresentation }) {
	return (
		<Card
			className={cn(
				// Non-interactive row — flat surface, no drill-in to invite.
				"grid grid-cols-1 gap-3 px-5 py-4 shadow-none",
				CASE_ROW_GRID,
				"sm:items-center sm:gap-4",
			)}
		>
			<div className="min-w-0">
				<p className={MOBILE_CELL_LABEL}>Case</p>
				<p className="truncate text-sm font-semibold tabular-nums text-primary">
					{item.caseNumber}
				</p>
			</div>

			<div className="min-w-0">
				<p className={MOBILE_CELL_LABEL}>Subject</p>
				<p className="text-sm text-foreground">{item.subject}</p>
			</div>

			<div className="min-w-0">
				<p className={MOBILE_CELL_LABEL}>Status</p>
				<StatusBadge
					label={item.statusLabel}
					tone={item.statusTone}
					className="max-w-full truncate"
				/>
			</div>

			<div className="min-w-0">
				<p className={MOBILE_CELL_LABEL}>Raised</p>
				{/* Age leads, exact timestamp supports it — see `caseAgeLabel`. */}
				<p className="text-sm text-foreground">{item.agoLabel ?? "—"}</p>
				{item.raisedLabel ? (
					<p className="text-xs text-muted-foreground">{item.raisedLabel}</p>
				) : null}
			</div>
		</Card>
	)
}

function HelpCenterRequests({
	cases,
	className,
}: {
	cases: CaseSummary[]
	className?: string
}) {
	const items = cases.map((item, index) => buildCasePresentation(item, index))

	if (items.length === 0) {
		return <EmptyState {...HELP_REQUESTS_EMPTY} className={className} />
	}

	return (
		<section className={cn("space-y-3", className)}>
			<div
				className={cn(
					"hidden gap-4 px-5 text-xs font-semibold tracking-wide text-muted-foreground uppercase sm:grid",
					CASE_ROW_GRID,
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
		</section>
	)
}

function CaseRequestRowSkeleton() {
	return (
		<Skeleton
			className={cn(
				"grid grid-cols-1 gap-3 rounded-xl border border-border bg-muted/40 px-5 py-4",
				CASE_ROW_GRID,
				"sm:items-center sm:gap-4",
			)}
		>
			<Skeleton className="h-4 w-20" />
			<Skeleton className="h-4 w-full max-w-xs" />
			<Skeleton className="h-6 w-16 rounded-full" />
			<Skeleton className="h-4 w-32" />
		</Skeleton>
	)
}

/** Mirrors `HelpCenterRequests` 1:1 — same grid string, same spacing. */
function HelpCenterRequestsSkeleton() {
	return (
		<section className="space-y-3" aria-busy aria-label="Loading your requests">
			<div
				className={cn("hidden gap-4 px-5 sm:grid", CASE_ROW_GRID)}
				aria-hidden
			>
				{[0, 1, 2, 3].map((col) => (
					<Skeleton key={col} className="h-2.5 w-12" />
				))}
			</div>
			{[0, 1, 2].map((row) => (
				<CaseRequestRowSkeleton key={row} />
			))}
		</section>
	)
}

export { CASE_ROW_GRID, HelpCenterRequests, HelpCenterRequestsSkeleton }
