import { Skeleton } from "@/components/atoms/skeleton"
import { CPD_ACTIVITIES_TITLE } from "@/config/cpd"

/** The results + facet columns while the first page loads. */
function CpdActivitiesContentSkeleton() {
	return (
		<div
			className="grid items-start gap-6 app:grid-cols-[minmax(0,1fr)_18rem]"
			aria-busy
			aria-label="Loading credit opportunities"
		>
			<div className="min-w-0 space-y-4">
				{Array.from({ length: 3 }).map((_, index) => (
					<div key={index} className="space-y-3 rounded-xl border border-border p-5">
						<div className="flex justify-between">
							<Skeleton className="h-4 w-24" />
							<Skeleton className="h-4 w-16" />
						</div>
						<Skeleton className="h-6 w-2/3 max-w-sm" />
						<Skeleton className="h-4 w-1/2 max-w-xs" />
						<Skeleton className="h-4 w-40" />
					</div>
				))}
			</div>
			<div className="space-y-4">
				<Skeleton className="h-24 w-full rounded-xl" />
				<Skeleton className="h-64 w-full rounded-xl" />
			</div>
		</div>
	)
}

function CpdActivitiesPendingShell() {
	return (
		<div className="space-y-6">
			<header className="space-y-3">
				<Skeleton className="h-6 w-32" />
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					{CPD_ACTIVITIES_TITLE}
				</h1>
			</header>
			<CpdActivitiesContentSkeleton />
		</div>
	)
}

function CpdActivitiesPending() {
	return <CpdActivitiesPendingShell />
}

export {
	CpdActivitiesContentSkeleton,
	CpdActivitiesPending,
	CpdActivitiesPendingShell,
}
