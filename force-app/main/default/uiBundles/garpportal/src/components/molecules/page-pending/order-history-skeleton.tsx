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
			{/* Summary bar — three stat columns. */}
			<Skeleton className="grid gap-5 rounded-xl border border-primary/20 bg-card p-5 sm:grid-cols-3 sm:gap-0 sm:divide-x sm:divide-border">
				{[0, 1, 2].map((column) => (
					<div
						key={column}
						className="space-y-1.5 sm:first:pr-5 sm:[&:nth-child(2)]:px-5 sm:last:pl-5"
					>
						<Skeleton className="h-3 w-24 rounded-sm" />
						<Skeleton className="h-8 w-28 rounded-sm" />
						{column === 0 ? <Skeleton className="h-8 w-20 rounded-xl" /> : null}
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
