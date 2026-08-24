import { useMemo, useState } from "react"
import {
	ChevronLeft,
	ChevronRight,
	Loader2,
	Search,
	SlidersHorizontal,
	X,
} from "lucide-react"

import type { DirectoryMember } from "@/api/directory"
import { Badge } from "@/components/atoms/badge"
import { Button } from "@/components/atoms/button"
import { Input } from "@/components/atoms/input"
import { Skeleton } from "@/components/atoms/skeleton"
import { DirectoryFilterChips } from "@/components/molecules/directory-filter-chips"
import {
	DirectoryFiltersDialog,
	EMPTY_DIRECTORY_FILTERS,
	type DirectoryFilterState,
} from "@/components/molecules/directory-filters-dialog"
import { DirectoryMemberDialog } from "@/components/molecules/directory-member-dialog"
import { DirectoryMemberRow } from "@/components/molecules/directory-member-row"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import {
	DIRECTORY_NO_ACCESS,
	DIRECTORY_PAGE_SIZE,
	DIRECTORY_ZERO_STATE,
	MEMBER_DIRECTORY_TITLE,
} from "@/config/directory"
import { useAccountOptions } from "@/hooks/use-account-options"
import { useDebouncedValue } from "@/hooks/use-debounced-value"
import { useDirectory, useDirectorySearch } from "@/hooks/use-directory"
import { activeFilterCount } from "@/lib/directory-presentation"
import {
	directoryPageState,
	directoryUpsell,
	toDirectorySearchParams,
} from "@/lib/directory-presentation"
import { cn } from "@/lib/utils"

function EmptyState({
	state,
	action,
}: {
	state: typeof DIRECTORY_ZERO_STATE | typeof DIRECTORY_NO_ACCESS
	action?: React.ReactNode
}) {
	const Icon = state.icon
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-14 text-center">
			<Icon className="size-9 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{state.title}
			</p>
			<p className="mt-2 max-w-sm text-sm text-muted-foreground">
				{state.message}
			</p>
			{action ? <div className="mt-5">{action}</div> : null}
		</div>
	)
}

type MemberDirectoryPanelProps = {
	initialTerm?: string
	/** The membership tab owns its own heading; the standalone route does not. */
	showHeading?: boolean
	className?: string
}

/**
 * The Member Directory.
 *
 * Search runs as the member types, on a debounce — the old submit-driven form
 * made every exploratory search a two-step, which is the wrong shape for a
 * tool whose whole purpose is to browse. The input stays live while only the
 * query key trails, so typing never feels held back.
 *
 * Filters live in a dialog rather than inline. As a panel they were nearly
 * eighty checkboxes that pushed the results below the fold; the active ones
 * are surfaced as removable chips instead, so a narrow list always shows its
 * own reason.
 *
 * Search, paging and redaction are all the server's — Apex applies the
 * viewer's entitlements and each subject's privacy switches, and returns the
 * page counts. Nothing is filtered or counted here.
 */
