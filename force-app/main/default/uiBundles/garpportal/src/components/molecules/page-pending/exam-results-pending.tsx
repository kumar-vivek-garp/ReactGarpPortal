import { getRouteApi } from "@tanstack/react-router"

import { Skeleton } from "@/components/atoms/skeleton"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { examResultsRouteSlug } from "@/lib/exam-results-presentation"

const routeApi = getRouteApi(
	"/_appLayout/programs/$programType/results/",
)

function ExamResultsPendingSkeleton() {
	return (
		<div
			className="space-y-6"
			aria-busy
			aria-label="Loading exam results"
		>
			<div className="overflow-hidden rounded-xl border border-border">
				<div className="flex flex-col gap-5 p-5 sm:flex-row">
					<Skeleton className="h-24 w-full rounded-xl sm:h-28 sm:w-36" />
					<div className="flex-1 space-y-3">
						<Skeleton className="h-6 w-28 rounded-full" />
						<Skeleton className="h-9 w-2/3 max-w-md" />
						<Skeleton className="h-4 w-full max-w-xl" />
						<div className="flex gap-2 pt-1">
							<Skeleton className="h-8 w-20 rounded-lg" />
							<Skeleton className="h-8 w-24 rounded-lg" />
							<Skeleton className="h-8 w-24 rounded-lg" />
						</div>
					</div>
				</div>
			</div>

			{Array.from({ length: 2 }).map((_, i) => (
				<div
					key={i}
					className="space-y-3 rounded-xl border border-border p-5"
				>
					<Skeleton className="h-6 w-24 rounded-full" />
					<Skeleton className="h-7 w-1/2 max-w-sm" />
					<Skeleton className="h-4 w-40" />
					<Skeleton className="h-4 w-full max-w-lg" />
					<Skeleton className="h-28 w-full rounded-xl" />
				</div>
			))}
		</div>
	)
}

function ExamResultsPendingShell({ programType }: { programType: string }) {
	const slug = examResultsRouteSlug(programType)
	return (
		<div className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]">
			<ProgramsSubpageHeader
				back={{
					kind: "program",
					programType: slug,
					label: slug.toUpperCase() || "Program",
				}}
			/>
			<div className="mt-4 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				<ExamResultsPendingSkeleton />
			</div>
		</div>
	)
}

function ExamResultsPending() {
	const { programType } = routeApi.useParams()
	return <ExamResultsPendingShell programType={programType} />
}

export {
	ExamResultsPending,
	ExamResultsPendingShell,
	ExamResultsPendingSkeleton,
}
