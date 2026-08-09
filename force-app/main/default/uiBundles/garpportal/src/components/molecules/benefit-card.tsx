import { Lock } from "lucide-react"

import type { Benefit } from "@/api/membership/types"
import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { CardCta } from "@/components/molecules/card-cta"
import { cn } from "@/lib/utils"

/** Shared height so every benefit card in a row matches; body scrolls for overflow. */
const BENEFIT_CARD_HEIGHT = "h-[28rem]"

type BenefitCardProps = {
	benefit: Benefit
	className?: string
}

function BenefitCard({ benefit, className }: BenefitCardProps) {
	return (
		<Card
			className={cn(
				"relative gap-0 overflow-hidden border-border py-0 shadow-none",
				BENEFIT_CARD_HEIGHT,
				className,
			)}
		>
			{benefit.imageUrl ? (
				<div className="relative shrink-0">
					<img
						src={benefit.imageUrl}
						alt=""
						className="h-32 w-full object-cover"
						onError={(event) => {
							event.currentTarget.style.display = "none"
						}}
					/>
				</div>
			) : null}

			<CardHeader className="shrink-0 px-5 pt-4 pb-2">
				<CardTitle className="font-heading text-base tracking-wide text-foreground">
					{benefit.title ?? "Benefit"}
				</CardTitle>
			</CardHeader>

			<CardContent
				className={cn(
					"min-h-0 flex-1 space-y-2 overflow-y-auto px-5",
					"[scrollbar-width:none] [&::-webkit-scrollbar]:hidden",
				)}
			>
				{benefit.paragraphs.map((paragraph) => (
					<p key={paragraph} className="text-sm text-muted-foreground">
						{paragraph}
					</p>
				))}

				{benefit.bullets.length > 0 ? (
					<ul className="list-disc space-y-1 pl-5 text-sm text-muted-foreground">
						{benefit.bullets.map((bullet) => (
							<li key={bullet}>{bullet}</li>
						))}
					</ul>
				) : null}

				{benefit.promoCode ? (
					<p className="text-sm text-muted-foreground">
						Promo code:{" "}
						<span className="font-mono font-semibold text-foreground">
							{benefit.promoCode}
						</span>
					</p>
				) : null}
			</CardContent>

			{benefit.locked ? (
				<div
					className="pointer-events-none absolute inset-x-0 top-0 bottom-14 z-10 flex items-center justify-center bg-background/65 backdrop-blur-[2px]"
					aria-hidden
				>
					<div className="flex flex-col items-center gap-2 px-4 text-center">
						<span className="flex size-11 items-center justify-center rounded-full border border-border bg-card text-foreground shadow-sm">
							<Lock className="size-5" aria-hidden />
						</span>
						<p className="text-sm font-semibold text-foreground">
							Individual Membership
						</p>
						<p className="max-w-[14rem] text-xs text-muted-foreground">
							Upgrade to unlock this benefit
						</p>
					</div>
				</div>
			) : null}

			<CardFooter className="relative z-20 mt-auto shrink-0 border-t border-border/60 bg-card px-5 py-4">
				<CardCta
					label={benefit.ctaLabel}
					url={benefit.ctaUrl}
					isExternal={benefit.ctaIsExternal}
					locked={benefit.locked}
					newWindow={benefit.opensInNewWindow}
				/>
			</CardFooter>
		</Card>
	)
}

export { BenefitCard }
