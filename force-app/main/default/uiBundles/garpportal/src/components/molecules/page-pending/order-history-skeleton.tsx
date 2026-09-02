import { Skeleton } from "@/components/atoms/skeleton"

/** Mirrors `OrderRow` — icon tile, title + meta run, trailing amount/badge/action. */
function OrderRowSkeleton() {
	return (
		<Skeleton className="flex flex-col gap-4 rounded-xl border border-primary/20 bg-card p-4 sm:flex-row sm:items-center">
			<Skeleton className="size-11 shrink-0 rounded-lg" />

			<div className="min-w-0 flex-1 space-y-1.5">
				<Skeleton className="h-5 w-3/5 max-w-xs rounded-sm" />
				<div className="flex flex-wrap gap-x-4 gap-y-1">
					<Skeleton className="h-3.5 w-24 rounded-sm" />
					<Skeleton className="h-3.5 w-28 rounded-sm" />
					<Skeleton className="h-3.5 w-20 rounded-sm" />
				</div>
			</div>

			<div className="flex shrink-0 flex-wrap items-center gap-x-4 gap-y-2 sm:flex-col sm:items-end">
				<Skeleton className="h-5 w-20 rounded-sm" />
				<Skeleton className="h-6 w-16 rounded-full" />
				<Skeleton className="h-8 w-20 rounded-xl" />
			</div>
		</Skeleton>
	)
}

function OrderHistorySkeleton() {
	return (
		<div className="space-y-6" aria-busy aria-label="Loading orders">
			{/* Summary bar — one slim strip of inline stats. */}
			<Skeleton className="flex flex-col gap-y-3 rounded-xl border border-primary/20 bg-card px-5 py-4 sm:flex-row sm:flex-wrap sm:items-center sm:gap-x-6 sm:py-3.5">
				<div className="flex flex-wrap items-center justify-between gap-3 sm:flex-1 sm:justify-start">
					<Skeleton className="h-3 w-24 rounded-sm" />
					<Skeleton className="h-7 w-24 rounded-sm" />
					<Skeleton className="h-8 w-full rounded-xl sm:w-20" />
				</div>
				{[0, 1].map((stat) => (
					<div
						key={stat}
						className="flex items-center justify-between gap-2.5 sm:flex-1 sm:justify-start"
					>
						<Skeleton className="h-3 w-16 rounded-sm" />
						<Skeleton className="h-7 w-10 rounded-sm" />
					</div>
				))}
			</Skeleton>

			{/* Toolbar — search + filter toggle. */}
			<div className="flex flex-wrap items-center justify-between gap-3">
				<Skeleton className="h-10 w-full rounded-lg sm:max-w-md" />
				<Skeleton className="h-9 w-56 rounded-xl" />
			</div>

			{/* Both sections render while the filter is unknown. */}
			{[0, 1].map((section) => (
				<section key={section} className="space-y-4">
					<Skeleton className="h-6 w-52 rounded-sm" />
					<div className="flex flex-col gap-3">
						{[0, 1, 2].map((row) => (
							<OrderRowSkeleton key={row} />
						))}
					</div>
				</section>
			))}
		</div>
	)
}

export { OrderHistorySkeleton }
