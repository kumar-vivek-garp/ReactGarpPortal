import { getRouteApi } from "@tanstack/react-router"

import { Skeleton } from "@/components/atoms/skeleton"
import { Tabs, TabsList, TabsTrigger, pillTabTriggerClassName } from "@/components/atoms/tabs"
import type { ProgramsTab } from "@/config/programs"
import { DEFAULT_PROGRAMS_TAB } from "@/config/programs"

const routeApi = getRouteApi("/_appLayout/programs/")

const TAB_ITEMS: Array<{ value: ProgramsTab; label: string }> = [
	{ value: "all", label: "All" },
	{ value: "in-progress", label: "In Progress" },
	{ value: "completed", label: "Completed" },
	{ value: "explore", label: "Explore Other" },
]

function ProgramCardSkeleton() {
	return (
		<Skeleton className="flex h-full flex-col gap-4 overflow-hidden rounded-xl border border-border py-0">
			<div className="flex h-44 items-center justify-center bg-muted/40 p-4">
				<Skeleton className="h-full w-full max-w-[12rem] rounded-xl" />
			</div>
			<div className="space-y-2 px-5 pt-1">
				<Skeleton className="h-5 w-4/5" />
			</div>
			<div className="flex-1 space-y-2 px-5">
				<Skeleton className="h-3.5 w-full" />
				<Skeleton className="h-3.5 w-full" />
				<Skeleton className="h-3.5 w-3/4" />
			</div>
			<div className="mt-auto px-5 pb-5">
				<Skeleton className="h-4 w-28" />
			</div>
		</Skeleton>
	)
}

function ProgramsContentSkeleton() {
	return (
		<div
			className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
			aria-busy
			aria-label="Loading programs"
		>
			{[0, 1, 2, 3, 4, 5, 6, 7].map((key) => (
				<ProgramCardSkeleton key={key} />
			))}
		</div>
	)
}

type ProgramsPendingProps = {
	tab?: ProgramsTab
}

/** Matches programs panel loading chrome (tabs without counts) + content skeleton. */
function ProgramsPendingShell({
	tab = DEFAULT_PROGRAMS_TAB,
}: ProgramsPendingProps) {
	return (
		<Tabs
			value={tab}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<header className="shrink-0 space-y-4">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					My Programs
				</h1>
				<div className="overflow-x-auto overscroll-x-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
					<TabsList className="h-auto w-max gap-3 bg-transparent p-0">
						{TAB_ITEMS.map((item) => (
							<TabsTrigger
								key={item.value}
								value={item.value}
								className={pillTabTriggerClassName}
							>
								{item.label}
							</TabsTrigger>
						))}
					</TabsList>
				</div>
			</header>
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				<ProgramsContentSkeleton />
			</div>
		</Tabs>
	)
}

function ProgramsPending() {
	const { tab } = routeApi.useSearch()
	return <ProgramsPendingShell tab={tab} />
}

export { ProgramsContentSkeleton, ProgramsPending, ProgramsPendingShell }