function MemberDirectoryPanel({
	initialTerm = "",
	showHeading = true,
	className,
}: MemberDirectoryPanelProps) {
	const [term, setTerm] = useState(initialTerm)
	const [filters, setFilters] = useState<DirectoryFilterState>(
		EMPTY_DIRECTORY_FILTERS,
	)
	const [filtersOpen, setFiltersOpen] = useState(false)
	const [page, setPage] = useState(1)
	const [selected, setSelected] = useState<DirectoryMember | null>(null)

	const debouncedTerm = useDebouncedValue(term)
	const access = useDirectory()
	const options = useAccountOptions()

	const params = useMemo(
		() =>
			toDirectorySearchParams({
				searchText: debouncedTerm,
				company: filters.company,
				industries: filters.values.industries,
				jobFunctions: filters.values.jobFunctions,
				riskSpecialties: filters.values.riskSpecialties,
				corporateTitles: filters.values.corporateTitles,
				certifications: filters.certifications,
				pageCurrent: page,
				pageSize: DIRECTORY_PAGE_SIZE,
			}),
		[debouncedTerm, filters, page],
	)

	const canSearch = access.data?.hasDirectoryAccess === true
	const results = useDirectorySearch(params, canSearch)
	const paging = directoryPageState(results.data)
	const upsell = directoryUpsell(access.data)
	const advanced = access.data?.hasDirectoryAdvancedSearchAccess === true
	const filterCount = activeFilterCount(filters)

	/* Any change of criteria returns to page 1 — narrowing from page 4 would
	 * otherwise land on an empty page that reads as "no results". */
	const applyFilters = (next: DirectoryFilterState) => {
		setFilters(next)
		setPage(1)
	}
	const changeTerm = (next: string) => {
		setTerm(next)
		setPage(1)
	}

	const heading = showHeading ? (
		<header className="space-y-1">
			<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
				{MEMBER_DIRECTORY_TITLE}
			</h1>
			<p className="text-sm text-muted-foreground">
				Search members who chose to appear in the GARP directory.
			</p>
		</header>
	) : null

	if (!access.isLoading && access.data && !canSearch) {
		return (
			<div className={cn("space-y-6", className)}>
				{heading}
				<EmptyState
					state={DIRECTORY_NO_ACCESS}
					action={
						upsell ? (
							<Button asChild>
								<a
									href={
										upsell.orderId
											? `/order-details/${upsell.orderId}`
											: "/membership"
									}
								>
									{upsell.label}
								</a>
							</Button>
						) : null
					}
				/>
			</div>
		)
	}

	const members = results.data?.members ?? []
	// `isFetching` rather than `isLoading`: with kept previous data the list
	// stays put, so the only honest signal of work is the quiet one in the box.
	const isRefreshing = results.isFetching && !results.isLoading

	return (
		<div className={cn("space-y-5", className)}>
			{heading}

			<div className="space-y-3">
				<div className="flex gap-2">
					<div className="relative flex-1">
						<Search
							className="pointer-events-none absolute start-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground"
							aria-hidden
						/>
						<Input
							value={term}
							onChange={(event) => changeTerm(event.target.value)}
							placeholder="Search by name, city or country"
							aria-label="Search the member directory"
							className="ps-9 pe-9"
						/>
						{isRefreshing ? (
							<Loader2
								className="absolute end-3 top-1/2 size-4 -translate-y-1/2 animate-spin text-muted-foreground"
								aria-hidden
							/>
						) : term ? (
							<button
								type="button"
								onClick={() => changeTerm("")}
								className="absolute end-2.5 top-1/2 -translate-y-1/2 rounded-full p-0.5 text-muted-foreground hover:text-foreground"
							>
								<X className="size-4" aria-hidden />
								<span className="sr-only">Clear search</span>
							</button>
						) : null}
					</div>

					{advanced ? (
						<Button
							type="button"
							variant="outline"
							onClick={() => setFiltersOpen(true)}
						>
							<SlidersHorizontal className="size-4" aria-hidden />
							Filters
							{filterCount > 0 ? (
								<Badge className="ms-1 h-5 min-w-5 justify-center px-1 text-xs tabular-nums">
									{filterCount}
								</Badge>
							) : null}
						</Button>
					) : null}
				</div>

				<DirectoryFilterChips
					state={filters}
					onChange={applyFilters}
					onClearAll={() => applyFilters(EMPTY_DIRECTORY_FILTERS)}
				/>
			</div>

			{results.isLoading ? (
				<div className="space-y-2" aria-busy>
					{Array.from({ length: 5 }).map((_, index) => (
						<Skeleton key={index} className="h-16 w-full rounded-lg" />
					))}
				</div>
			) : null}

			{!results.isLoading && results.isError ? (
				<p className="text-sm text-muted-foreground">
					We couldn&apos;t run that search. Please try again later.
				</p>
			) : null}

			{!results.isLoading && !results.isError ? (
				members.length === 0 ? (
					<EmptyState
						state={DIRECTORY_ZERO_STATE}
						action={
							filterCount > 0 ? (
								<Button
									type="button"
									variant="outline"
									onClick={() => applyFilters(EMPTY_DIRECTORY_FILTERS)}
								>
									Clear {filterCount} {filterCount === 1 ? "filter" : "filters"}
								</Button>
							) : null
						}
					/>
				) : (
					<div className="space-y-4">
						{paging.rangeLabel ? (
							<p className="text-sm text-muted-foreground tabular-nums">
								{paging.rangeLabel}
							</p>
						) : null}

						{/*
						 * Each row is its own interactive Card, so they are spaced
						 * rather than wrapped in one — a card inside a card flattens
						 * the press motion the row is there to show.
						 */}
						<StaggerReveal className="space-y-2">
							{members.map((member, index) => (
								<DirectoryMemberRow
									key={member.id ?? `member-${index}`}
									member={member}
									onOpen={() => setSelected(member)}
								/>
							))}
						</StaggerReveal>

						{paging.pages > 1 ? (
							<div className="flex items-center justify-between">
								<Button
									type="button"
									variant="outline"
									size="sm"
									disabled={!paging.hasPrevious}
									onClick={() => setPage((current) => current - 1)}
								>
									<ChevronLeft className="size-4" aria-hidden />
									Previous
								</Button>
								<span className="text-sm text-muted-foreground tabular-nums">
									Page {paging.pageCurrent} of {paging.pages}
								</span>
								<Button
									type="button"
									variant="outline"
									size="sm"
									disabled={!paging.hasNext}
									onClick={() => setPage((current) => current + 1)}
								>
									Next
									<ChevronRight className="size-4" aria-hidden />
								</Button>
							</div>
						) : null}
					</div>
				)
			) : null}

			<DirectoryFiltersDialog
				open={filtersOpen}
				onOpenChange={setFiltersOpen}
				value={filters}
				onApply={applyFilters}
				picklists={options.data?.picklists}
			/>

			<DirectoryMemberDialog
				member={selected}
				onOpenChange={(open) => {
					if (!open) setSelected(null)
				}}
			/>
		</div>
	)
}

export { MemberDirectoryPanel }
