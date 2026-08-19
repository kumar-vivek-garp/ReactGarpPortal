import { Badge } from "@/components/atoms/badge"
import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { CardCta } from "@/components/molecules/card-cta"
import { MetaLines } from "@/components/molecules/meta-lines"
import { StatusBadge } from "@/components/molecules/status-badge"
import { programBrandSurface } from "@/config/program-brand"
import type { StudyItemPresentation } from "@/lib/study-materials-presentation"
import { cn } from "@/lib/utils"

type StudyMaterialCardProps = {
	item: StudyItemPresentation
	/** Mark above-the-fold artwork as an LCP candidate. */
	priority?: boolean
	className?: string
}

/**
 * Grid card for an owned material or a catalogue entry.
 *
 * Brand tint and code chip come from the item's program bucket, reusing the
 * programs palette — these materials *are* the FRM / SCR / RAI books, so they
 * should carry the same identity as the program cards.
 */
function StudyMaterialCard({
	item,
	priority = false,
	className,
}: StudyMaterialCardProps) {
	const brand = programBrandSurface(item.programKey)
	const showFooter = Boolean(item.primaryAction || item.secondaryAction)

	return (
		<Card
			className={cn(
				"h-full gap-4 overflow-hidden border-border py-0 shadow-none",
				className,
			)}
		>
			<div
				className={cn(
					"flex h-36 shrink-0 items-center justify-center p-4",
					brand.surface,
				)}
			>
				{item.imageUrl ? (
					<img
						src={item.imageUrl}
						alt=""
						decoding="async"
						fetchPriority={priority ? "high" : "auto"}
						loading={priority ? "eager" : "lazy"}
						className="max-h-full max-w-full object-contain"
						onError={(event) => {
							event.currentTarget.style.display = "none"
						}}
					/>
				) : null}
			</div>

			<CardHeader className="gap-2 px-5 pt-1">
				<div className="flex flex-wrap items-center gap-2">
					<Badge className={cn("rounded-md font-bold tracking-wider", brand.chip)}>
						{item.codeLabel}
					</Badge>
					{item.statusLabel && item.statusTone ? (
						<StatusBadge label={item.statusLabel} tone={item.statusTone} />
					) : null}
					{item.typeLabel ? (
						<Badge variant="outline" className="rounded-md font-semibold">
							{item.typeLabel}
						</Badge>
					) : null}
				</div>
				<CardTitle className="font-heading text-lg leading-snug tracking-wide text-foreground">
					{item.title}
				</CardTitle>
			</CardHeader>

			<CardContent className="flex-1 space-y-3 px-5">
				{item.paragraphs.length > 0 ? (
					<p className="line-clamp-3 text-sm text-muted-foreground">
						{item.paragraphs.join(" ")}
					</p>
				) : null}

				<MetaLines lines={item.metaLines} />
			</CardContent>

			{showFooter ? (
				<CardFooter className="mt-auto flex flex-wrap items-center gap-x-6 gap-y-2 px-5 pb-5">
					{item.primaryAction ? (
						<CardCta
							label={item.primaryAction.label}
							url={item.primaryAction.url}
							isExternal={item.primaryAction.isExternal}
							newWindow={item.primaryAction.newWindow}
						/>
					) : null}
					{item.secondaryAction ? (
						<CardCta
							label={item.secondaryAction.label}
							url={item.secondaryAction.url}
							isExternal={item.secondaryAction.isExternal}
						/>
					) : null}
				</CardFooter>
			) : (
				<div className="pb-5" />
			)}
		</Card>
	)
}

export { StudyMaterialCard }
