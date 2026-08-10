import { useCallback, useState } from "react"
import { animated, useSpring } from "@react-spring/web"

import { Skeleton } from "@/components/atoms/skeleton"
import { DashboardCard } from "@/components/molecules/dashboard-card"
import { useDashboard } from "@/hooks/use-dashboard"
import { useDismissDashboardCard } from "@/hooks/use-dismiss-dashboard-card"
import { cn } from "@/lib/utils"

const PANEL_SPRING = { mass: 0.9, tension: 320, friction: 26 }

type DashboardCardSkeletonProps = {
	/** Exam-style header image placeholder. */
	withImage?: boolean
	/** Profile meter vs directory search field. */
	body?: "meter" | "search" | "lines"
}

function DashboardCardSkeleton({
	withImage = false,
	body = "lines",
}: DashboardCardSkeletonProps) {
	return (
		<Skeleton
			className={cn(
				"flex flex-col overflow-hidden rounded-xl border border-border bg-muted/40",
			)}
		>
			{withImage ? (
				<Skeleton className="h-40 w-full rounded-none" />
			) : null}

			<div className="space-y-3 px-5 pt-5 pb-4">
				<div className="flex items-start gap-2">
					{!withImage ? (
						<Skeleton className="mt-0.5 size-5 shrink-0 rounded-full" />
					) : null}
					<div className="min-w-0 flex-1 space-y-2">
						{withImage ? <Skeleton className="h-3.5 w-40" /> : null}
						<Skeleton className="h-5 w-3/5 max-w-xs" />
					</div>
				</div>

				{body === "meter" ? (
					<>
						<Skeleton className="h-6 w-full rounded-lg" />
						<Skeleton className="h-3 w-4/5 max-w-sm" />
						<Skeleton className="h-3 w-full" />
						<Skeleton className="h-3 w-2/3" />
					</>
				) : null}

				{body === "search" ? (
					<>
						<Skeleton className="h-3 w-full" />
						<Skeleton className="h-3 w-5/6" />
						<Skeleton className="h-10 w-full rounded-xl" />
					</>
				) : null}

				{body === "lines" ? (
					<>
						<Skeleton className="h-3 w-full" />
						<Skeleton className="h-3 w-4/5" />
					</>
				) : null}
			</div>

			<div className="mt-auto border-t border-border/60 px-5 py-4">
				<Skeleton className="h-5 w-36" />
			</div>
		</Skeleton>
	)
}

function DashboardSkeleton() {
	return (
		<div
			className="grid gap-6 sm:grid-cols-2 xl:grid-cols-3"
			aria-busy
			aria-label="Loading dashboard"
		>
			<DashboardCardSkeleton body="meter" />
			<DashboardCardSkeleton withImage body="lines" />
			<DashboardCardSkeleton body="search" />
		</div>
	)
}

/**
 * Member home dashboard — ranked cards from `GET /memberportal/dashboard`.
 * Dismiss is optimistic; Apex persists via `dismissCard`.
 */
function DashboardPanel({ className }: { className?: string }) {
	const { data, isLoading, isError } = useDashboard()
	const dismissMutation = useDismissDashboardCard()
	const [dismissed, setDismissed] = useState<string[]>([])

	const enter = useSpring({
		from: { opacity: 0, transform: "translateY(8px)" },
		to: { opacity: 1, transform: "translateY(0px)" },
		config: PANEL_SPRING,
	})

	const handleDismiss = useCallback(
		(key: string) => {
			setDismissed((current) =>
				current.includes(key) ? current : [...current, key],
			)
			dismissMutation.mutate(key, {
				onError: () => {
					setDismissed((current) => current.filter((k) => k !== key))
				},
			})
		},
		[dismissMutation],
	)

	if (isLoading) {
		return <DashboardSkeleton />
	}

	if (isError) {
		return (
			<p className="text-sm text-muted-foreground">
				We couldn&apos;t load your dashboard. Please try again later.
			</p>
		)
	}

	const cards = (data?.cards ?? []).filter(
		(card) => !dismissed.includes(card.key),
	)

	return (
		<animated.div className={cn("space-y-6", className)} style={enter}>
			<h1 className="sr-only">Dashboard</h1>

			{cards.length === 0 ? (
				<div className="rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
					<p className="font-heading text-lg font-semibold tracking-wide text-foreground">
						You&apos;re all caught up
					</p>
					<p className="mt-2 text-sm text-muted-foreground">
						There is nothing that needs your attention right now.
					</p>
				</div>
			) : (
				<div className="grid gap-6 sm:grid-cols-2 xl:grid-cols-3">
					{cards.map((card) => (
						<DashboardCard
							key={card.key}
							card={card}
							onDismiss={handleDismiss}
						/>
					))}
				</div>
			)}
		</animated.div>
	)
}

export { DashboardPanel }
