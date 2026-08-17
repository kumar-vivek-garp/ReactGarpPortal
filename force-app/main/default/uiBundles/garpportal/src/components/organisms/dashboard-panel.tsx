import { useCallback, useState } from "react"

import { DashboardCard } from "@/components/molecules/dashboard-card"
import { DashboardPending } from "@/components/molecules/page-pending"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { useDashboardCards } from "@/hooks/use-dashboard-cards"
import { useDismissDashboardCard } from "@/hooks/use-dismiss-dashboard-card"
import { cn } from "@/lib/utils"

/**
 * Member home dashboard — Apex cards plus enrolled/events composed with
 * the legacy visibility rules. Dismiss is optimistic; Apex persists via
 * `dismissCard`.
 */
function DashboardPanel({ className }: { className?: string }) {
	const { cards: composedCards, isLoading, isError } = useDashboardCards()
	const dismissMutation = useDismissDashboardCard()
	const [dismissed, setDismissed] = useState<string[]>([])

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
		return <DashboardPending />
	}

	if (isError) {
		return (
			<p className="text-sm text-muted-foreground">
				We couldn&apos;t load your dashboard. Please try again later.
			</p>
		)
	}

	const cards = composedCards.filter((card) => !dismissed.includes(card.key))

	return (
		<div className={cn("space-y-6", className)}>
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
				<StaggerReveal
					className="grid gap-6 sm:grid-cols-2 xl:grid-cols-3"
					itemClassName="h-full"
				>
					{cards.map((card) => (
						<DashboardCard
							key={card.key}
							card={card}
							onDismiss={handleDismiss}
						/>
					))}
				</StaggerReveal>
			)}
		</div>
	)
}

export { DashboardPanel }
