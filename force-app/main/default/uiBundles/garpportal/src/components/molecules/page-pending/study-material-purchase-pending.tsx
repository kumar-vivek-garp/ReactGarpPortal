import { Skeleton } from "@/components/atoms/skeleton"
import {
	REGISTRATION_BAR_CONTROL_GROUP,
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_BAR_SUBMIT,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_SHELL,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import { cn } from "@/lib/utils"

/**
 * Mirrors the purchase form's bar and 60/40 grid so nothing shifts when the
 * quote lands — the item card and the address card left, the summary right.
 */
function StudyMaterialPurchaseSkeleton() {
	return (
		<div aria-busy aria-label="Loading your purchase">
			<div className={REGISTRATION_STICKY_BAR}>
				<Skeleton className="h-8 w-64 max-w-full" />
				<div className={REGISTRATION_BAR_CONTROL_GROUP}>
					<Skeleton className={cn(REGISTRATION_BAR_CONTROL_HEIGHT, "w-24 shrink-0")} />
					<Skeleton
						className={cn(
							REGISTRATION_BAR_CONTROL_HEIGHT,
							REGISTRATION_BAR_SUBMIT,
							"rounded-xl sm:w-28",
						)}
					/>
				</div>
			</div>
			<div className={cn(REGISTRATION_GRID, "mt-4")}>
				<div className={REGISTRATION_MAIN_COLUMN}>
					<Skeleton className="h-36 w-full rounded-xl border border-border bg-card" />
					<Skeleton className="h-96 w-full rounded-xl border border-border bg-card" />
				</div>
				<aside className={REGISTRATION_RAIL_COLUMN}>
					<Skeleton className="h-52 w-full rounded-xl border border-border bg-card" />
				</aside>
			</div>
		</div>
	)
}

function StudyMaterialPurchasePendingShell() {
	return (
		<div className={REGISTRATION_SHELL}>
			<div>
				<StudyMaterialPurchaseSkeleton />
			</div>
		</div>
	)
}

function StudyMaterialPurchasePending() {
	return <StudyMaterialPurchasePendingShell />
}

export {
	StudyMaterialPurchasePending,
	StudyMaterialPurchasePendingShell,
	StudyMaterialPurchaseSkeleton,
}
