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
				"flex flex-col overflow-hidden rounded-xl border border-primary/20 bg-card shadow-sm",
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

/** Matches dashboard panel React Query loading UI — real header, skeleton cards. */
function DashboardPending() {
	return (
		<div
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
			aria-busy
			aria-label="Loading dashboard"
		>
			<header className="shrink-0 space-y-2">
				<p className="text-xs font-semibold tracking-wider text-primary uppercase">
					Member home
				</p>
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					Dashboard
				</h1>
				<p className="max-w-2xl text-sm text-muted-foreground">
					Your next steps, programs, and events — in one place.
				</p>
			</header>
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				<div className="grid gap-6 pb-2 sm:grid-cols-2 xl:grid-cols-3">
					<DashboardCardSkeleton body="lines" />
					<DashboardCardSkeleton body="lines" />
					<DashboardCardSkeleton body="search" />
				</div>
			</div>
		</div>
	)
}

export { DashboardPending }
