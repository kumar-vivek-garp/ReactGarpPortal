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
			<p className="font-heading text-2xl text-success-green">Nothing due</p>
		)
	}

	// A single currency gets the headline treatment. Several are listed instead —
	// adding them together would fabricate a total that does not exist.
	if (summary.outstanding.length === 1) {
		return (
			<p className="font-heading text-2xl text-destructive">
				<AnimatedTotal entry={summary.outstanding[0]} />
			</p>
		)
	}

	return (
		<div className="flex flex-wrap items-baseline gap-x-3 gap-y-0.5">
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
 * Label + value side by side — the strip stays one text-line tall. On mobile
 * each stat is its own row, label left and value right.
 */
function Stat({ label, value }: { label: string; value: number }) {
	return (
		<div className="flex items-center justify-between gap-2.5 sm:flex-1 sm:justify-start">
			<StatLabel>{label}</StatLabel>
			<p className="font-heading text-2xl tabular-nums text-foreground">
				{value}
			</p>
		</div>
	)
}

/**
 * Balance-forward header for Order History.
 *
 * "What do I owe?" is the question this tab exists to answer, and scanning a
 * list of rows for it is work. Outstanding is payable-only (see
 * `summarizeOrders`) so the figure is money the member can actually settle.
 *
 * One slim strip, not stat columns: three short facts don't earn a tall
 * three-column card, and every pixel it gives up goes to the order list.
 */
function OrderSummaryBar({ summary, className }: OrderSummaryBarProps) {
	const showPay = summary.hasPayable && summary.outstanding.length > 0

	return (
		<Card
			className={cn(
				// Mobile stacks the stats as label/value rows; sm+ is one slim strip
				// of three equal segments.
				"gap-y-3 px-5 py-4 sm:flex-row sm:flex-wrap sm:items-center sm:gap-x-6 sm:py-3.5",
				className,
			)}
		>
			<div className="flex flex-wrap items-center justify-between gap-x-3 gap-y-2 sm:flex-1 sm:justify-start">
				<StatLabel>Outstanding</StatLabel>
				<OutstandingValue summary={summary} />
				{showPay ? (
					<Button asChild size="sm" className="w-full sm:w-auto">
						<Link
							to="/my-account"
							search={{ tab: "order-history", orders: "unpaid" }}
						>
							Pay now
						</Link>
					</Button>
				) : null}
			</div>

			<div className="hidden w-px self-stretch bg-border sm:block" aria-hidden />

			<Stat label="Unpaid" value={summary.unpaidCount} />

			<div className="hidden w-px self-stretch bg-border sm:block" aria-hidden />

			<Stat label="Orders" value={summary.totalCount} />
		</Card>
	)
}

export { OrderSummaryBar }
