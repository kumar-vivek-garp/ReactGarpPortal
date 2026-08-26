import { getRouteApi } from "@tanstack/react-router"

import { Skeleton } from "@/components/atoms/skeleton"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import type { ListView } from "@/config/list-view"
import type { MembershipTab } from "@/config/membership"
import {
	DEFAULT_MEMBERSHIP_TAB,
	MEMBERSHIP_TAB_ITEMS,
	resolveMembershipView,
} from "@/config/membership"
import { useListViewStore } from "@/store/list-view-store"

const routeApi = getRouteApi("/_appLayout/membership/")

/** Mirrors `MembershipHero`: avatar, name, chip row, meta row, right-zone callout. */
function MembershipHeroSkeleton() {
	return (
		<Skeleton className="rounded-xl border border-border p-5 sm:p-6">
			<div className="flex flex-col gap-5 app:flex-row app:items-start app:gap-6">
				<Skeleton className="size-22 shrink-0 rounded-full app:size-28" />
				<div className="min-w-0 flex-1 space-y-2.5">
					<Skeleton className="h-7 w-56 max-w-full sm:h-8" />
					<div className="flex flex-wrap items-center gap-2">
						<Skeleton className="h-6 w-24 rounded-full" />
						<Skeleton className="h-6 w-20 rounded-full" />
						<Skeleton className="h-6 w-16 rounded-full" />
					</div>
					<Skeleton className="h-4 w-64 max-w-full" />
				</div>
				<Skeleton className="h-20 w-full rounded-lg app:w-80" />
			</div>
		</Skeleton>
	)
}

/** Mirrors `BenefitCard`: optional image, badge + title, clamped body, footer CTA. */
function BenefitCardSkeleton({ withImage = true }: { withImage?: boolean }) {
	return (
		<Skeleton className="flex h-full min-h-72 flex-col overflow-hidden rounded-xl border border-border bg-card">
			{withImage ? (
				<Skeleton className="h-32 w-full shrink-0 rounded-none" />
			) : null}
			<div className="shrink-0 space-y-2 px-5 pt-4 pb-2">
				<Skeleton className="h-4 w-3/5" />
			</div>
			<div className="min-h-0 flex-1 space-y-2 overflow-hidden px-5">
				<Skeleton className="h-3 w-full" />
				<Skeleton className="h-3 w-full" />
				<Skeleton className="h-3 w-4/5" />
				<Skeleton className="h-3 w-2/3" />
			</div>
			<div className="mt-auto shrink-0 border-t border-border/60 px-5 py-4">
				<Skeleton className="h-5 w-32" />
			</div>
		</Skeleton>
	)
}

/** Mirrors `BenefitRow`: image thumb, title, clamped summary, CTA at the end. */
function BenefitRowSkeleton() {
	return (
		<Skeleton className="flex flex-col gap-4 rounded-xl border border-border bg-card p-4 sm:flex-row sm:items-center">
			<Skeleton className="h-16 w-full shrink-0 rounded-lg sm:w-24" />
			<div className="min-w-0 flex-1 space-y-2">
				<Skeleton className="h-4 w-3/5" />
				<Skeleton className="h-3.5 w-4/5" />
			</div>
			<div className="flex shrink-0 items-center gap-2 sm:flex-col sm:items-end">
				<Skeleton className="h-4 w-24" />
				<Skeleton className="size-5 rounded-full" />
			</div>
		</Skeleton>
	)
}

/** Matches the resolved layout so the skeleton has the same geometry as the page. */
function MembershipBenefitsSkeleton({ view = "grid" }: { view?: ListView }) {
	return (
		<div className="space-y-8" aria-busy aria-label="Loading membership benefits">
			<MembershipHeroSkeleton />
			<section className="space-y-4">
				<Skeleton className="h-6 w-48" />
				{view === "list" ? (
					<div className="flex flex-col gap-3">
						{[0, 1, 2].map((key) => (
							<BenefitRowSkeleton key={key} />
						))}
					</div>
				) : (
					<div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
						{[0, 1, 2, 3].map((key) => (
							<BenefitCardSkeleton key={key} withImage={key !== 1} />
						))}
					</div>
				)}
			</section>
		</div>
	)
}

function MembershipDirectorySkeleton() {
	return (
		<div
			className="flex min-h-0 flex-1 flex-col gap-3"
			aria-busy
			aria-label="Loading member directory"
		>
			<Skeleton className="h-3.5 w-full max-w-xl" />
			<Skeleton className="h-10 w-full rounded-xl" />
			<div className="space-y-2 pt-2">
				{[0, 1, 2].map((key) => (
					<Skeleton
						key={key}
						className="rounded-xl border border-border bg-muted/20 px-4 py-3"
					>
						<Skeleton className="h-4 w-48" />
						<Skeleton className="mt-2 h-3 w-72 max-w-full" />
					</Skeleton>
				))}
			</div>
		</div>
	)
}

type MembershipPendingProps = {
	tab?: MembershipTab
	view?: ListView
}

function MembershipPendingShell({
	tab = DEFAULT_MEMBERSHIP_TAB,
	view,
}: MembershipPendingProps) {
	// Same precedence as the panel, so the skeleton matches the layout that lands.
	const preferredView = useListViewStore((state) => state.preferred.membership)
	const resolvedView = resolveMembershipView(view, preferredView)

	return (
		<Tabs
			value={tab}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<header className="shrink-0 space-y-4">
				<div className="flex flex-wrap items-center justify-between gap-3">
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
						Membership Benefits
					</h1>
					{tab === "benefits" ? (
						<Skeleton className="h-9 w-20 rounded-xl" />
					) : null}
				</div>
				<PillTabs items={MEMBERSHIP_TAB_ITEMS} value={tab} />
			</header>
			<div className="mt-6 flex min-h-0 flex-1 flex-col overflow-hidden pb-2">
				{tab === "directory" ? (
					<MembershipDirectorySkeleton />
				) : (
					<div className="min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
						<MembershipBenefitsSkeleton view={resolvedView} />
					</div>
				)}
			</div>
		</Tabs>
	)
}

/** Route pending — reads destination `?tab=` / `?view=`. */
function MembershipPending() {
	const { tab, view } = routeApi.useSearch()
	return <MembershipPendingShell tab={tab} view={view} />
}

export {
	MembershipBenefitsSkeleton,
	MembershipDirectorySkeleton,
	MembershipPending,
	MembershipPendingShell,
}
