import { DashboardCard } from "@/components/molecules/dashboard-card"
import { DashboardPending } from "@/components/molecules/page-pending"
import { PageEnterFade } from "@/components/molecules/page-enter-fade"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { useDashboardCards } from "@/hooks/use-dashboard-cards"
import { useDashboardCardVisibility } from "@/hooks/use-dashboard-card-visibility"
import { cn } from "@/lib/utils"

/**
 * Member home dashboard — Apex cards plus enrolled/events composed with
 * the legacy visibility rules. Hiding a card and taking it back both live in
 * `useDashboardCardVisibility`; this component only filters on the result.
 */
function DashboardPanel({ className }: { className?: string }) {
	const { cards: composedCards, isLoading, isError } = useDashboardCards()
	const { hiddenKeys, dismiss } = useDashboardCardVisibility()

	if (isLoading) {
		return <DashboardPending />
	}

	const cards = composedCards.filter((card) => !hiddenKeys.includes(card.key))

	return (
		// Same fixed-height, internally-scrolling shell as programs/events: the
		// header stays put and only the card area scrolls, so every module
		// scrolls the same way.
		<PageEnterFade
			className={cn(
				"-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]",
				className,
			)}
		>
			<header className="shrink-0 space-y-2">
				<p className="text-xs font-semibold tracking-wider text-primary uppercase">
					Member home
				</p>
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					Dashboard
				</h1>
				<p className="max-w-2xl text-sm text-muted-foreground">
					Your next steps, programs, and events — in one place.
				</p>
			</header>

			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isError ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load your dashboard. Please try again later.
					</p>
				) : cards.length === 0 ? (
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
						className="grid gap-6 pb-2 sm:grid-cols-2 xl:grid-cols-3"
						itemClassName="h-full"
					>
						{cards.map((card) => (
							<DashboardCard
								key={card.key}
								card={card}
								onDismiss={dismiss}
							/>
						))}
					</StaggerReveal>
				)}
			</div>
		</PageEnterFade>
	)
}

export { DashboardPanel }
