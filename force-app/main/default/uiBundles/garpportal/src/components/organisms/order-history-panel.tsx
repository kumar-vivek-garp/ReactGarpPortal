import { useMemo, useState } from "react"
import { animated, useTransition } from "@react-spring/web"
import { useNavigate } from "@tanstack/react-router"
import { Search } from "lucide-react"
import type { LucideIcon } from "lucide-react"

import type { PortalOrder } from "@/api/orders/types"
import { Input } from "@/components/atoms/input"
import { ToggleGroup, ToggleGroupItem } from "@/components/atoms/toggle-group"
import { OrderHistorySkeleton } from "@/components/molecules/page-pending"
import { OrderRow } from "@/components/molecules/order-row"
import { OrderSummaryBar } from "@/components/molecules/order-summary-bar"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import {
	DEFAULT_ORDER_FILTER,
	ORDER_FILTER_ITEMS,
	ORDER_FILTER_SECTIONS,
	ORDER_SECTION_META,
	ORDERS_ZERO_STATE,
	type OrderFilter,
	type OrderSection,
} from "@/config/order-history"
import { useOrders } from "@/hooks/use-orders"
import { orderMatches, summarizeOrders } from "@/lib/order-presentation"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"

type OrderHistoryPanelProps = {
	/** When false, the orders query does not run. */
	enabled: boolean
	/** Bucket filter from `?orders=`. Absent means the default. */
	filter: OrderFilter | undefined
}

/** Shared zero/empty treatment — same recipe as the programs empty state. */
function OrdersEmptyState({
	icon: Icon,
	title,
	message,
}: {
	icon: LucideIcon
	title: string
	message?: string
}) {
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{title}
			</p>
			{message ? (
				<p className="mt-2 max-w-md text-sm text-muted-foreground">{message}</p>
			) : null}
		</div>
	)
}

function OrderSectionBlock({
	section,
	orders,
	hasSearch,
	/** Headings only earn their space when both sections are on screen. */
	showHeading,
}: {
	section: OrderSection
	orders: PortalOrder[]
	hasSearch: boolean
	showHeading: boolean
}) {
	const meta = ORDER_SECTION_META[section]
	const Icon = meta.icon

	return (
		<section className="space-y-4">
			{showHeading ? (
				<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
					<Icon className="size-5 shrink-0 text-primary" aria-hidden />
					{meta.heading}
					<span className="text-base font-normal text-muted-foreground">
						({orders.length})
					</span>
				</h2>
			) : null}

			{orders.length === 0 ? (
				<OrdersEmptyState
					icon={Icon}
					title={hasSearch ? meta.searchEmptyTitle : meta.emptyTitle}
					message={hasSearch ? undefined : meta.emptyMessage}
				/>
			) : (
				<StaggerReveal className="flex flex-col gap-3">
					{orders.map((order) => (
						<OrderRow key={order.id} order={order} />
					))}
				</StaggerReveal>
			)}
		</section>
	)
}

function OrderHistoryPanel({ enabled, filter }: OrderHistoryPanelProps) {
	const navigate = useNavigate({ from: "/my-account/" })
	const { data, isLoading, isError } = useOrders(enabled)
	const [term, setTerm] = useState("")
	const trimmed = term.trim()

	const unpaidAll = useMemo(() => data?.unpaidOrders ?? [], [data])
	const paidAll = useMemo(() => data?.paidOrders ?? [], [data])

	const summary = useMemo(
		() => summarizeOrders(unpaidAll, paidAll),
		[unpaidAll, paidAll],
	)

	const matched = useMemo(
		() => ({
			unpaid: unpaidAll.filter((order) => orderMatches(order, trimmed)),
			paid: paidAll.filter((order) => orderMatches(order, trimmed)),
		}),
		[unpaidAll, paidAll, trimmed],
	)

	const activeFilter = filter ?? DEFAULT_ORDER_FILTER

	const selectFilter = (next: OrderFilter) => {
		void navigate({
			// Functional updater — a literal would drop `?status=`, which carries
			// the Stripe auto-renew return signal for the account-information tab.
			search: (prev) => ({ ...prev, orders: next }),
			replace: true,
		})
	}

	const filterTransitions = useTransition(activeFilter, TAB_PANEL_TRANSITION)

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

	if (summary.totalCount === 0) {
		return (
			<OrdersEmptyState
				icon={ORDERS_ZERO_STATE.icon}
				title={ORDERS_ZERO_STATE.title}
				message={ORDERS_ZERO_STATE.message}
			/>
		)
	}

	const filterCount: Record<OrderFilter, number> = {
		all: summary.totalCount,
		unpaid: summary.unpaidCount,
		paid: summary.paidCount,
	}

	return (
		<div className="space-y-6">
			<OrderSummaryBar summary={summary} />

			<div className="flex flex-wrap items-center justify-between gap-3">
				<div className="relative min-w-0 flex-1 sm:max-w-md">
					<Search
						className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground"
						aria-hidden
					/>
					<Input
						value={term}
						onChange={(event) => setTerm(event.target.value)}
						placeholder="Search by invoice, description, or amount"
						aria-label="Search orders"
						className="h-10 rounded-xl pr-3 pl-9 shadow-none"
					/>
				</div>

				<ToggleGroup
					variant="outline"
					type="single"
					value={activeFilter}
					onValueChange={(value) => {
						// Radix allows deselecting the active item; ignore that.
						if (!value) return
						selectFilter(value as OrderFilter)
					}}
					aria-label="Filter orders"
				>
					{ORDER_FILTER_ITEMS.map((item) => (
						<ToggleGroupItem key={item.value} value={item.value}>
							{item.label}
							<span className="font-normal opacity-80">
								({filterCount[item.value]})
							</span>
						</ToggleGroupItem>
					))}
				</ToggleGroup>
			</div>

			{filterTransitions((style, currentFilter) => (
				<animated.div key={currentFilter} style={style}>
					{/*
					 * Remount on filter change so the cascade replays — `useTrail` will
					 * not re-run on its own because the `to` values are unchanged.
					 */}
					<div className="space-y-8">
						{ORDER_FILTER_SECTIONS[currentFilter].map((section) => (
							<OrderSectionBlock
								key={section}
								section={section}
								orders={matched[section]}
								hasSearch={Boolean(trimmed)}
								showHeading={ORDER_FILTER_SECTIONS[currentFilter].length > 1}
							/>
						))}
					</div>
				</animated.div>
			))}
		</div>
	)
}

export { OrderHistoryPanel }
