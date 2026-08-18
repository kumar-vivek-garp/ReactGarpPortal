import { Skeleton } from "@/components/atoms/skeleton"
import { cn } from "@/lib/utils"

type DashboardCardSkeletonProps = {
	withImage?: boolean
	body?: "meter" | "search" | "lines"
}

function DashboardCardSkeleton({
	withImage = false,
	body = "lines",
}: DashboardCardSkeletonProps) {
	return (
		<Skeleton
			className={cn(
				"flex flex-col overflow-hidden rounded-xl border border-border bg-muted/40",
			)}
		>
			{withImage ? <Skeleton className="h-40 w-full rounded-none" /> : null}

			<div className="space-y-3 px-5 pt-5 pb-4">
				<div className="flex items-start gap-2">
					{!withImage ? (
						<Skeleton className="mt-0.5 size-5 shrink-0 rounded-full" />
					) : null}
					<div className="min-w-0 flex-1 space-y-2">
						{withImage ? <Skeleton className="h-3.5 w-40" /> : null}
						<Skeleton className="h-5 w-3/5 max-w-xs" />
					</div>
				</div>

				{body === "meter" ? (
					<>
						<Skeleton className="h-6 w-full rounded-lg" />
						<Skeleton className="h-3 w-4/5 max-w-sm" />
						<Skeleton className="h-3 w-full" />
						<Skeleton className="h-3 w-2/3" />
					</>
				) : null}

				{body === "search" ? (
					<>
						<Skeleton className="h-3 w-full" />
						<Skeleton className="h-3 w-5/6" />
						<Skeleton className="h-10 w-full rounded-xl" />
					</>
				) : null}

				{body === "lines" ? (
					<>
						<Skeleton className="h-3 w-full" />
						<Skeleton className="h-3 w-4/5" />
					</>
				) : null}
			</div>

			<div className="mt-auto border-t border-border/60 px-5 py-4">
				<Skeleton className="h-5 w-36" />
			</div>
		</Skeleton>
	)
}

/** Matches dashboard panel React Query loading UI. */
function DashboardPending() {
	return (
		<div className="space-y-6" aria-busy aria-label="Loading dashboard">
			<div className="space-y-2">
				<Skeleton className="h-3 w-24" />
				<Skeleton className="h-9 w-48 max-w-full" />
				<Skeleton className="h-4 w-80 max-w-full" />
			</div>
			<div className="grid gap-6 sm:grid-cols-2 xl:grid-cols-3">
				<DashboardCardSkeleton body="lines" />
				<DashboardCardSkeleton body="lines" />
				<DashboardCardSkeleton body="search" />
			</div>
		</div>
	)
}

export { DashboardPending }
