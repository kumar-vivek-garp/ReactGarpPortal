import { getRouteApi } from "@tanstack/react-router"

import { Skeleton } from "@/components/atoms/skeleton"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { programTypeSlug } from "@/lib/program-card-links"

const routeApi = getRouteApi("/_appLayout/programs/$programType/")

function ProgramDetailSkeleton() {
	return (
		<div className="space-y-6" aria-busy aria-label="Loading program details">
			<div className="space-y-3">
				<Skeleton className="h-4 w-28" />
				<Skeleton className="h-9 w-2/3 max-w-md" />
			</div>
			<Skeleton className="h-40 w-full rounded-xl" />
			<Skeleton className="h-40 w-full rounded-xl" />
		</div>
	)
}

type ProgramDetailPendingProps = {
	programType?: string
}

function ProgramDetailPendingShell({
	programType = "Program",
}: ProgramDetailPendingProps) {
	const title = programTypeSlug(programType).toUpperCase() || "Program"

	return (
		<div className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]">
			<ProgramsSubpageHeader title={title} />
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
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
