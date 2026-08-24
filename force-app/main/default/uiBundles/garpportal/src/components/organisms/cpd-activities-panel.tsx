import { useState } from "react"
import { Link, useNavigate } from "@tanstack/react-router"
import { ArrowLeft } from "lucide-react"

import type { CpdActivity } from "@/api/cpd"
import { CpdActivityCard } from "@/components/molecules/cpd-activity-card"
import {
	CpdActivityFilters,
	type CpdFacetValues,
} from "@/components/molecules/cpd-activity-filters"
import { CpdClaimDialog } from "@/components/molecules/cpd-claim-dialog"
import { CpdPagination } from "@/components/molecules/cpd-pagination"
import { Button } from "@/components/atoms/button"
import { SpringNudge } from "@/components/atoms/spring-nudge"
import { CpdActivitiesContentSkeleton } from "@/components/molecules/page-pending"
import { PageEnterFade } from "@/components/molecules/page-enter-fade"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import {
	CPD_ACTIVITIES_PAGE_SIZE,
	CPD_ACTIVITIES_TITLE,
	CPD_ACTIVITIES_ZERO_STATE,
	CPD_FACETS,
	DEFAULT_CPD_SORT,
	type CpdActivitiesSearch,
	type CpdFacetKey,
	type CpdSortOption,
} from "@/config/cpd"
import { useCpdActivities } from "@/hooks/use-cpd-activities"
import { useSpringNudge } from "@/hooks/use-spring-nudge"
import { activityToClaimSeed, pageCount } from "@/lib/cpd-presentation"
import { cn } from "@/lib/utils"

/**
 * Back to `/cpd` plus the page title.
 *
 * Deliberately not `ProgramsSubpageHeader` — that one only knows how to return
 * to the programs listing or a program detail, and widening it for a CPD page
 * would leave a "programs" component owning non-programs chrome.
 */
function CpdActivitiesHeader() {
	const nudge = useSpringNudge({ direction: "backward" })
	return (
		<header className="shrink-0 space-y-3">
			<Link
				to="/cpd"
				className="inline-flex text-lg font-bold text-foreground hover:text-primary"
				{...nudge.bind}
			>
				<SpringNudge
					nudge={nudge}
					icon={<ArrowLeft className="size-6" strokeWidth={2.5} />}
					iconPosition="leading"
				>
					CPD Credits
				</SpringNudge>
			</Link>
			<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
				{CPD_ACTIVITIES_TITLE}
			</h1>
		</header>
	)
}

function ActivitiesEmptyState() {
	const Icon = CPD_ACTIVITIES_ZERO_STATE.icon
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{CPD_ACTIVITIES_ZERO_STATE.title}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">
				{CPD_ACTIVITIES_ZERO_STATE.message}
			</p>
		</div>
	)
}

/**
 * A scoped id that matched nothing.
 *
 * Apex answers an unknown id with an empty list at 200, not an error, so this
 * is a genuine state rather than a failure — a stale bookmark, or an activity
 * that has since been deactivated.
 */
function ActivityNotFound({ onViewAll }: { onViewAll: () => void }) {
	const Icon = CPD_ACTIVITIES_ZERO_STATE.icon
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				This activity is no longer listed
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">
				It may have been withdrawn, or the link may be out of date.
			</p>
			<Button
				type="button"
				variant="outline"
				className="mt-5"
				onClick={onViewAll}
			>
				Browse all activities
			</Button>
		</div>
	)
}

type CpdActivitiesPanelProps = CpdActivitiesSearch & { className?: string }

/**
 * Browse Credit Opportunities.
 *
 * All of sort, facets and page live in the URL, so a filtered result is
 * shareable and Back steps through pages. Each combination is its own query
 * key, which makes revisiting a page a cache hit rather than a refetch.
 */
