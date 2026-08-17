import { Skeleton } from "@/components/atoms/skeleton"
import { cn } from "@/lib/utils"

function OrderRowSkeleton({ showPay = false }: { showPay?: boolean }) {
	return (
		<Skeleton
			className={cn(
				"grid grid-cols-1 gap-3 rounded-xl border border-border bg-muted/40 px-5 py-4",
				"sm:grid-cols-[minmax(0,9rem)_minmax(0,8rem)_minmax(0,1fr)_minmax(0,7rem)_auto] sm:items-center sm:gap-4",
				showPay &&
					"sm:grid-cols-[minmax(0,9rem)_minmax(0,8rem)_minmax(0,1fr)_minmax(0,7rem)_auto_auto]",
			)}
		>
			<Skeleton className="h-4 w-24" />
			<Skeleton className="h-4 w-20" />
			<Skeleton className="h-4 w-full max-w-xs" />
			<Skeleton className="h-4 w-16 sm:justify-self-end" />
			<Skeleton className="h-6 w-16 rounded-full" />
			{showPay ? (
				<Skeleton className="h-8 w-20 rounded-xl sm:justify-self-end" />
			) : null}
		</Skeleton>
	)
}

function OrderHistorySkeleton() {
	return (
		<div className="space-y-8" aria-busy aria-label="Loading orders">
			<Skeleton className="h-11 w-full max-w-md rounded-lg" />
			{[
				{ title: "w-48", showPay: true as const },
				{ title: "w-40", showPay: false as const },
			].map((section, sectionIndex) => (
				<section key={sectionIndex} className="space-y-3">
					<Skeleton className={cn("h-6", section.title)} />
					<div
						className={cn(
							"hidden gap-4 px-5 sm:grid",
							section.showPay
								? "sm:grid-cols-[minmax(0,9rem)_minmax(0,8rem)_minmax(0,1fr)_minmax(0,7rem)_auto_auto]"
								: "sm:grid-cols-[minmax(0,9rem)_minmax(0,8rem)_minmax(0,1fr)_minmax(0,7rem)_auto]",
						)}
						aria-hidden
					>
						{[0, 1, 2, 3, 4].map((col) => (
							<Skeleton key={col} className="h-2.5 w-12" />
						))}
						{section.showPay ? (
							<Skeleton className="h-2.5 w-12 justify-self-end" />
						) : null}
					</div>
					{[0, 1, 2].map((row) => (
						<OrderRowSkeleton key={row} showPay={section.showPay} />
					))}
				</section>
			))}
		</div>
	)
}

export { OrderHistorySkeleton }
