import { ReceiptText } from "lucide-react"

import type { MaterialQuote } from "@/api/study-materials/types"
import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { AnimatedAmount } from "@/components/forms/exam-registration/animated-amount"
import { STUDY_MATERIAL_PURCHASE } from "@/config/study-materials"
import { materialQuoteLines } from "@/lib/study-material-checkout"
import { cn } from "@/lib/utils"

type PurchaseSummaryRailProps = {
	quote: MaterialQuote
}

/**
 * The pinned right column — the money, always on screen while the address is
 * filled in. The exam rail carries a cart that re-prices; this one carries
 * three fixed lines, so the figures never blur, but they share the rail's
 * height cap and its rows so the two pages read as one checkout.
 *
 * No `overscroll-contain`, deliberately: when the rail bottoms out the wheel
 * should keep scrolling the page.
 */
function PurchaseSummaryRail({ quote }: PurchaseSummaryRailProps) {
	const lines = materialQuoteLines(quote)
	const currency = STUDY_MATERIAL_PURCHASE.currency

	return (
		<div className="flex max-h-[calc(100vh-13.5rem)] flex-col gap-4 overflow-y-auto scrollbar-none">
			<Card>
				<CardHeader>
					<CardTitle className="flex items-center gap-2 text-base">
						<ReceiptText className="size-4 text-muted-foreground" aria-hidden />
						{STUDY_MATERIAL_PURCHASE.summaryHeading}
					</CardTitle>
				</CardHeader>
				<CardContent className="flex flex-col gap-2">
					{lines.map((line) => (
						<div key={line.key} className="contents">
							{line.emphasis ? <hr className="border-border" /> : null}
							<div
								className={cn(
									"flex items-baseline justify-between gap-4",
									line.emphasis ? "text-lg font-semibold" : "text-body",
								)}
							>
								<span
									className={cn(
										"min-w-0",
										line.emphasis ? "text-foreground" : "text-muted-foreground",
									)}
								>
									{line.label}
								</span>
								{line.amount == null ? (
									<span className="shrink-0 text-caption text-muted-foreground">
										{STUDY_MATERIAL_PURCHASE.shippingUnknown}
									</span>
								) : (
									<AnimatedAmount
										amount={line.amount}
										currency={currency}
										pending={false}
										className={cn("shrink-0", line.emphasis && "text-primary")}
									/>
								)}
							</div>
						</div>
					))}
					<p className="pt-1 text-caption leading-relaxed text-muted-foreground">
						{STUDY_MATERIAL_PURCHASE.taxNote}
					</p>
				</CardContent>
			</Card>
		</div>
	)
}

export { PurchaseSummaryRail }
