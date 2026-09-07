import { Package } from "lucide-react"

import type { MaterialQuote } from "@/api/study-materials/types"
import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { STUDY_MATERIAL_PURCHASE } from "@/config/study-materials"
import { formatMoney } from "@/lib/account-format"

type PurchaseItemSectionProps = {
	quote: MaterialQuote
}

/**
 * What is being bought — the one line item, with its art and how it arrives.
 *
 * Mirrors the exam rail's material tile: `object-contain` on a neutral tile,
 * because book covers come in every aspect ratio and cropping one to a square
 * cuts the title off the front of it.
 */
function PurchaseItemSection({ quote }: PurchaseItemSectionProps) {
	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<Package className="size-5 text-muted-foreground" aria-hidden />
					{STUDY_MATERIAL_PURCHASE.itemHeading}
				</CardTitle>
			</CardHeader>
			<CardContent className="flex items-center gap-4">
				{quote.imageURL ? (
					<div className="flex size-20 shrink-0 items-center justify-center overflow-hidden rounded-lg bg-muted">
						<img
							src={quote.imageURL}
							alt=""
							loading="lazy"
							className="size-full object-contain"
						/>
					</div>
				) : null}
				<div className="flex min-w-0 flex-1 flex-col gap-1">
					<h2 className="font-heading text-lg leading-snug font-semibold tracking-wide text-foreground">
						{quote.title ?? "Study material"}
					</h2>
					<p className="text-body text-muted-foreground">
						{quote.isShippable
							? STUDY_MATERIAL_PURCHASE.deliveryPrinted
							: STUDY_MATERIAL_PURCHASE.deliveryOnline}
					</p>
				</div>
				<span className="shrink-0 text-body font-semibold text-foreground tabular-nums">
					{formatMoney(quote.price, STUDY_MATERIAL_PURCHASE.currency)}
				</span>
			</CardContent>
		</Card>
	)
}

export { PurchaseItemSection }
