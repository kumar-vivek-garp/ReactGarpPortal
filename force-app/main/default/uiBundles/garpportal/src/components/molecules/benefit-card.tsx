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
import { StatusBadge } from "@/components/molecules/status-badge"
import { buildBenefitPresentation } from "@/lib/membership-presentation"
import { cn } from "@/lib/utils"

type BenefitCardProps = {
	benefit: Benefit
	className?: string
}

function BenefitCard({ benefit, className }: BenefitCardProps) {
	const item = buildBenefitPresentation(benefit)

	return (
		<Card
			className={cn(
				// Natural height with clamped copy — see `buildBenefitPresentation`
				// for why this replaced a fixed height plus a hidden scroll area.
				"relative h-full gap-0 overflow-hidden py-0 shadow-none",
				className,
			)}
		>
			{item.imageUrl ? (
				<div className="relative shrink-0">
					<img
						src={item.imageUrl}
						alt=""
						loading="lazy"
						decoding="async"
						className="h-32 w-full object-cover"
						onError={(event) => {
							event.currentTarget.style.display = "none"
						}}
					/>
				</div>
			) : null}

			<CardHeader className="shrink-0 gap-2 px-5 pt-4 pb-2">
				{item.statusLabel && item.statusTone ? (
					<div className="flex flex-wrap items-center gap-2">
						<StatusBadge label={item.statusLabel} tone={item.statusTone} />
					</div>
				) : null}
				<CardTitle className="font-heading text-base tracking-wide text-foreground">
					{item.title}
				</CardTitle>
			</CardHeader>

			<CardContent className="flex-1 space-y-2 px-5 pb-4">
				{item.body ? (
					<p className="line-clamp-4 text-sm text-muted-foreground">
						{item.body}
					</p>
				) : null}

				{item.bullets.length > 0 ? (
					<ul className="list-disc space-y-1 pl-5 text-sm text-muted-foreground">
						{item.bullets.map((bullet) => (
							<li key={bullet} className="line-clamp-2">
								{bullet}
							</li>
						))}
					</ul>
				) : null}

				{item.hiddenBulletCount > 0 ? (
					<p className="text-xs text-muted-foreground">
						+{item.hiddenBulletCount} more
					</p>
				) : null}

				{item.promoCode ? (
					<p className="text-sm text-muted-foreground">
						Promo code:{" "}
						<span className="font-mono font-semibold text-foreground">
							{item.promoCode}
						</span>
					</p>
				) : null}
			</CardContent>

			{item.locked ? (
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
					label={item.cta?.label ?? null}
					url={item.cta?.url ?? null}
					isExternal={item.cta?.isExternal ?? false}
					locked={item.locked}
					newWindow={item.cta?.newWindow}
				/>
			</CardFooter>
		</Card>
	)
}

export { BenefitCard }
