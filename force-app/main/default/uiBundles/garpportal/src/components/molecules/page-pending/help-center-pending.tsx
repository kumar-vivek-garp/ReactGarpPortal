import { getRouteApi } from "@tanstack/react-router"

import { Skeleton } from "@/components/atoms/skeleton"
import { Tabs } from "@/components/atoms/tabs"
import { HelpCenterRequestsSkeleton } from "@/components/molecules/help-center-requests"
import {
	GET_HELP_GRID,
	HELP_CENTER_SCROLL,
	HELP_CENTER_SHELL,
	HelpCenterHeader,
} from "@/components/organisms/help-center-panel"
import type { HelpCenterTab } from "@/config/help-center"

const routeApi = getRouteApi("/_appLayout/help-center/")

/**
 * Matches the help-center chrome + the active tab's body 1:1 — the shell,
 * scroll region, header and row grid are all imported from the real
 * components, so the skeleton cannot drift from what it stands in for.
 */
function HelpCenterPendingShell({ tab }: { tab: HelpCenterTab }) {
	return (
		<Tabs value={tab} className={HELP_CENTER_SHELL}>
			<HelpCenterHeader tab={tab} />

			<div
				className={HELP_CENTER_SCROLL}
				aria-busy
				aria-label="Loading help center"
			>
				{tab === "requests" ? (
					<HelpCenterRequestsSkeleton />
				) : (
					<div className={GET_HELP_GRID}>
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

export { HelpCenterPending, HelpCenterPendingShell }
