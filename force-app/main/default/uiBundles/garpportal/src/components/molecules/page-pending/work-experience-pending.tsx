import { Skeleton } from "@/components/atoms/skeleton"

/** The body of the work-experience page while `cv` loads. */
function WorkExperienceContentSkeleton() {
	return (
		<div className="space-y-6" aria-busy aria-label="Loading work experience">
			<div className="space-y-3 rounded-xl border border-border p-5">
				<Skeleton className="h-6 w-56" />
				<Skeleton className="h-2 w-full rounded-full" />
			</div>
			{Array.from({ length: 3 }).map((_, index) => (
				<div key={index} className="flex gap-4">
					<Skeleton className="size-9 shrink-0 rounded-full" />
					<div className="flex-1 space-y-3">
						<Skeleton className="h-6 w-48" />
						{index === 0 ? (
							<Skeleton className="h-28 w-full rounded-xl" />
						) : null}
					</div>
				</div>
			))}
		</div>
	)
}

function WorkExperiencePendingShell() {
	return (
		<div className="space-y-6">
			<Skeleton className="h-6 w-24" />
			<Skeleton className="h-9 w-64" />
			<WorkExperienceContentSkeleton />
		</div>
	)
}

function WorkExperiencePending() {
	return <WorkExperiencePendingShell />
}

export {
	WorkExperienceContentSkeleton,
	WorkExperiencePending,
	WorkExperiencePendingShell,
}
