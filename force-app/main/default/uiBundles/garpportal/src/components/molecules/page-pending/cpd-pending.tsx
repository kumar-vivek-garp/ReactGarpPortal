import { Skeleton } from "@/components/atoms/skeleton"
import { CPD_PAGE_TITLE } from "@/config/cpd"

/** The body of `/cpd` while `cpdProgram` loads — header stays put. */
function CpdContentSkeleton() {
	return (
		<div
			className="grid items-start gap-6 app:grid-cols-[minmax(0,1fr)_20rem]"
			aria-busy
			aria-label="Loading CPD credits"
		>
			<div className="min-w-0 space-y-6">
				<div className="space-y-2 rounded-xl border border-border p-5">
					<Skeleton className="h-6 w-44" />
					<Skeleton className="h-9 w-full max-w-xs rounded-lg" />
					<Skeleton className="h-9 w-full max-w-xs rounded-lg" />
					<Skeleton className="h-9 w-full max-w-xs rounded-lg" />
				</div>

				{Array.from({ length: 2 }).map((_, section) => (
					<div key={section} className="space-y-3">
						<Skeleton className="h-7 w-48" />
						<div className="space-y-3 rounded-xl border border-border p-5">
							{Array.from({ length: 3 }).map((_, row) => (
								<Skeleton key={row} className="h-5 w-full" />
							))}
						</div>
					</div>
				))}
			</div>

			<div className="space-y-3 rounded-xl border border-border p-5">
				<Skeleton className="h-6 w-52" />
				<Skeleton className="h-2 w-full rounded-sm" />
				<Skeleton className="h-2 w-full rounded-sm" />
				<Skeleton className="h-5 w-40" />
			</div>
		</div>
	)
}

function CpdPendingShell() {
	return (
		<div className="space-y-6">
			<header className="flex flex-wrap items-center justify-between gap-3">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					{CPD_PAGE_TITLE}
				</h1>
			</header>
			<CpdContentSkeleton />
		</div>
	)
}

function CpdPending() {
	return <CpdPendingShell />
}

export { CpdContentSkeleton, CpdPending, CpdPendingShell }
