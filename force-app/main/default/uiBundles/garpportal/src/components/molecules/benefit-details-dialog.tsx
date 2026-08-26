import { Info } from "lucide-react"

import { Button } from "@/components/atoms/button"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
	DialogTrigger,
} from "@/components/atoms/dialog"
import { CardCta } from "@/components/molecules/card-cta"
import { StatusBadge } from "@/components/molecules/status-badge"
import type { BenefitPresentation } from "@/lib/membership-presentation"
import { cn } from "@/lib/utils"

type BenefitDetailsDialogProps = {
	item: BenefitPresentation
	/** Applied to the trigger button, so callers can position it. */
	className?: string
}

/**
 * Full copy for one benefit — the card clamps its body to four lines and trims
 * bullets to three, so without this the tail of the description was simply
 * unreachable. Trigger and dialog travel together so both the grid card and
 * the list row get the identical affordance.
 *
 * Locked benefits open it too — reading what a benefit is, is exactly how a
 * member decides an upgrade is worth it.
 */
function BenefitDetailsDialog({ item, className }: BenefitDetailsDialogProps) {
	const [lede, ...restParagraphs] = item.paragraphs

	return (
		<Dialog>
			<DialogTrigger asChild>
				<Button
					type="button"
					variant="ghost"
					size="sm"
					className={cn("gap-1.5 text-muted-foreground hover:text-foreground", className)}
					aria-label={`About ${item.title}`}
				>
					<Info className="size-4" aria-hidden />
					Details
				</Button>
			</DialogTrigger>
			{/* Radix requires an explicit opt-out when no Description is rendered. */}
			<DialogContent
				className="sm:max-w-lg"
				{...(lede ? {} : { "aria-describedby": undefined })}
			>
				<DialogHeader>
					{item.statusLabel && item.statusTone ? (
						<div className="flex flex-wrap items-center gap-2">
							<StatusBadge label={item.statusLabel} tone={item.statusTone} />
						</div>
					) : null}
					<DialogTitle className="font-heading tracking-wide">
						{item.title}
					</DialogTitle>
					{lede ? <DialogDescription>{lede}</DialogDescription> : null}
				</DialogHeader>

				<div className="max-h-[55vh] space-y-3 overflow-y-auto overscroll-contain text-sm text-muted-foreground">
					{item.imageUrl ? (
						<img
							src={item.imageUrl}
							alt=""
							loading="lazy"
							decoding="async"
							className="h-36 w-full rounded-lg object-cover"
							onError={(event) => {
								event.currentTarget.style.display = "none"
							}}
						/>
					) : null}

					{restParagraphs.map((paragraph) => (
						<p key={paragraph}>{paragraph}</p>
					))}

					{item.allBullets.length > 0 ? (
						<ul className="list-disc space-y-1 pl-5">
							{item.allBullets.map((bullet) => (
								<li key={bullet}>{bullet}</li>
							))}
						</ul>
					) : null}

					{item.promoCode ? (
						<p>
							Promo code:{" "}
							<span className="font-mono font-semibold text-foreground">
								{item.promoCode}
							</span>
						</p>
					) : null}
				</div>

				{item.cta ? (
					<div className="flex justify-end border-t border-border/60 pt-4">
						<CardCta
							label={item.cta.label}
							url={item.cta.url}
							isExternal={item.cta.isExternal}
							locked={item.locked}
							newWindow={item.cta.newWindow}
						/>
					</div>
				) : null}
			</DialogContent>
		</Dialog>
	)
}

export { BenefitDetailsDialog }
