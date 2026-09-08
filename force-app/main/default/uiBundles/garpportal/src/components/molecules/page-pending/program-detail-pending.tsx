import { getRouteApi } from "@tanstack/react-router"

import { Skeleton } from "@/components/atoms/skeleton"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { cn } from "@/lib/utils"
import { PAGE_SHELL, PAGE_STICKY_SUBHEADER } from "@/components/molecules/page-shell"

const routeApi = getRouteApi("/_appLayout/programs/$programType/")

function ProgramDetailSkeleton() {
	return (
		<div
			className="space-y-6"
			aria-busy
			aria-label="Loading program details"
		>
			{/* Hero */}
			<div className="overflow-hidden rounded-xl border border-border">
				<div className="flex flex-col gap-5 p-5 sm:flex-row">
					<Skeleton className="h-28 w-full rounded-xl sm:h-32 sm:w-40" />
					<div className="flex-1 space-y-3">
						<Skeleton className="h-6 w-28 rounded-full" />
						<Skeleton className="h-9 w-2/3 max-w-md" />
						<Skeleton className="h-4 w-full max-w-xl" />
						<Skeleton className="h-4 w-4/5 max-w-lg" />
					</div>
				</div>
			</div>

			{/* Next step */}
			<Skeleton className="h-36 w-full rounded-xl" />

			<div
				className={cn(
					"grid items-start gap-8",
					"app:grid-cols-[minmax(0,1fr)_minmax(16rem,20rem)]",
				)}
			>
				<div className="space-y-5">
					<Skeleton className="h-56 w-full rounded-xl" />
					<Skeleton className="h-64 w-full rounded-xl" />
				</div>
				<div className="hidden space-y-5 app:block">
					<Skeleton className="h-40 w-full rounded-xl" />
					<Skeleton className="h-56 w-full rounded-xl" />
				</div>
			</div>
		</div>
	)
}

type ProgramDetailPendingProps = {
	programType?: string
}

function ProgramDetailPendingShell({
	programType = "Program",
}: ProgramDetailPendingProps) {
	void programType

	return (
		<div className={PAGE_SHELL}>
			<ProgramsSubpageHeader className={PAGE_STICKY_SUBHEADER} />
			<div>
				<ProgramDetailSkeleton />
			</div>
		</div>
	)
}

function ProgramDetailPending() {
	const { programType } = routeApi.useParams()
	return <ProgramDetailPendingShell programType={programType} />
}

export { ProgramDetailPending, ProgramDetailPendingShell, ProgramDetailSkeleton }
