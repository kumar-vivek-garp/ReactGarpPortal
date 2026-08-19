import { Badge } from "@/components/atoms/badge"
import { CardCta } from "@/components/molecules/card-cta"
import { MetaLines } from "@/components/molecules/meta-lines"
import { StatusBadge } from "@/components/molecules/status-badge"
import { programBrandSurface } from "@/config/program-brand"
import type { StudyItemPresentation } from "@/lib/study-materials-presentation"
import { cn } from "@/lib/utils"

type StudyMaterialRowProps = {
	item: StudyItemPresentation
	priority?: boolean
	className?: string
}

/**
 * List row for an owned material or a catalogue entry — denser than the card and
 * better for scanning a long catalogue for one title.
 *
 * Shares `StudyItemPresentation` with `StudyMaterialCard`, so grid and list can
 * never disagree about status, price or actions.
 */
function StudyMaterialRow({
	item,
	priority = false,
	className,
}: StudyMaterialRowProps) {
	const brand = programBrandSurface(item.programKey)

	return (
		<div
			className={cn(
				"flex flex-col gap-4 rounded-xl border border-border bg-card p-4 sm:flex-row sm:items-center",
				className,
			)}
		>
			<div
				className={cn(
					"flex h-16 w-full shrink-0 items-center justify-center rounded-lg p-2 sm:w-24",
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
				) : (
					<span className="font-heading text-sm font-bold tracking-wider text-foreground/70">
						{item.codeLabel}
					</span>
				)}
			</div>

			<div className="min-w-0 flex-1 space-y-2">
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

				<h3 className="font-heading text-base leading-snug tracking-wide text-foreground">
					{item.title}
				</h3>

				{item.paragraphs.length > 0 ? (
					<p className="line-clamp-1 text-sm text-muted-foreground">
						{item.paragraphs.join(" ")}
					</p>
				) : null}

				<MetaLines lines={item.metaLines} className="space-y-1" />
			</div>

			<div className="flex shrink-0 flex-wrap items-center gap-x-5 gap-y-2 sm:flex-col sm:items-end">
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
			</div>
		</div>
	)
}

export { StudyMaterialRow }
