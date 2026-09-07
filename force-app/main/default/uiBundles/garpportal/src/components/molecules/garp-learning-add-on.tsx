import type { GarpLearningAddOn } from "@/api/study-materials/types"
import { CardCta } from "@/components/molecules/card-cta"
import { orderDetailsPath } from "@/lib/order-paths"
import { formatPrice } from "@/lib/study-materials-presentation"
import { cn } from "@/lib/utils"

type GarpLearningAddOnCardProps = {
	addOn: GarpLearningAddOn
	className?: string
}

/**
 * The FRM Part I practice-exam upgrade, offered on the GARP Learning card.
 *
 * Display only, as the legacy has it: the price is shown, but the add-on is
 * never a row of its own and `materialQuote` refuses its product code, so
 * there is no Purchase link to offer. A pending order for it is the one thing
 * the member can act on, and that points at the order.
 */
function GarpLearningAddOnCard({ addOn, className }: GarpLearningAddOnCardProps) {
	const price = addOn.kind === "purchasable" ? formatPrice(addOn.price) : null
	const pendingOrderPath =
		addOn.kind === "purchasable" ? orderDetailsPath(addOn.pendingOrderId) : null

	return (
		<div
			className={cn("rounded-lg border border-border bg-muted/40 p-3", className)}
			data-testid="garp-learning-add-on"
		>
			<p className="text-sm font-semibold text-foreground">{addOn.heading}</p>
			{addOn.description ? (
				<p className="mt-1 text-sm text-muted-foreground">{addOn.description}</p>
			) : null}
			{price || pendingOrderPath ? (
				<div className="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1">
					{price ? (
						<span className="text-sm font-semibold text-foreground">{price}</span>
					) : null}
					{pendingOrderPath ? (
						<CardCta
							label="Order awaiting payment"
							url={pendingOrderPath}
							isExternal={false}
						/>
					) : null}
				</div>
			) : null}
		</div>
	)
}

export { GarpLearningAddOnCard }
