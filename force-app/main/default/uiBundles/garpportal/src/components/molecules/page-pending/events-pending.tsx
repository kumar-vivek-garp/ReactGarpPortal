import { getRouteApi } from "@tanstack/react-router"

import { Skeleton } from "@/components/atoms/skeleton"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import type { EventsTab } from "@/config/events"
import { DEFAULT_EVENTS_TAB, EVENT_TAB_ITEMS } from "@/config/events"

const routeApi = getRouteApi("/_appLayout/events/")

function EventCardSkeleton() {
	return (
		<Skeleton className="flex h-full flex-col gap-4 overflow-hidden rounded-xl border border-border py-5">
			<div className="flex gap-4 px-5">
				<Skeleton className="size-16 shrink-0 rounded-xl" />
				<div className="min-w-0 flex-1 space-y-2">
					<Skeleton className="h-5 w-28 rounded-xl" />
					<Skeleton className="h-5 w-4/5" />
					<Skeleton className="h-5 w-3/5" />
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
		<div
			className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
			aria-busy
			aria-label="Loading events"
		>
			{[0, 1, 2, 3, 4, 5].map((key) => (
				<EventCardSkeleton key={key} />
			))}
		</div>
	)
}

type EventsPendingProps = {
	tab?: EventsTab
}

/** Matches events panel loading chrome + content skeleton. */
function EventsPendingShell({ tab = DEFAULT_EVENTS_TAB }: EventsPendingProps) {
	return (
		<Tabs
			value={tab}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<header className="shrink-0 space-y-4">
				<div className="space-y-3">
					<div>
						<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
							My Events
						</h1>
						<p className="mt-1 text-sm text-muted-foreground">
							Your registrations, chapter meetings, and featured GARP events.
						</p>
					</div>
					<div className="flex flex-wrap items-center gap-3">
						<Skeleton className="h-8 w-44 rounded-md" />
						<Skeleton className="h-8 w-32 rounded-md" />
					</div>
				</div>
				<PillTabs items={EVENT_TAB_ITEMS} value={tab} />
			</header>
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				<EventsContentSkeleton />
			</div>
		</Tabs>
	)
}

function EventsPending() {
	const { tab } = routeApi.useSearch()
	return <EventsPendingShell tab={tab} />
}

export { EventsContentSkeleton, EventsPending, EventsPendingShell }
