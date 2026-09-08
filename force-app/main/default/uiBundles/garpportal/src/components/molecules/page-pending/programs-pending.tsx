import { getRouteApi } from "@tanstack/react-router"

import { Skeleton } from "@/components/atoms/skeleton"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import {
	DEFAULT_PROGRAMS_TAB,
	PROGRAM_TAB_ITEMS,
	resolveProgramsView,
	type ProgramsTab,
	type ProgramsView,
} from "@/config/programs"
import { useListViewStore } from "@/store/list-view-store"
import { PAGE_SHELL, PAGE_STICKY_HEADER } from "@/components/molecules/page-shell"
import { cn } from "@/lib/utils"

const routeApi = getRouteApi("/_appLayout/programs/")

/**
 * Mirrors `ProgramCard`: brand-washed logo panel, code chip + status badge row,
 * title, two clamped description lines, one meta row, then the CTA. The real
 * brand tint depends on the program type, so the panel stays neutral until data
 * lands.
 */
function ProgramCardSkeleton() {
	return (
		<Skeleton className="flex h-full flex-col gap-4 overflow-hidden rounded-xl border border-border bg-card">
			<div className="flex h-36 shrink-0 items-center justify-center bg-muted/40 p-4">
				<Skeleton className="size-24 rounded-xl" />
			</div>

			<div className="space-y-2 px-5 pt-1">
				<div className="flex items-center gap-2">
					<Skeleton className="h-5 w-12 rounded-md" />
					<Skeleton className="h-6 w-28 rounded-full" />
				</div>
				<Skeleton className="h-5 w-4/5" />
			</div>

			<div className="flex-1 space-y-3 px-5">
				<div className="space-y-2">
					<Skeleton className="h-3.5 w-full" />
					<Skeleton className="h-3.5 w-3/4" />
				</div>
				<div className="flex items-center gap-2">
					<Skeleton className="size-4 rounded" />
					<Skeleton className="h-3.5 w-28" />
				</div>
			</div>

			<div className="mt-auto flex items-center gap-2 px-5 pb-5">
				<Skeleton className="h-4 w-24" />
				<Skeleton className="size-5 rounded-full" />
			</div>
		</Skeleton>
	)
}

/** Mirrors `ProgramRow`: logo thumb, chip row, title, description, meta, CTA. */
function ProgramRowSkeleton() {
	return (
		<Skeleton className="flex flex-col gap-4 rounded-xl border border-border bg-card p-4 sm:flex-row sm:items-center">
			<Skeleton className="h-16 w-full shrink-0 rounded-lg sm:w-24" />
			<div className="min-w-0 flex-1 space-y-2">
				<div className="flex items-center gap-2">
					<Skeleton className="h-5 w-12 rounded-md" />
					<Skeleton className="h-6 w-28 rounded-full" />
				</div>
				<Skeleton className="h-5 w-3/5" />
				<Skeleton className="h-3.5 w-4/5" />
				<div className="flex items-center gap-2">
					<Skeleton className="size-4 rounded" />
					<Skeleton className="h-3.5 w-24" />
				</div>
			</div>
			<div className="flex shrink-0 items-center gap-2 sm:flex-col sm:items-end">
				<Skeleton className="h-4 w-24" />
				<Skeleton className="size-5 rounded-full" />
			</div>
		</Skeleton>
	)
}

/** Matches the resolved layout so the skeleton has the same geometry as the page. */
function ProgramsContentSkeleton({ view = "grid" }: { view?: ProgramsView }) {
	if (view === "list") {
		return (
			<div
				className="flex flex-col gap-3"
				aria-busy
				aria-label="Loading programs"
			>
				{[0, 1, 2].map((key) => (
					<ProgramRowSkeleton key={key} />
				))}
			</div>
		)
	}

	return (
		<div
			className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
			aria-busy
			aria-label="Loading programs"
		>
			{[0, 1, 2, 3, 4, 5].map((key) => (
				<ProgramCardSkeleton key={key} />
			))}
		</div>
	)
}

type ProgramsPendingProps = {
	tab?: ProgramsTab
	view?: ProgramsView
}

/**
 * Programs loading chrome (tabs without counts) + content skeleton.
 *
 * With no explicit `tab` in the URL the resolved tab depends on data that has
 * not loaded yet, so no pill is marked active — better than flashing "All" and
 * snapping to "In Progress" a frame later.
 */
function ProgramsPendingShell({ tab, view }: ProgramsPendingProps) {
	// Same precedence as the panel, so the skeleton matches the layout that lands.
	const preferredView = useListViewStore((state) => state.preferred.programs)
	const resolvedView = resolveProgramsView(
		view,
		tab ?? DEFAULT_PROGRAMS_TAB,
		preferredView,
	)

	return (
		<Tabs
			value={tab ?? ""}
			className={PAGE_SHELL}
		>
			<header className={cn(PAGE_STICKY_HEADER, "space-y-4")}>
				<div className="flex flex-wrap items-center justify-between gap-3">
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
						My Programs
					</h1>
					<Skeleton className="h-9 w-20 rounded-xl" />
				</div>
				<PillTabs items={PROGRAM_TAB_ITEMS} value={tab ?? ""} />
			</header>
			<div>
				<ProgramsContentSkeleton view={resolvedView} />
			</div>
		</Tabs>
	)
}

function ProgramsPending() {
	const { tab, view } = routeApi.useSearch()
	return <ProgramsPendingShell tab={tab} view={view} />
}

export { ProgramsContentSkeleton, ProgramsPending, ProgramsPendingShell }
