import { Skeleton } from "@/components/atoms/skeleton"
import {
	REGISTRATION_BAR_CONTROL_GROUP,
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_BAR_SUBMIT,
	REGISTRATION_BAR_TITLE_GROUP,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import {
	SkeletonCard,
	SkeletonField,
	SkeletonRows,
} from "@/components/molecules/form-skeleton"
import { cn } from "@/lib/utils"

/**
 * The body of the exam-setup page while `examSetup` loads — the same 60/40
 * grid and rail the real form lays out, from the same shared constants, so
 * nothing shifts sideways when the payload lands.
 */
function ExamSetupContentSkeleton() {
	return (
		<div className={REGISTRATION_GRID} aria-busy aria-label="Loading exam setup">
			<div className={REGISTRATION_MAIN_COLUMN}>
				{/* Choose your sitting: two administration tiles and a site. */}
				<SkeletonCard
					rows={
						<div className="flex flex-col gap-4">
							<div className="grid gap-2 sm:grid-cols-2">
								<Skeleton className="h-16 w-full rounded-lg" />
								<Skeleton className="h-16 w-full rounded-lg" />
							</div>
							<SkeletonField />
						</div>
					}
				/>
				{/* Confirm your ID. */}
				<SkeletonCard
					rows={
						<div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
							<Skeleton className="h-20 w-full rounded-xl sm:col-span-2" />
							<SkeletonField />
							<SkeletonField />
							<SkeletonField />
							<SkeletonField />
							<SkeletonField className="sm:col-span-2" />
						</div>
					}
				/>
			</div>
			<aside className={REGISTRATION_RAIL_COLUMN}>
				<div className="flex flex-col gap-4">
					<SkeletonCard rows={<SkeletonRows count={2} />} />
					<SkeletonCard rows={<SkeletonRows count={3} />} />
				</div>
			</aside>
		</div>
	)
}

/** The whole page, bar included — what the route shows before the panel mounts. */
function ExamSetupPendingShell() {
	return (
		<div className="flex flex-col gap-6" aria-busy>
			<span className="sr-only">Loading exam setup…</span>
			<div className={REGISTRATION_STICKY_BAR}>
				<div className={REGISTRATION_BAR_TITLE_GROUP}>
					<Skeleton className="h-6 w-6 shrink-0 sm:w-20" />
					<div className="hidden h-6 w-px shrink-0 bg-border sm:block" />
					<Skeleton className="h-8 w-80 max-w-full" />
				</div>
				<div className={REGISTRATION_BAR_CONTROL_GROUP}>
					<Skeleton className={cn(REGISTRATION_BAR_CONTROL_HEIGHT, "w-28 shrink-0")} />
					<Skeleton
						className={cn(REGISTRATION_BAR_CONTROL_HEIGHT, REGISTRATION_BAR_SUBMIT, "rounded-xl sm:w-44")}
					/>
				</div>
			</div>
			<ExamSetupContentSkeleton />
		</div>
	)
}

function ExamSetupPending() {
	return <ExamSetupPendingShell />
}

export { ExamSetupContentSkeleton, ExamSetupPending, ExamSetupPendingShell }
