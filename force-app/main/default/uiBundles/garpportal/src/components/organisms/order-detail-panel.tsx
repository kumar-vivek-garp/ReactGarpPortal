import { animated, useSpring } from "@react-spring/web"
import { Link, useNavigate } from "@tanstack/react-router"
import { Download, Loader2, ReceiptText } from "lucide-react"
import type { ReactNode } from "react"

import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { AccountFieldList } from "@/components/molecules/account-field-list"
import { AccountSectionCard } from "@/components/molecules/account-section-card"
import { MetaLines } from "@/components/molecules/meta-lines"
import { OrderDetailHeader } from "@/components/molecules/order-detail-header"
import { OrderDetailSkeleton } from "@/components/molecules/page-pending/order-detail-pending"
import { StatusBadge } from "@/components/molecules/status-badge"
import { invoicePdfUrl } from "@/config/order-history"
import { useCancelOrder } from "@/hooks/use-cancel-order"
import { useOrderDetail } from "@/hooks/use-order-detail"
import { usePayOrder } from "@/hooks/use-pay-order"
import type { OrderDetailCallout } from "@/lib/order-detail-presentation"
import { buildOrderDetailPresentation } from "@/lib/order-detail-presentation"
import type { MetaLine } from "@/lib/meta-line"
import { cn } from "@/lib/utils"

/** Forward-nav feel when opening `/my-account/orders/$orderNumber`. */
const DETAIL_ENTER_SPRING = { mass: 0.9, tension: 320, friction: 26 }

type OrderDetailPanelProps = {
	orderNumber: string
}

function Callout({
	tone,
	title,
	children,
}: {
	tone: OrderDetailCallout["tone"]
	title: string
	children: ReactNode
}) {
	return (
		<div
			className={cn(
				"rounded-lg border p-3 text-sm text-foreground",
				tone === "warning" && "border-destructive/50 bg-destructive/10",
				tone === "pending" && "border-garp-saffron/50 bg-garp-saffron/15",
				tone === "neutral" && "border-border bg-muted/40",
			)}
		>
			<p className="font-heading font-semibold">{title}</p>
			<div className="mt-1 text-muted-foreground">{children}</div>
		</div>
	)
}

function DetailBody({ orderNumber }: { orderNumber: string }) {
	const navigate = useNavigate()
	const { data, isLoading, isError, error } = useOrderDetail(orderNumber)
	const pay = usePayOrder()
	const cancel = useCancelOrder()
	const order = data?.order ?? null
	const presentation = order ? buildOrderDetailPresentation(order) : null
	const busy = pay.isPending || cancel.isPending

	function downloadOrder(orderId: string) {
		window.open(invoicePdfUrl(orderId), "_blank", "noopener,noreferrer")
	}

	function onPay() {
		if (!order) return
		pay.mutate(order.id, {
			onSuccess: (result) => {
				if (result.statusCode === 201) {
					void navigate({
						to: "/my-account",
						search: { tab: "order-history" },
					})
				}
			},
		})
	}

	function onCancel() {
		if (!order) return
		cancel.mutate(order.id, {
			onSuccess: () => {
				void navigate({
					to: "/my-account",
					search: { tab: "order-history" },
				})
			},
		})
	}

	if (isLoading) return <OrderDetailSkeleton />

	if (isError || !order || !presentation) {
		return (
			<p className="text-sm text-muted-foreground">
				{error instanceof Error && error.message
					? error.message
					: "This order could not be found on your account."}
			</p>
		)
	}

	const metaLines: MetaLine[] = presentation.summaryFields.map((field) => ({
		icon:
			field.label === "Purchase Date"
				? "when"
				: field.label === "Invoice"
					? "invoice"
					: "paymentMethod",
		text: `${field.label}: ${field.value}`,
	}))

	return (
		<div className="space-y-6 pb-2">
			{/* Summary hero — amount-first, same visual language as Order History. */}
			<Card className="gap-4 p-5 shadow-none sm:flex-row sm:items-center">
				<span
					className="flex size-12 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
					aria-hidden
				>
					<ReceiptText className="size-6" />
				</span>

				<div className="min-w-0 flex-1 space-y-2">
					<div className="flex flex-wrap items-center gap-2">
						<h1 className="font-heading text-2xl font-semibold tracking-wide text-foreground sm:text-3xl">
							{presentation.title}
						</h1>
						<StatusBadge
							label={presentation.statusLabel}
							tone={presentation.statusTone}
						/>
					</div>
					{metaLines.length > 0 ? (
						<MetaLines
							lines={metaLines}
							className="flex flex-wrap gap-x-4 gap-y-1 space-y-0"
						/>
					) : null}
				</div>

				{presentation.amountLabel ? (
					<p className="shrink-0 font-heading text-3xl font-semibold tabular-nums text-foreground">
						{presentation.amountLabel}
					</p>
				) : null}
			</Card>

			{presentation.callout ? (
				<Callout
					tone={presentation.callout.tone}
					title={presentation.callout.title}
				>
					<p>{presentation.callout.body}</p>
				</Callout>
			) : null}

			<AccountSectionCard
				title="Order details"
				subtitle="Everything returned for this purchase, including IDs Member Services may ask for."
			>
				<AccountFieldList
					rows={presentation.detailFields.map((field) => ({
						label: field.label,
						value: field.value,
					}))}
				/>
			</AccountSectionCard>

			<div className="flex flex-wrap items-center gap-3">
				{presentation.canPay ? (
					<Button type="button" disabled={busy} onClick={onPay}>
						{pay.isPending ? (
							<Loader2 className="size-4 animate-spin" aria-hidden />
						) : null}
						Pay Order
					</Button>
				) : null}

				<Button
					type="button"
					variant={presentation.canPay ? "outline" : "default"}
					disabled={busy}
					onClick={() => downloadOrder(presentation.orderId)}
				>
					<Download className="size-4" aria-hidden />
					Download Order
				</Button>

				{presentation.canCancel ? (
					<Button
						type="button"
						variant="outline"
						disabled={busy}
						onClick={onCancel}
					>
						{cancel.isPending ? (
							<Loader2 className="size-4 animate-spin" aria-hidden />
						) : null}
						Cancel Order
					</Button>
				) : null}

				<Button asChild variant="ghost">
					<Link to="/my-account" search={{ tab: "order-history" }}>
						View Orders
					</Link>
				</Button>
			</div>
		</div>
	)
}

function OrderDetailPanelView({ orderNumber }: OrderDetailPanelProps) {
	const enter = useSpring({
		from: { opacity: 0, transform: "translateX(18px)" },
		to: { opacity: 1, transform: "translateX(0px)" },
		config: DETAIL_ENTER_SPRING,
	})

	return (
		<animated.div
			style={enter}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<OrderDetailHeader />

			<div className="mt-4 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				<DetailBody orderNumber={orderNumber} />
			</div>
		</animated.div>
	)
}

/** Remount on param change so the enter spring re-runs between orders. */
function OrderDetailPanel({ orderNumber }: OrderDetailPanelProps) {
	return (
		<OrderDetailPanelView
			key={orderNumber.trim()}
			orderNumber={orderNumber}
		/>
	)
}

export { OrderDetailPanel }