function CpdActivitiesPanel({
	activityId,
	type,
	area,
	provider,
	sort,
	page,
	className,
}: CpdActivitiesPanelProps) {
	const navigate = useNavigate({ from: "/cpd/activities/" })
	const [seed, setSeed] = useState<CpdActivity | null>(null)
	const singleId = activityId?.trim() || undefined

	const selected: CpdFacetValues = {
		type: type ?? [],
		area: area ?? [],
		provider: provider ?? [],
	}
	const activeSort: CpdSortOption = sort ?? DEFAULT_CPD_SORT
	const activePage = page ?? 1

	/*
	 * With an id, the facets and paging are not sent at all — Apex ignores them
	 * — so the sidebar and paginator are hidden rather than left showing
	 * controls that would do nothing.
	 */
	const { data, isLoading, isError, isFetching } = useCpdActivities(
		singleId
			? { activityId: singleId }
			: {
					activityTypes: selected.type,
					areasOfStudy: selected.area,
					providers: selected.provider,
					sortOrder: activeSort,
					pageSize: CPD_ACTIVITIES_PAGE_SIZE,
					pageCurrent: activePage,
				},
	)

	/** Drops the scope AND the URL with it — the legacy left the address stale. */
	const viewAllActivities = () => {
		void navigate({ search: (prev) => ({ ...prev, activityId: undefined }) })
	}

	const activities = data?.cpdActivities ?? []
	const totalPages = pageCount(data?.totalCount ?? 0, CPD_ACTIVITIES_PAGE_SIZE)

	/** Any filter change resets to page 1 — page 6 of the old result set is meaningless. */
	const toggleFacet = (facet: CpdFacetKey, value: string, checked: boolean) => {
		const next = checked
			? [...selected[facet], value]
			: selected[facet].filter((entry) => entry !== value)
		void navigate({
			search: (prev) => ({
				...prev,
				[facet]: next.length > 0 ? next : undefined,
				page: undefined,
			}),
			replace: true,
		})
	}

	return (
		<PageEnterFade className={cn("space-y-6", className)}>
			<CpdActivitiesHeader />

			{isLoading ? <CpdActivitiesContentSkeleton /> : null}

			{!isLoading && isError ? (
				<p className="text-sm text-muted-foreground">
					We couldn&apos;t load credit opportunities. Please try again later.
				</p>
			) : null}

			{!isLoading && !isError ? (
				<div
					className={cn(
						"grid items-start gap-6",
						singleId ? null : "app:grid-cols-[minmax(0,1fr)_18rem]",
					)}
				>
					<div className="min-w-0 space-y-4">
						{singleId ? (
							<Button
								type="button"
								variant="outline"
								size="sm"
								onClick={viewAllActivities}
							>
								<ArrowLeft className="size-4" aria-hidden />
								View all activities
							</Button>
						) : null}

						{activities.length === 0 ? (
							singleId ? (
								<ActivityNotFound onViewAll={viewAllActivities} />
							) : (
								<ActivitiesEmptyState />
							)
						) : (
							<>
								<StaggerReveal className="flex flex-col gap-4">
									{activities.map((activity) => (
										<CpdActivityCard
											key={activity.id}
											activity={activity}
											onSubmitCredits={setSeed}
											showPermalink={!singleId}
										/>
									))}
								</StaggerReveal>
								{singleId ? null : (
								<CpdPagination
									page={activePage}
									pageSize={CPD_ACTIVITIES_PAGE_SIZE}
									pageCount={totalPages}
									totalCount={data?.totalCount ?? 0}
									busy={isFetching}
									onPageChange={(next) => {
										void navigate({
											search: (prev) => ({
												...prev,
												page: next === 1 ? undefined : next,
											}),
										})
									}}
								/>
								)}
							</>
						)}
					</div>

					{singleId ? null : (
					<CpdActivityFilters
						options={{
							type: data?.activityTypes ?? [],
							area: data?.areasOfStudy ?? [],
							provider: data?.providers ?? [],
						}}
						selected={selected}
						sort={activeSort}
						onToggle={toggleFacet}
						onSortChange={(next) => {
							void navigate({
								search: (prev) => ({
									...prev,
									sort: next === DEFAULT_CPD_SORT ? undefined : next,
									page: undefined,
								}),
								replace: true,
							})
						}}
						onClear={() => {
							void navigate({
								search: (prev) => ({
									...prev,
									...Object.fromEntries(
										CPD_FACETS.map((facet) => [facet.key, undefined]),
									),
									page: undefined,
								}),
								replace: true,
							})
						}}
					/>
					)}
				</div>
			) : null}

			{/* Picking an activity opens the Phase B form, pre-filled. */}
			<CpdClaimDialog
				open={seed !== null}
				onOpenChange={(next) => {
					if (!next) setSeed(null)
				}}
				claim={seed ? activityToClaimSeed(seed) : null}
			/>
		</PageEnterFade>
	)
}

export { CpdActivitiesPanel }
