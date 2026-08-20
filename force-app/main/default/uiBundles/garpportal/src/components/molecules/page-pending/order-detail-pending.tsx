import { getRouteApi } from "@tanstack/react-router"

import { Skeleton } from "@/components/atoms/skeleton"
import { OrderDetailHeader } from "@/components/molecules/order-detail-header"

const routeApi = getRouteApi(
	"/_appLayout/my-account/orders/$orderNumber/",
)

function OrderDetailSkeleton() {
	return (
		<div
			className="space-y-6"
			aria-busy
			aria-label="Loading order details"
		>
			{/* Summary hero */}
			<div className="flex flex-col gap-4 rounded-xl border border-border p-5 sm:flex-row sm:items-center">
				<Skeleton className="size-12 shrink-0 rounded-lg" />
				<div className="min-w-0 flex-1 space-y-2">
					<Skeleton className="h-8 w-2/3 max-w-md" />
					<Skeleton className="h-4 w-72 max-w-full" />
				</div>
				<Skeleton className="h-9 w-28 shrink-0" />
			</div>

			<Skeleton className="h-16 w-full rounded-lg" />

			{/* Details card */}
			<div className="space-y-4 rounded-xl border border-border p-5">
				<Skeleton className="h-6 w-40" />
				<Skeleton className="h-4 w-64 max-w-full" />
				<div className="space-y-0 pt-2">
					{Array.from({ length: 6 }).map((_, i) => (
						<div
							key={i}
							className="flex items-baseline justify-between gap-4 border-b border-border/60 py-2 last:border-0"
						>
							<Skeleton className="h-3 w-28" />
							<Skeleton className="h-4 w-40" />
						</div>
					))}
				</div>
			</div>

			<div className="flex flex-wrap gap-3">
				<Skeleton className="h-10 w-36 rounded-md" />
				<Skeleton className="h-10 w-28 rounded-md" />
			</div>
		</div>
	)
}

function OrderDetailPendingShell() {
	return (
		<div className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]">
			<OrderDetailHeader />
			<div className="mt-4 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				<OrderDetailSkeleton />
			</div>
		</div>
	)
}

function OrderDetailPending() {
	void routeApi.useParams()
	return <OrderDetailPendingShell />
}

export { OrderDetailPending, OrderDetailPendingShell, OrderDetailSkeleton }
