import { useState } from "react"

import type { StudyMaterialItem } from "@/api/study-materials/types"
import { Badge } from "@/components/atoms/badge"
import { Card } from "@/components/atoms/card"
import { EBookTitleList } from "@/components/molecules/ebook-title-list"
import { GarpLearningAddOnCard } from "@/components/molecules/garp-learning-add-on"
import { MetaLines } from "@/components/molecules/meta-lines"
import { StatusBadge } from "@/components/molecules/status-badge"
import { StudyMaterialAction } from "@/components/molecules/study-material-action"
import { StudyMaterialDetailsDialog } from "@/components/molecules/study-material-details-dialog"
import { programBrandSurface } from "@/config/program-brand"
import {
	materialMetaLines,
	materialStatusBadge,
	resolveMaterialAction,
	studyCodeLabel,
} from "@/lib/study-materials-presentation"
import { cn } from "@/lib/utils"

type StudyMaterialRowProps = {
	item: StudyMaterialItem
	priority?: boolean
	className?: string
}

/**
 * List row for one material — denser than the card and better for scanning a
 * long catalogue for one title.
 *
 * Shares every rule with `StudyMaterialCard`, so grid and list can never
 * disagree about status, price or actions.
 */
function StudyMaterialRow({
	item,
	priority = false,
	className,
}: StudyMaterialRowProps) {
	const brand = programBrandSurface(item.programKey)
	const codeLabel = studyCodeLabel(item.programKey)
	const action = resolveMaterialAction(item)
	const badge = materialStatusBadge(item)
	const metaLines = materialMetaLines(item)
	const [detailsOpen, setDetailsOpen] = useState(false)

	return (
		<Card
			className={cn(
				// Same flat, bordered treatment as the grid card this row shares
				// rules with — Card's own border/bg/radius apply as-is, only the
				// row's flex layout is added on top.
				"gap-4 p-4 shadow-none sm:flex-row sm:items-center",
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
					<span className="font-heading text-sm font-bold tracking-wider text-heading/70">
						{codeLabel}
					</span>
				)}
			</div>

			<div className="min-w-0 flex-1 space-y-2">
				<div className="flex flex-wrap items-center gap-2">
					<Badge className={cn("rounded-md font-bold tracking-wider", brand.chip)}>
						{codeLabel}
					</Badge>
					{badge ? <StatusBadge label={badge.label} tone={badge.tone} /> : null}
					{item.typeLabel ? (
						<Badge variant="outline" className="rounded-md font-semibold">
							{item.typeLabel}
						</Badge>
					) : null}
				</div>

				{/*
				 * Title and blurb open the full description. A plain button rather
				 * than an overlay: this column also holds the eBook list and the
				 * add-on card, both of which have buttons an overlay would cover.
				 */}
				<button
					type="button"
					onClick={() => setDetailsOpen(true)}
					aria-label={`View details for ${item.title}`}
					className={cn(
						"block w-full cursor-pointer space-y-2 rounded-md text-left",
						"focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
					)}
				>
					<h3 className="font-heading text-base leading-snug tracking-wide text-heading">
						{item.title}
					</h3>

					{item.description ? (
						<p className="line-clamp-1 text-sm text-muted-foreground">
							{item.description}
						</p>
					) : null}
				</button>

				<MetaLines lines={metaLines} className="space-y-1" />

				{item.eBookSet ? (
					<EBookTitleList titles={item.eBookSet.titles} />
				) : null}

				{item.addOn ? <GarpLearningAddOnCard addOn={item.addOn} /> : null}
			</div>

			<div className="flex shrink-0 flex-wrap items-center gap-x-5 gap-y-2 sm:flex-col sm:items-end">
				<StudyMaterialAction action={action} />
			</div>

			<StudyMaterialDetailsDialog
				item={item}
				open={detailsOpen}
				onOpenChange={setDetailsOpen}
			/>
		</Card>
	)
}

export { StudyMaterialRow }
