import { getRouteApi } from "@tanstack/react-router"

import { PillTabs } from "@/components/atoms/pill-tabs"
import { Skeleton } from "@/components/atoms/skeleton"
import { Tabs } from "@/components/atoms/tabs"
import {
	HELP_CENTER_TAB_ITEMS,
	type HelpCenterTab,
} from "@/config/help-center"
import { cn } from "@/lib/utils"

const routeApi = getRouteApi("/_appLayout/help-center/")

const REQUEST_ROW_GRID =
	"sm:grid-cols-[minmax(0,7rem)_minmax(0,1fr)_minmax(0,8rem)_minmax(0,12rem)]"

function HelpCenterRequestRowSkeleton() {
	return (
		<Skeleton
			className={cn(
				"grid grid-cols-1 gap-3 rounded-xl border border-border bg-muted/40 px-5 py-4",
				REQUEST_ROW_GRID,
				"sm:items-center sm:gap-4",
			)}
		>
			<Skeleton className="h-4 w-20" />
			<Skeleton className="h-4 w-full max-w-xs" />
			<Skeleton className="h-6 w-16 rounded-full" />
			<Skeleton className="h-4 w-32" />
		</Skeleton>
	)
}

function HelpCenterRequestsSkeleton() {
	return (
		<section className="space-y-3" aria-busy aria-label="Loading your requests">
			<div
				className={cn(
					"hidden gap-4 px-5 sm:grid",
					REQUEST_ROW_GRID,
				)}
				aria-hidden
			>
				{[0, 1, 2, 3].map((col) => (
					<Skeleton key={col} className="h-2.5 w-12" />
				))}
			</div>
			{[0, 1, 2].map((row) => (
				<HelpCenterRequestRowSkeleton key={row} />
			))}
		</section>
	)
}

/** Matches the help-center chrome (tabs) + the active tab's body. */
function HelpCenterPendingShell({ tab }: { tab: HelpCenterTab }) {
	return (
		<Tabs value={tab} className="gap-0">
			<header className="space-y-4">
				<div>
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
						Help Center
					</h1>
					<p className="mt-1 max-w-2xl text-sm text-muted-foreground">
						Open a support case with Member Services, track requests you have
						already raised, or use the links for FAQs and other contact options.
					</p>
				</div>
				<PillTabs items={HELP_CENTER_TAB_ITEMS} value={tab} />
			</header>

			<div className="mt-6" aria-busy aria-label="Loading help center">
				{tab === "requests" ? (
					<HelpCenterRequestsSkeleton />
				) : (
					<div className="grid items-start gap-8 lg:grid-cols-[minmax(0,7fr)_minmax(0,3fr)] lg:gap-10">
						<section className="min-w-0 space-y-5">
							<div className="space-y-2">
								<Skeleton className="h-6 w-52" />
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
									<Skeleton className="h-9 w-24 rounded-xl" />
								</div>
							</div>
						</section>
						<Skeleton className="h-64 w-full rounded-xl lg:h-full" />
					</div>
				)}
			</div>
		</Tabs>
	)
}

function HelpCenterPending() {
	const { tab } = routeApi.useSearch()
	return <HelpCenterPendingShell tab={tab} />
}

export {
	HelpCenterPending,
	HelpCenterPendingShell,
	HelpCenterRequestsSkeleton,
}
