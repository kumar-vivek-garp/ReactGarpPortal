import { PillTabs } from "@/components/atoms/pill-tabs"
import { Skeleton } from "@/components/atoms/skeleton"
import { Tabs } from "@/components/atoms/tabs"
import { PAGE_SHELL, PAGE_STICKY_HEADER } from "@/components/molecules/page-shell"
import {
	CPD_PAGE_SUBTITLE,
	CPD_PAGE_TITLE,
	CPD_TAB_ITEMS,
} from "@/config/cpd"

/** One activity row — glyph tile, title and meta run, figure and badge. */
function CpdClaimRowSkeleton() {
	return (
		<Skeleton className="flex items-center gap-4 rounded-xl border border-border bg-card p-4">
			<Skeleton className="size-11 shrink-0 rounded-lg" />
			<div className="min-w-0 flex-1 space-y-2">
				<Skeleton className="h-5 w-2/5" />
				<Skeleton className="h-3.5 w-3/5" />
			</div>
			<div className="hidden shrink-0 flex-col items-end gap-2 sm:flex">
				<Skeleton className="h-4 w-20" />
				<Skeleton className="h-6 w-24 rounded-full" />
			</div>
		</Skeleton>
	)
}

/** The body of `/cpd` while `cpdProgram` loads — header stays put. */
function CpdContentSkeleton() {
	return (
		<div className="space-y-4" aria-busy aria-label="Loading CPD credits">
			{/* The one-line credit strip: label, figures, bars. */}
			<Skeleton className="flex flex-wrap items-center gap-4 rounded-xl border border-border bg-card px-4 py-3">
				<Skeleton className="h-5 w-44" />
				<Skeleton className="h-5 w-56" />
				<Skeleton className="ml-auto h-4 w-64" />
			</Skeleton>

			{/* One list at a time now, so the skeleton shows one list too. */}
			<div className="space-y-3">
				{[0, 1, 2].map((row) => (
					<CpdClaimRowSkeleton key={row} />
				))}
			</div>
		</div>
	)
}

function CpdPendingShell() {
	return (
		/*
		 * `value=""` — nothing is active until the cycle's claims say which tab
		 * to open on, and PillTabs is built for that: the indicator stays parked
		 * rather than flicking from one pill to the other on hydration.
		 */
		<Tabs value="" className={PAGE_SHELL}>
			<header className={`${PAGE_STICKY_HEADER} space-y-4`}>
				<div>
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
						{CPD_PAGE_TITLE}
					</h1>
					<p className="mt-1 text-sm text-muted-foreground">
						{CPD_PAGE_SUBTITLE}
					</p>
				</div>
				<PillTabs items={CPD_TAB_ITEMS} value="" />
			</header>
			<CpdContentSkeleton />
		</Tabs>
	)
}

function CpdPending() {
	return <CpdPendingShell />
}

export { CpdContentSkeleton, CpdPending, CpdPendingShell }
