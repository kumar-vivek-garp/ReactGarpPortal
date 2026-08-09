import { useState } from "react"

import { Input } from "@/components/atoms/input"
import { Skeleton } from "@/components/atoms/skeleton"
import type { PortalOrder } from "@/api/orders/types"
import { useOrders } from "@/hooks/use-orders"
import { formatLongDate, formatMoney } from "@/lib/account-format"

type OrderHistoryPanelProps = {
	/** When false, the orders query does not run. */
	enabled: boolean
}

function orderMatches(order: PortalOrder, term: string): boolean {
	if (!term) return true
	const needle = term.toLowerCase()
	return [
		order.invoiceNumber,
		order.description,
		order.paymentStatus,
		order.stage,
		formatLongDate(order.orderDate),
		order.amount == null ? null : String(order.amount),
		formatMoney(order.amount, order.currencyCode),
	]
		.filter(Boolean)
		.some((field) => String(field).toLowerCase().includes(needle))
}

function OrderRow({ order }: { order: PortalOrder }) {
	const amount = formatMoney(order.amount, order.currencyCode)

	return (
		<div className="grid grid-cols-1 items-center gap-2 rounded-xl border border-border bg-card px-5 py-4 sm:grid-cols-[minmax(0,12rem)_minmax(0,10rem)_1fr_auto]">
			<span className="text-sm text-muted-foreground">
				{formatLongDate(order.orderDate) ?? "—"}
			</span>
			<span className="text-sm font-medium text-garp-cyan">{order.invoiceNumber ?? "—"}</span>
			<span className="text-sm text-foreground">{order.description ?? "GARP Order"}</span>
			<span className="text-sm font-medium text-foreground sm:text-right">{amount ?? "—"}</span>
		</div>
	)
}

function OrderHistorySkeleton() {
	return (
		<div className="space-y-8" aria-busy aria-label="Loading orders">
			<Skeleton className="h-9 w-full max-w-md rounded-md" />
			{[0, 1].map((section) => (
				<div key={section} className="space-y-3">
					<Skeleton className="h-7 w-48 rounded-sm" />
					{[0, 1, 2].map((row) => (
						<Skeleton key={row} className="h-16 w-full rounded-xl" />
					))}
				</div>
			))}
		</div>
	)
}

function OrderSection({
	title,
	orders,
	emptyLabel,
	searchEmptyLabel,
	hasSearch,
}: {
	title: string
	orders: PortalOrder[]
	emptyLabel: string
	searchEmptyLabel: string
	hasSearch: boolean
}) {
	return (
		<section className="space-y-3">
			<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
				{title}
			</h2>
			{orders.length === 0 ? (
				<p className="py-3 text-sm text-muted-foreground">
					{hasSearch ? searchEmptyLabel : emptyLabel}
				</p>
			) : (
				<div className="space-y-3">
					{orders.map((order) => (
						<OrderRow key={order.id} order={order} />
					))}
				</div>
			)}
		</section>
	)
}

function OrderHistoryPanel({ enabled }: OrderHistoryPanelProps) {
	const { data, isLoading, isError } = useOrders(enabled)
	const [term, setTerm] = useState("")
	const trimmed = term.trim()

	const unpaid = (data?.unpaidOrders ?? []).filter((o) => orderMatches(o, trimmed))
	const paid = (data?.paidOrders ?? []).filter((o) => orderMatches(o, trimmed))

	// `isLoading` (pending + fetching), not `isPending` — disabled queries stay pending.
	if (isLoading) {
		return <OrderHistorySkeleton />
	}

	if (isError) {
		return (
			<p className="text-sm text-muted-foreground">
				We couldn&apos;t load your order history. Please try again later.
			</p>
		)
	}

	return (
		<div className="space-y-8">
			<Input
				value={term}
				onChange={(event) => setTerm(event.target.value)}
				placeholder="Search"
				aria-label="Search orders"
				className="h-11 max-w-md rounded-lg shadow-none focus-visible:border-ring focus-visible:ring-0 focus-visible:ring-offset-0"
			/>

			<OrderSection
				title="Unpaid Purchases"
				orders={unpaid}
				emptyLabel="No unpaid orders"
				searchEmptyLabel="No unpaid orders match your search"
				hasSearch={Boolean(trimmed)}
			/>

			<OrderSection
				title="Paid Purchases"
				orders={paid}
				emptyLabel="No paid orders"
				searchEmptyLabel="No paid orders match your search"
				hasSearch={Boolean(trimmed)}
			/>
		</div>
	)
}

export { OrderHistoryPanel }
