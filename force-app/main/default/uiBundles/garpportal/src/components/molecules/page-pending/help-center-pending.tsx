import { Skeleton } from "@/components/atoms/skeleton"

/** Form-shaped placeholder for help-center chunk wait (page has no API skeleton). */
function HelpCenterPending() {
	return (
		<div className="space-y-8" aria-busy aria-label="Loading help center">
			<div>
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					Help Center
				</h1>
				<p className="mt-1 text-sm text-muted-foreground">
					Open a support case with Member Services, or use the links for FAQs
					and other contact options.
				</p>
			</div>

			<div className="grid items-start gap-10 lg:grid-cols-[minmax(0,1fr)_18rem] lg:gap-16">
				<section className="min-w-0 space-y-5">
					<div className="space-y-2">
						<Skeleton className="h-5 w-44" />
						<Skeleton className="h-3.5 w-full max-w-md" />
					</div>
					<div className="space-y-5">
						<div className="space-y-1.5">
							<Skeleton className="h-3.5 w-16" />
							<Skeleton className="h-9 w-full rounded-md" />
						</div>
						<div className="space-y-1.5">
							<Skeleton className="h-3.5 w-24" />
							<Skeleton className="h-48 w-full rounded-md" />
						</div>
						<div className="flex justify-end">
							<Skeleton className="h-9 w-24 rounded-md" />
						</div>
					</div>
				</section>

				<aside className="space-y-4 lg:border-l lg:border-border/60 lg:pl-10">
					<div className="space-y-2">
						<Skeleton className="h-5 w-48" />
						<Skeleton className="h-3.5 w-full max-w-xs" />
					</div>
					<div className="flex flex-col gap-3">
						{[0, 1, 2, 3].map((key) => (
							<Skeleton key={key} className="h-4 w-40" />
						))}
					</div>
				</aside>
			</div>
		</div>
	)
}

export { HelpCenterPending }
