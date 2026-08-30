import { Skeleton } from "@/components/atoms/skeleton"
import { CompletionRingSkeleton } from "@/components/molecules/completion-ring"
import {
	ACCOUNT_BENTO_SCOPE,
	ACCOUNT_CARD_ORDER,
} from "@/config/account-sections"
import { useBentoColumns } from "@/hooks/use-bento-layout"

// Lives apart from account-information-panel.tsx on purpose: the route
// pending skeleton is eager, and importing it from the panel file would drag
// the whole panel (edit forms, react-hook-form) into the entry chunk.
function AccountInformationSkeleton() {
	// Bones must lay out in the member's own arrangement, or the whole grid
	// re-shuffles the instant real data lands — a flash on every visit.
	const columns = useBentoColumns(ACCOUNT_BENTO_SCOPE, ACCOUNT_CARD_ORDER)

	return (
		<div className="space-y-6" aria-busy aria-label="Loading account">
			{/* Hero bone — same geometry as AccountIdentityHero. */}
			<div className="rounded-xl border border-border bg-muted/40 p-5 sm:p-6">
				<div className="flex flex-col gap-5 app:flex-row app:items-center app:gap-6">
					<CompletionRingSkeleton />
					<div className="min-w-0 flex-1 space-y-2.5">
						<Skeleton className="h-8 w-3/5 max-w-xs rounded-sm" />
						<div className="flex flex-wrap gap-2">
							<Skeleton className="h-6 w-32 rounded-full" />
							<Skeleton className="h-6 w-24 rounded-full" />
							<Skeleton className="h-6 w-28 rounded-full" />
						</div>
						<Skeleton className="h-3.5 w-2/5 rounded-sm" />
						<Skeleton className="h-3.5 w-1/3 rounded-sm" />
					</div>
					<Skeleton className="h-9 w-full rounded-md app:w-32" />
				</div>
			</div>

			{/* Same masonry geometry as the live grid, so the bones cannot drift. */}
			<div className="flex items-start gap-6">
				{columns.map((column, columnIndex) => (
					<div key={columnIndex} className="flex min-w-0 flex-1 flex-col gap-6">
						{column.map((section, index) => (
							<div
								key={section}
								className="flex min-h-56 flex-col gap-3 rounded-xl border border-border bg-muted/40 px-6 py-5"
							>
								<div className="flex items-center gap-2">
									<Skeleton className="size-8 shrink-0 rounded-lg" />
									<Skeleton className="h-5 w-2/5 rounded-sm" />
								</div>
								<div className="flex flex-1 flex-col gap-2.5">
									<Skeleton className="h-3.5 w-full rounded-sm" />
									<Skeleton className="h-3.5 w-5/6 rounded-sm" />
									<Skeleton className="h-3.5 w-4/6 rounded-sm" />
									<Skeleton className="h-3.5 w-3/4 rounded-sm" />
									{index % 2 === 0 ? (
										<>
											<Skeleton className="mt-1 h-3.5 w-1/3 rounded-sm" />
											<Skeleton className="h-3.5 w-full rounded-sm" />
											<Skeleton className="h-3.5 w-2/3 rounded-sm" />
										</>
									) : (
										<>
											<Skeleton className="mt-1 h-3.5 w-2/5 rounded-sm" />
											<Skeleton className="h-3.5 w-4/5 rounded-sm" />
										</>
									)}
								</div>
							</div>
						))}
					</div>
				))}
			</div>
		</div>
	)
}

export { AccountInformationSkeleton }
