import { useState } from "react"
import { Search } from "lucide-react"

import type { PortalOrder } from "@/api/orders/types"
import { Button } from "@/components/atoms/button"
import { Input } from "@/components/atoms/input"
import { OrderHistorySkeleton } from "@/components/molecules/page-pending"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { useOrders } from "@/hooks/use-orders"
import { formatLongDate, formatMoney } from "@/lib/account-format"
import { cn } from "@/lib/utils"

type OrderHistoryPanelProps = {
	/** When false, the orders query does not run. */
	enabled: boolean
}

const PAY_MAILTO =
	"mailto:memberservices@garp.com?Subject=Payment%20for%20invoice"

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

function statusLabel(order: PortalOrder): string {
	if (order.paymentStatus?.trim()) return order.paymentStatus.trim()
	if (order.isPaid) return "Paid"
	if (order.stage?.trim()) return order.stage.trim()
	return order.canPay ? "Unpaid" : "—"
}

function OrderStatus({ order }: { order: PortalOrder }) {
	const label = statusLabel(order)
	return (
		<span
			className={cn(
				"inline-flex max-w-full truncate rounded-full px-2.5 py-0.5 text-xs font-semibold",
				order.isPaid
					? "bg-emerald-600/10 text-emerald-800 dark:text-emerald-300"
					: "bg-amber-500/15 text-amber-900 dark:text-amber-200",
			)}
		>
			{label}
		</span>
	)
}

function OrderRow({ order, showPay }: { order: PortalOrder; showPay: boolean }) {
	const amount = formatMoney(order.amount, order.currencyCode)

	return (
		<div
			className={cn(
				"grid grid-cols-1 gap-3 rounded-xl border border-border bg-muted/40 px-5 py-4 shadow-none",
				"sm:grid-cols-[minmax(0,9rem)_minmax(0,8rem)_minmax(0,1fr)_minmax(0,7rem)_auto] sm:items-center sm:gap-4",
				showPay && "sm:grid-cols-[minmax(0,9rem)_minmax(0,8rem)_minmax(0,1fr)_minmax(0,7rem)_auto_auto]",
			)}
		>
			<div className="min-w-0">
				<p className="text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:hidden">
					Date
				</p>
				<p className="text-sm text-foreground">
					{formatLongDate(order.orderDate) ?? "—"}
				</p>
			</div>

			<div className="min-w-0">
				<p className="text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:hidden">
					Invoice
				</p>
				<p className="truncate text-sm font-semibold text-garp-cyan">
					{order.invoiceNumber ?? "—"}
				</p>
			</div>

			<div className="min-w-0">
				<p className="text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:hidden">
					Description
				</p>
				<p className="text-sm text-foreground">{order.description ?? "GARP Order"}</p>
			</div>

			<div className="min-w-0 sm:text-right">
				<p className="text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:hidden">
					Amount
				</p>
				<p className="text-sm font-semibold tabular-nums text-foreground">
					{amount ?? "—"}
				</p>
			</div>

			<div className="min-w-0">
				<p className="text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:hidden">
					Status
				</p>
				<OrderStatus order={order} />
			</div>

			{showPay ? (
				<div className="sm:justify-self-end">
					{order.canPay ? (
						<Button asChild size="sm" variant="outline">
							<a href={PAY_MAILTO}>Pay now</a>
						</Button>
					) : (
						<span className="hidden text-sm text-muted-foreground sm:inline">—</span>
					)}
				</div>
			) : null}
		</div>
	)
}

function OrderSection({
	title,
	orders,
	emptyLabel,
	searchEmptyLabel,
	hasSearch,
	showPay,
}: {
	title: string
	orders: PortalOrder[]
	emptyLabel: string
	searchEmptyLabel: string
	hasSearch: boolean
	showPay: boolean
}) {
	return (
		<section className="space-y-3">
			<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
				{title}
				<span className="ml-2 text-base font-normal text-muted-foreground">
					({orders.length})
				</span>
			</h2>

			{orders.length === 0 ? (
				<div className="rounded-xl border border-dashed border-border bg-muted/20 px-5 py-8 text-center">
					<p className="text-sm text-muted-foreground">
						{hasSearch ? searchEmptyLabel : emptyLabel}
					</p>
				</div>
			) : (
				<div className="space-y-3">
					<div
						className={cn(
							"hidden gap-4 px-5 text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:grid",
							showPay
								? "sm:grid-cols-[minmax(0,9rem)_minmax(0,8rem)_minmax(0,1fr)_minmax(0,7rem)_auto_auto]"
								: "sm:grid-cols-[minmax(0,9rem)_minmax(0,8rem)_minmax(0,1fr)_minmax(0,7rem)_auto]",
						)}
						aria-hidden
					>
						<span>Date</span>
						<span>Invoice</span>
						<span>Description</span>
						<span className="text-right">Amount</span>
						<span>Status</span>
						{showPay ? <span className="text-right">Action</span> : null}
					</div>
					<StaggerReveal className="space-y-3">
						{orders.map((order) => (
							<OrderRow key={order.id} order={order} showPay={showPay} />
						))}
					</StaggerReveal>
				</div>
			)}
		</section>
	)
}

function OrderHistoryPanel({ enabled }: OrderHistoryPanelProps) {
	const { data, isLoading, isError } = useOrders(enabled)
	const [term, setTerm] = useState("")
	const trimmed = term.trim()

	const unpaidAll = data?.unpaidOrders ?? []
	const paidAll = data?.paidOrders ?? []
	const unpaid = unpaidAll.filter((o) => orderMatches(o, trimmed))
	const paid = paidAll.filter((o) => orderMatches(o, trimmed))
	const isEmpty = unpaidAll.length === 0 && paidAll.length === 0

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

	if (isEmpty) {
		return (
			<div className="rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
				<p className="font-heading text-lg font-semibold tracking-wide text-foreground">
					No orders yet
				</p>
				<p className="mt-2 text-sm text-muted-foreground">
					Exam registrations, membership, and event purchases appear here with their
					invoice numbers.
				</p>
			</div>
		)
	}

	return (
		<div className="space-y-8">
			<div className="relative max-w-md">
				<Search
					className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground"
					aria-hidden
				/>
				<Input
					value={term}
					onChange={(event) => setTerm(event.target.value)}
					placeholder="Search by invoice, description, or amount"
					aria-label="Search orders"
					className="h-11 rounded-lg pr-3 pl-9 shadow-none"
				/>
			</div>

			<OrderSection
				title="Unpaid Purchases"
				orders={unpaid}
				emptyLabel="No unpaid purchases"
				searchEmptyLabel="No unpaid purchases match your search"
				hasSearch={Boolean(trimmed)}
				showPay
			/>

			<OrderSection
				title="Paid Purchases"
				orders={paid}
				emptyLabel="No paid purchases"
				searchEmptyLabel="No paid purchases match your search"
				hasSearch={Boolean(trimmed)}
				showPay={false}
			/>
		</div>
	)
}

export { OrderHistoryPanel }
