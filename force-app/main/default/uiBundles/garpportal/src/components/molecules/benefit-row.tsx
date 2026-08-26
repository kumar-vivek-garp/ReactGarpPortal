import { BadgeCheck } from "lucide-react"

import type { Benefit } from "@/api/membership/types"
import { Card } from "@/components/atoms/card"
import { BenefitDetailsDialog } from "@/components/molecules/benefit-details-dialog"
import { CardCta } from "@/components/molecules/card-cta"
import { StatusBadge } from "@/components/molecules/status-badge"
import { buildBenefitPresentation } from "@/lib/membership-presentation"
import { cn } from "@/lib/utils"

type BenefitRowProps = {
	benefit: Benefit
	priority?: boolean
	className?: string
}

/**
 * List row for one membership benefit — denser than the card and better for
 * scanning many benefits for one by name.
 *
 * Shares `buildBenefitPresentation` with `BenefitCard`, so grid and list can
 * never disagree about copy, lock state or the CTA. A locked benefit keeps the
 * card's blur-overlay treatment out of the row — the "Members only" badge plus
 * the padlock on the CTA carry the same fact at row density.
 */
function BenefitRow({ benefit, priority = false, className }: BenefitRowProps) {
	const item = buildBenefitPresentation(benefit)
	const summary =
		item.body ?? (item.bullets.length > 0 ? item.bullets.join(" · ") : null)

	return (
		<Card
			className={cn(
				// Same flat, bordered treatment as the grid card this row shares
				// presentation with — only the row's flex layout is added on top.
				"gap-4 p-4 shadow-none sm:flex-row sm:items-center",
				className,
			)}
		>
			<div className="h-16 w-full shrink-0 overflow-hidden rounded-lg bg-muted/40 sm:w-24">
				{item.imageUrl ? (
					<img
						src={item.imageUrl}
						alt=""
						decoding="async"
						fetchPriority={priority ? "high" : "auto"}
						loading={priority ? "eager" : "lazy"}
						className="size-full object-cover"
						onError={(event) => {
							event.currentTarget.style.display = "none"
						}}
					/>
				) : (
					<div className="flex size-full items-center justify-center">
						<BadgeCheck className="size-6 text-muted-foreground" aria-hidden />
					</div>
				)}
			</div>

			<div className="min-w-0 flex-1 space-y-2">
				{item.statusLabel && item.statusTone ? (
					<div className="flex flex-wrap items-center gap-2">
						<StatusBadge label={item.statusLabel} tone={item.statusTone} />
					</div>
				) : null}

				<h3 className="font-heading text-base leading-snug tracking-wide text-foreground">
					{item.title}
				</h3>

				{summary ? (
					<p className="line-clamp-1 text-sm text-muted-foreground">{summary}</p>
				) : null}

				{item.promoCode ? (
					<p className="text-sm text-muted-foreground">
						Promo code:{" "}
						<span className="font-mono font-semibold text-foreground">
							{item.promoCode}
						</span>
					</p>
				) : null}
			</div>

			{item.cta || item.hasDetails ? (
				<div className="flex shrink-0 flex-wrap items-center gap-x-5 gap-y-2 sm:flex-col sm:items-end">
					{item.cta ? (
						<CardCta
							label={item.cta.label}
							url={item.cta.url}
							isExternal={item.cta.isExternal}
							locked={item.locked}
							newWindow={item.cta.newWindow}
						/>
					) : null}
					{item.hasDetails ? (
						<BenefitDetailsDialog item={item} className="-my-1 sm:-mr-2" />
					) : null}
				</div>
			) : null}
		</Card>
	)
}

export { BenefitRow }
