import { Skeleton } from "@/components/atoms/skeleton"

function CatalogueCardSkeleton() {
	return (
		<Skeleton className="flex h-full flex-col gap-4 overflow-hidden rounded-xl border border-border py-0">
			<div className="flex h-44 items-center justify-center bg-muted/40 p-4">
				<Skeleton className="h-full w-full max-w-[12rem] rounded-md" />
			</div>
			<div className="space-y-2 px-5 pt-1">
				<Skeleton className="h-5 w-4/5" />
				<Skeleton className="h-4 w-28" />
			</div>
			<div className="flex-1 space-y-2 px-5">
				<Skeleton className="h-3.5 w-full" />
				<Skeleton className="h-3.5 w-full" />
				<Skeleton className="h-3.5 w-3/4" />
			</div>
			<div className="mt-auto flex justify-end px-5 pb-5">
				<Skeleton className="h-4 w-28" />
			</div>
		</Skeleton>
	)
}

function StudyMaterialsContentSkeleton() {
	return (
		<div
			className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
			aria-busy
			aria-label="Loading study materials"
		>
			{[0, 1, 2, 3, 4, 5, 6, 7].map((key) => (
				<CatalogueCardSkeleton key={key} />
			))}
		</div>
	)
}

/** Matches study-materials panel loading chrome + content skeleton. */
function StudyMaterialsPending() {
	return (
		<div className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]">
			<header className="shrink-0 space-y-4">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					Study Materials for Risk Professionals
				</h1>
				<div className="flex flex-wrap gap-2">
					{[0, 1, 2, 3].map((key) => (
						<Skeleton key={key} className="h-9 w-24 rounded-xl" />
					))}
				</div>
			</header>
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				<StudyMaterialsContentSkeleton />
			</div>
		</div>
	)
}

export { StudyMaterialsContentSkeleton, StudyMaterialsPending }
