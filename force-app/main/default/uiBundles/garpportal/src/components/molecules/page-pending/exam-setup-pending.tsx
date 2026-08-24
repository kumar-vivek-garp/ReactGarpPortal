import { Skeleton } from "@/components/atoms/skeleton"

/** The body of the exam-setup page while `examSetup` loads. */
function ExamSetupContentSkeleton() {
	return (
		<div className="space-y-6" aria-busy aria-label="Loading exam setup">
			{Array.from({ length: 2 }).map((_, section) => (
				<div key={section} className="flex gap-4">
					<Skeleton className="size-9 shrink-0 rounded-full" />
					<div className="flex-1 space-y-4 rounded-xl border border-border p-5">
						<Skeleton className="h-5 w-44" />
						<div className="grid gap-4 sm:grid-cols-2">
							{Array.from({ length: section === 0 ? 2 : 4 }).map((_, field) => (
								<div key={field} className="space-y-1.5">
									<Skeleton className="h-4 w-24" />
									<Skeleton className="h-9 w-full rounded-xl" />
								</div>
							))}
						</div>
					</div>
				</div>
			))}
			<Skeleton className="h-10 w-40 rounded-xl" />
		</div>
	)
}

function ExamSetupPendingShell() {
	return (
		<div className="space-y-6">
			<Skeleton className="h-6 w-24" />
			<Skeleton className="h-9 w-64" />
			<ExamSetupContentSkeleton />
		</div>
	)
}

function ExamSetupPending() {
	return <ExamSetupPendingShell />
}

export { ExamSetupContentSkeleton, ExamSetupPending, ExamSetupPendingShell }
