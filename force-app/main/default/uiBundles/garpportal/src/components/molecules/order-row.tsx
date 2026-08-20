import { useNavigate } from "@tanstack/react-router"
import { ReceiptText } from "lucide-react"

import type { PortalOrder } from "@/api/orders/types"
import { Card } from "@/components/atoms/card"
import { MetaLines } from "@/components/molecules/meta-lines"
import { StatusBadge } from "@/components/molecules/status-badge"
import { buildOrderRowPresentation } from "@/lib/order-presentation"
import { cn } from "@/lib/utils"

type OrderRowProps = {
	order: PortalOrder
	className?: string
}

/**
 * One purchase. Whole card navigates via Card `onActivate` so press motion
 * settles before the route change.
 */
function OrderRow({ order, className }: OrderRowProps) {
	const navigate = useNavigate()
	const { description, amountLabel, metaLines, statusLabel, statusTone } =
		buildOrderRowPresentation(order)

	return (
		<Card
			interactive
			role="link"
			tabIndex={0}
			aria-label={`View order ${description}`}
			className={cn(
				// No `shadow-none` — interactive Card owns elevation via spring.
				"gap-4 p-4 sm:flex-row sm:items-center",
				className,
			)}
			onActivate={() => {
				void navigate({
					to: "/my-account/orders/$orderNumber",
					params: { orderNumber: order.id },
				})
			}}
		>
			{/*
			 * The tile stays neutral-primary rather than status-toned — the badge
			 * already carries the semantic colour, and two status signals on one row
			 * compete instead of reinforcing.
			 */}
			<span
				className="flex size-11 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
				aria-hidden
			>
				<ReceiptText className="size-5" />
			</span>

			<div className="min-w-0 flex-1 space-y-1.5">
				<h3 className="font-heading text-base leading-snug tracking-wide text-foreground">
					{description}
				</h3>
				{/* Horizontal run rather than the default stack, so a row stays a row. */}
				<MetaLines
					lines={metaLines}
					className="flex flex-wrap gap-x-4 gap-y-1 space-y-0"
				/>
			</div>

			<div className="flex shrink-0 flex-wrap items-center gap-x-4 gap-y-2 sm:flex-col sm:items-end">
				<p className="text-base font-semibold tabular-nums text-foreground">
					{amountLabel}
				</p>
				<StatusBadge label={statusLabel} tone={statusTone} />
			</div>
		</Card>
	)
}

export { OrderRow }
