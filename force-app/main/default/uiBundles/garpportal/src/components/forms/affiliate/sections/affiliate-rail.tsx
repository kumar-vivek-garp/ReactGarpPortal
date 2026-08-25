import { Check, ReceiptText } from "lucide-react"

import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { AFFILIATE_BENEFITS, AFFILIATE_REGISTRATION } from "@/config/registration"

/**
 * The right-hand rail: what the membership includes, and what it comes to.
 *
 * The exam forms pin a live cart here; affiliate has no cart to pin, because
 * its order is a single AFREE line for zero. The slot is kept anyway and given
 * the one thing it can honestly hold — the offer itself — so the form reads as
 * the same checkout its siblings do rather than as a lone column of fields.
 *
 * The total is a constant, not a fetched figure: there is no `calculateFees`
 * call on this path, so nothing here can go stale or arrive late.
 *
 * Capped and scrolling internally, and deliberately *without*
 * `overscroll-contain`: when a secondary column bottoms out the wheel should
 * carry on scrolling the page. The cap subtracts everything above it — 5rem
 * fixed toolbar, 3rem shell `py-6`, 5.5rem `lg:top-22` pin offset — because
 * the rail's scroll parent is the form column, not the viewport.
 */
function AffiliateRail() {
	return (
		<div className="flex max-h-[calc(100vh-13.5rem)] flex-col gap-4 overflow-y-auto scrollbar-none">
			<Card>
				<CardHeader>
					<CardTitle className="flex items-center gap-2 text-base">
						<Check className="size-4 text-success-green" aria-hidden />
						Included with membership
					</CardTitle>
				</CardHeader>
				<CardContent>
					<StaggerReveal className="flex flex-col gap-3">
						{AFFILIATE_BENEFITS.map((benefit) => (
							<div key={benefit} className="flex items-start gap-3">
								<Check
									className="mt-0.5 size-4 shrink-0 text-success-green"
									aria-hidden
								/>
								<p className="text-body">{benefit}</p>
							</div>
						))}
					</StaggerReveal>
				</CardContent>
			</Card>

			<Card>
				<CardHeader>
					<CardTitle className="flex items-center gap-2 text-base">
						<ReceiptText className="size-4 text-muted-foreground" aria-hidden />
						Order summary
					</CardTitle>
				</CardHeader>
				<CardContent>
					<div className="flex flex-col gap-2">
						<div className="flex items-center justify-between gap-4 text-body">
							<span className="min-w-0 text-muted-foreground">
								{AFFILIATE_REGISTRATION.title}
							</span>
							<span className="shrink-0 text-success-green">Free</span>
						</div>

						<hr className="border-border" />

						<div className="flex items-center justify-between gap-4 text-body font-semibold">
							<span className="min-w-0">Total</span>
							<span className="shrink-0 text-primary">Free</span>
						</div>

						{/*
						 * Said plainly rather than left to be inferred from two zeroes:
						 * "free" on a registration form is the question people actually
						 * have, and there is no payment step further down to answer it.
						 */}
						<p className="pt-1 text-caption text-muted-foreground">
							Affiliate membership costs nothing and there is no payment step
							&mdash; you will not be asked for card details.
						</p>
					</div>
				</CardContent>
			</Card>
		</div>
	)
}

export { AffiliateRail }
