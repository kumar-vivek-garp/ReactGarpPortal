import { Skeleton } from "@/components/atoms/skeleton"

/**
 * Mirrors `EventCard`: date tile, type + status chip row, title, then the
 * when/location meta rows and the footer actions.
 */
function EventCardSkeleton() {
	return (
		<Skeleton className="flex h-full flex-col gap-4 overflow-hidden rounded-xl border border-border bg-card py-5">
			<div className="flex gap-4 px-5">
				<Skeleton className="size-16 shrink-0 rounded-xl" />
				<div className="min-w-0 flex-1 space-y-2">
					<div className="flex items-center gap-2">
						<Skeleton className="h-6 w-28 rounded-md" />
						<Skeleton className="h-6 w-20 rounded-full" />
					</div>
					<Skeleton className="h-5 w-4/5" />
				</div>
			</div>
			<div className="flex-1 space-y-2 px-5">
				<div className="flex items-center gap-2">
					<Skeleton className="size-4 rounded" />
					<Skeleton className="h-3.5 w-48" />
				</div>
				<div className="flex items-center gap-2">
					<Skeleton className="size-4 rounded" />
					<Skeleton className="h-3.5 w-32" />
				</div>
			</div>
			<div className="mt-auto flex items-center justify-between gap-3 px-5">
				<Skeleton className="h-4 w-28" />
				<Skeleton className="h-8 w-36 rounded-xl" />
			</div>
		</Skeleton>
	)
}

function EventsContentSkeleton() {
	return (
		<div className="space-y-8" aria-busy aria-label="Loading events">
			{/* Up-next hero: eyebrow + title + meta on the left, date block right. */}
			<Skeleton className="flex flex-col gap-6 rounded-xl border border-border bg-card p-6 sm:p-8 lg:flex-row lg:items-center lg:gap-10">
				<div className="flex min-w-0 flex-1 flex-col gap-3">
					<div className="flex items-center gap-3">
						<Skeleton className="h-4 w-52" />
						<Skeleton className="h-6 w-24 rounded-md" />
					</div>
					<Skeleton className="h-8 w-3/5" />
					<Skeleton className="h-4 w-4/5" />
					<Skeleton className="h-4 w-72" />
					<div className="mt-2 flex items-center gap-5">
						<Skeleton className="h-9 w-40 rounded-xl" />
						<Skeleton className="h-4 w-32" />
					</div>
				</div>
				<Skeleton className="h-36 w-36 shrink-0 self-start rounded-xl lg:self-center" />
			</Skeleton>

			{/* "Also happening" heading + type dropdown. */}
			<div className="flex items-center justify-between gap-3">
				<Skeleton className="h-6 w-40" />
				<Skeleton className="h-9 w-56 rounded-md" />
			</div>

			<div className="grid gap-6 sm:grid-cols-2 xl:grid-cols-3">
				{[0, 1].map((key) => (
					<EventCardSkeleton key={key} />
				))}
			</div>
		</div>
	)
}

/** Matches events panel loading chrome + content skeleton. */
function EventsPendingShell() {
	return (
		<div className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]">
			<header className="shrink-0">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					My Events
				</h1>
				<p className="mt-1 text-sm text-muted-foreground">
					Your next commitment up top, everything else below.
				</p>
			</header>
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				<EventsContentSkeleton />
			</div>
		</div>
	)
}

function EventsPending() {
	return <EventsPendingShell />
}

export { EventsContentSkeleton, EventsPending, EventsPendingShell }
