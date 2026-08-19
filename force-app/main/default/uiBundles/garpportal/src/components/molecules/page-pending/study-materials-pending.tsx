import { getRouteApi } from "@tanstack/react-router"

import { Skeleton } from "@/components/atoms/skeleton"
import type { ListView } from "@/config/list-view"
import { resolveStudyMaterialsView } from "@/config/study-materials"
import { useListViewStore } from "@/store/list-view-store"

const routeApi = getRouteApi("/_appLayout/study-materials/")

/**
 * Mirrors `StudyMaterialCard`: brand-washed artwork panel, code + status + type
 * chip row, title, three clamped paragraph lines, one meta row, then the CTA.
 * The real brand tint depends on the program, so the panel stays neutral until
 * data lands.
 */
function StudyMaterialCardSkeleton() {
	return (
		<Skeleton className="flex h-full flex-col gap-4 overflow-hidden rounded-xl border border-border bg-card">
			<div className="flex h-36 shrink-0 items-center justify-center bg-muted/40 p-4">
				<Skeleton className="size-24 rounded-xl" />
			</div>

			<div className="space-y-2 px-5 pt-1">
				<div className="flex items-center gap-2">
					<Skeleton className="h-5 w-12 rounded-md" />
					<Skeleton className="h-6 w-24 rounded-full" />
				</div>
				<Skeleton className="h-5 w-4/5" />
			</div>

			<div className="flex-1 space-y-3 px-5">
				<div className="space-y-2">
					<Skeleton className="h-3.5 w-full" />
					<Skeleton className="h-3.5 w-full" />
					<Skeleton className="h-3.5 w-3/4" />
				</div>
				<div className="flex items-center gap-2">
					<Skeleton className="size-4 rounded" />
					<Skeleton className="h-3.5 w-24" />
				</div>
			</div>

			<div className="mt-auto flex items-center gap-2 px-5 pb-5">
				<Skeleton className="h-4 w-28" />
				<Skeleton className="size-5 rounded-full" />
			</div>
		</Skeleton>
	)
}

/** Mirrors `StudyMaterialRow`: artwork thumb, chip row, title, meta, CTA. */
function StudyMaterialRowSkeleton() {
	return (
		<Skeleton className="flex flex-col gap-4 rounded-xl border border-border bg-card p-4 sm:flex-row sm:items-center">
			<Skeleton className="h-16 w-full shrink-0 rounded-lg sm:w-24" />
			<div className="min-w-0 flex-1 space-y-2">
				<div className="flex items-center gap-2">
					<Skeleton className="h-5 w-12 rounded-md" />
					<Skeleton className="h-6 w-24 rounded-full" />
				</div>
				<Skeleton className="h-5 w-3/5" />
				<Skeleton className="h-3.5 w-4/5" />
			</div>
			<div className="flex shrink-0 items-center gap-2 sm:flex-col sm:items-end">
				<Skeleton className="h-4 w-24" />
				<Skeleton className="size-5 rounded-full" />
			</div>
		</Skeleton>
	)
}

/** Matches the resolved layout so the skeleton has the same geometry as the page. */
function StudyMaterialsContentSkeleton({
	view = "grid",
}: {
	view?: ListView
}) {
	if (view === "list") {
		return (
			<div
				className="flex flex-col gap-3"
				aria-busy
				aria-label="Loading study materials"
			>
				{[0, 1, 2, 3].map((key) => (
					<StudyMaterialRowSkeleton key={key} />
				))}
			</div>
		)
	}

	return (
		<div
			className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
			aria-busy
			aria-label="Loading study materials"
		>
			{[0, 1, 2, 3, 4, 5].map((key) => (
				<StudyMaterialCardSkeleton key={key} />
			))}
		</div>
	)
}

/** Matches study-materials panel loading chrome + content skeleton. */
function StudyMaterialsPendingShell({ view }: { view?: ListView }) {
	return (
		<div className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]">
			<header className="shrink-0 space-y-4">
				<div className="flex flex-wrap items-center justify-between gap-3">
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
						Study Materials for Risk Professionals
					</h1>
					<Skeleton className="h-9 w-20 rounded-xl" />
				</div>
				<div className="flex flex-wrap gap-2">
					{[0, 1, 2, 3].map((key) => (
						<Skeleton key={key} className="h-9 w-24 rounded-xl" />
					))}
				</div>
			</header>
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				<StudyMaterialsContentSkeleton view={view} />
			</div>
		</div>
	)
}

function StudyMaterialsPending() {
	const { view } = routeApi.useSearch()
	// Same precedence as the panel, so the skeleton matches the layout that lands.
	const preferredView = useListViewStore(
		(state) => state.preferred["study-materials"],
	)
	return (
		<StudyMaterialsPendingShell
			view={resolveStudyMaterialsView(view, preferredView)}
		/>
	)
}

export {
	StudyMaterialsContentSkeleton,
	StudyMaterialsPending,
	StudyMaterialsPendingShell,
}
