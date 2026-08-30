import { Skeleton } from "@/components/atoms/skeleton"
import { cn } from "@/lib/utils"

// Lives apart from contact-preferences-panel.tsx on purpose: the route
// pending skeleton is eager, and importing it from the panel file would drag
// the panel's data hooks into the entry chunk.
function PrefsSectionSkeleton({
	titleWidth,
	lines = 2,
	extra,
}: {
	titleWidth: string
	lines?: number
	extra?: "link" | "checks" | "fields"
}) {
	return (
		<Skeleton className="gap-4 rounded-xl border border-border bg-muted/40 py-5">
			<div className="px-6">
				<Skeleton className={cn("h-5", titleWidth)} />
			</div>
			<div className="space-y-3 px-6">
				{Array.from({ length: lines }, (_, i) => (
					<Skeleton
						key={i}
						className={cn("h-3.5", i === lines - 1 ? "w-4/5" : "w-full")}
					/>
				))}
				{extra === "link" ? (
					<Skeleton className="mt-1 h-4 w-52" />
				) : null}
				{extra === "checks" ? (
					<div className="mt-2 space-y-5">
						{[0, 1].map((key) => (
							<div key={key} className="space-y-2">
								<Skeleton className="h-4 w-40" />
								<div className="flex items-start gap-2.5">
									<Skeleton className="mt-0.5 size-4 shrink-0 rounded-sm" />
									<div className="min-w-0 flex-1 space-y-1.5">
										<Skeleton className="h-3 w-full" />
										<Skeleton className="h-3 w-5/6" />
									</div>
								</div>
							</div>
						))}
					</div>
				) : null}
				{extra === "fields" ? (
					<div className="space-y-3 pt-1">
						<Skeleton className="h-3.5 w-3/4" />
						<Skeleton className="h-3.5 w-2/3" />
					</div>
				) : null}
			</div>
		</Skeleton>
	)
}

function ContactPreferencesSkeleton() {
	return (
		<div
			className="grid gap-6 sm:grid-cols-[minmax(0,1fr)_minmax(16rem,20rem)] sm:items-start"
			aria-busy
			aria-label="Loading contact preferences"
		>
			<div className="space-y-6">
				<PrefsSectionSkeleton titleWidth="w-44" lines={2} extra="link" />
				<PrefsSectionSkeleton titleWidth="w-40" lines={1} extra="checks" />
			</div>
			<PrefsSectionSkeleton titleWidth="w-48" lines={0} extra="fields" />
		</div>
	)
}

export { ContactPreferencesSkeleton }
