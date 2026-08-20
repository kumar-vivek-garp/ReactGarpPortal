import { animated, useSpring } from "@react-spring/web"
import { Link } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { formatMoney } from "@/lib/account-format"
import type { OrdersSummary, OutstandingTotal } from "@/lib/order-presentation"
import { cn } from "@/lib/utils"

/** Slow enough that the balance reads as counting up, not glitching. */
const COUNT_SPRING = { mass: 1, tension: 170, friction: 30 }

type OrderSummaryBarProps = {
	summary: OrdersSummary
	className?: string
}

function StatLabel({ children }: { children: string }) {
	return (
		<p className="text-xs font-semibold tracking-wider text-muted-foreground uppercase">
			{children}
		</p>
	)
}

/** One currency's balance, counting up from zero on mount. */
function AnimatedTotal({
	entry,
	className,
}: {
	entry: OutstandingTotal
	className?: string
}) {
	const spring = useSpring({
		from: { n: 0 },
		to: { n: entry.total },
		config: COUNT_SPRING,
	})

	return (
		<animated.span className={cn("tabular-nums", className)}>
			{spring.n.to(
				(value) => formatMoney(value, entry.currency) ?? entry.formatted,
			)}
		</animated.span>
	)
}

function OutstandingValue({ summary }: { summary: OrdersSummary }) {
	if (summary.outstanding.length === 0) {
		// No currency context exists when nothing is owed, so a bare "0.00" would
		// be both meaningless and faintly alarming. Say it plainly.
		return (
			<p className="font-heading text-3xl text-success-green">Nothing due</p>
		)
	}

	// A single currency gets the headline treatment. Several are listed instead —
	// adding them together would fabricate a total that does not exist.
	if (summary.outstanding.length === 1) {
		return (
			<p className="font-heading text-3xl text-destructive">
				<AnimatedTotal entry={summary.outstanding[0]} />
			</p>
		)
	}

	return (
		<div className="flex flex-col gap-0.5">
			{summary.outstanding.map((entry) => (
				<p
					key={entry.currency ?? "none"}
					className="font-heading text-xl text-destructive"
				>
					<AnimatedTotal entry={entry} />
				</p>
			))}
		</div>
	)
}

/**
 * Balance-forward header for Order History.
 *
 * "What do I owe?" is the question this tab exists to answer, and scanning a
 * list of rows for it is work. Outstanding is payable-only (see
 * `summarizeOrders`) so the figure is money the member can actually settle.
 */
function OrderSummaryBar({ summary, className }: OrderSummaryBarProps) {
	const showPay = summary.hasPayable && summary.outstanding.length > 0

	return (
		<Card
			className={cn(
				"grid gap-5 p-5 sm:grid-cols-3 sm:gap-0 sm:divide-x sm:divide-border",
				className,
			)}
		>
			<div className="space-y-1.5 sm:pr-5">
				<StatLabel>Outstanding</StatLabel>
				<OutstandingValue summary={summary} />
				{showPay ? (
					<Button asChild size="sm" className="mt-1 w-fit">
						<Link
							to="/my-account"
							search={{ tab: "order-history", orders: "unpaid" }}
						>
							Pay now
						</Link>
					</Button>
				) : null}
			</div>

			<div className="space-y-1.5 sm:px-5">
				<StatLabel>Unpaid</StatLabel>
				<p className="font-heading text-3xl tabular-nums text-foreground">
					{summary.unpaidCount}
				</p>
			</div>

			<div className="space-y-1.5 sm:pl-5">
				<StatLabel>Orders</StatLabel>
				<p className="font-heading text-3xl tabular-nums text-foreground">
					{summary.totalCount}
				</p>
			</div>
		</Card>
	)
}

export { OrderSummaryBar }
