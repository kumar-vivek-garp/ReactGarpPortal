import { getRouteApi } from "@tanstack/react-router"

import { Skeleton } from "@/components/atoms/skeleton"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import type { MembershipTab } from "@/config/membership"
import { DEFAULT_MEMBERSHIP_TAB, MEMBERSHIP_TAB_ITEMS } from "@/config/membership"

const routeApi = getRouteApi("/_appLayout/membership/")

function MembershipHeroSkeleton() {
	return (
		<Skeleton className="rounded-xl border border-border px-6 py-6">
			<div className="grid gap-6 md:grid-cols-[minmax(0,18rem)_1fr]">
				<div className="flex items-start gap-3">
					<Skeleton className="size-14 shrink-0 rounded-full" />
					<div className="min-w-0 flex-1 space-y-2">
						<Skeleton className="h-4 w-40" />
						<Skeleton className="h-3.5 w-36" />
						<Skeleton className="h-3.5 w-44" />
						<Skeleton className="h-3.5 w-48" />
					</div>
				</div>
				<div className="space-y-3">
					<Skeleton className="h-3.5 w-full" />
					<Skeleton className="h-3.5 w-5/6" />
					<Skeleton className="h-3.5 w-4/5" />
					<Skeleton className="h-9 w-44 rounded-xl" />
				</div>
			</div>
		</Skeleton>
	)
}

function BenefitCardSkeleton({ withImage = true }: { withImage?: boolean }) {
	return (
		<Skeleton className="flex h-[28rem] flex-col overflow-hidden rounded-xl border border-border">
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

function MembershipBenefitsSkeleton() {
	return (
		<div className="space-y-8" aria-busy aria-label="Loading membership benefits">
			<MembershipHeroSkeleton />
			<section className="space-y-4">
				<Skeleton className="h-6 w-48" />
				<div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
					{[0, 1, 2, 3].map((key) => (
						<BenefitCardSkeleton key={key} withImage={key !== 1} />
					))}
				</div>
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
}

function MembershipPendingShell({
	tab = DEFAULT_MEMBERSHIP_TAB,
}: MembershipPendingProps) {
	return (
		<Tabs
			value={tab}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<header className="shrink-0 space-y-4">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					Membership Benefits
				</h1>
				<PillTabs items={MEMBERSHIP_TAB_ITEMS} value={tab} />
			</header>
			<div className="mt-6 flex min-h-0 flex-1 flex-col overflow-hidden pb-2">
				{tab === "directory" ? (
					<MembershipDirectorySkeleton />
				) : (
					<div className="min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
						<MembershipBenefitsSkeleton />
					</div>
				)}
			</div>
		</Tabs>
	)
}

/** Route pending — reads destination `?tab=`. */
function MembershipPending() {
	const { tab } = routeApi.useSearch()
	return <MembershipPendingShell tab={tab} />
}

export {
	MembershipBenefitsSkeleton,
	MembershipDirectorySkeleton,
	MembershipPending,
	MembershipPendingShell,
}
