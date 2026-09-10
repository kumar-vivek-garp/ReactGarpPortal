import { useState } from "react"

import type { StudyMaterialItem } from "@/api/study-materials/types"
import { Badge } from "@/components/atoms/badge"
import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
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

type StudyMaterialCardProps = {
	item: StudyMaterialItem
	/** Mark above-the-fold artwork as an LCP candidate. */
	priority?: boolean
	className?: string
}

/**
 * Grid card for one material.
 *
 * Brand tint and code chip come from the item's program bucket, reusing the
 * programs palette — these materials *are* the FRM / SCR / RAI books, so they
 * should carry the same identity as the program cards. What the card can DO
 * is decided by `resolveMaterialAction`; the card only renders the answer.
 */
function StudyMaterialCard({
	item,
	priority = false,
	className,
}: StudyMaterialCardProps) {
	const brand = programBrandSurface(item.programKey)
	const action = resolveMaterialAction(item)
	const badge = materialStatusBadge(item)
	const metaLines = materialMetaLines(item)
	const [detailsOpen, setDetailsOpen] = useState(false)

	return (
		<Card
			className={cn(
				"h-full gap-4 overflow-hidden py-0 shadow-none",
				className,
			)}
		>
			{/*
			 * The details trigger covers the artwork, the title and the blurb —
			 * not the whole card. Below this region sit the eBook list and the
			 * action, which have buttons of their own that an overlay would
			 * swallow. It is a SIBLING laid over the region rather than a
			 * wrapper, because a <button> may not contain one.
			 */}
			<div className="relative">
				<button
					type="button"
					onClick={() => setDetailsOpen(true)}
					aria-label={`View details for ${item.title}`}
					className={cn(
						"absolute inset-0 z-10 cursor-pointer rounded-t-xl",
						"focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
					)}
				/>

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

				<CardHeader className="gap-2 px-5 pt-4">
				<div className="flex flex-wrap items-center gap-2">
					<Badge className={cn("rounded-md font-bold tracking-wider", brand.chip)}>
						{studyCodeLabel(item.programKey)}
					</Badge>
					{badge ? <StatusBadge label={badge.label} tone={badge.tone} /> : null}
					{item.typeLabel ? (
						<Badge variant="outline" className="rounded-md font-semibold">
							{item.typeLabel}
						</Badge>
					) : null}
				</div>
					<CardTitle className="font-heading text-lg leading-snug tracking-wide text-heading">
						{item.title}
					</CardTitle>

					{item.description ? (
						<p className="line-clamp-3 text-sm text-muted-foreground">
							{item.description}
						</p>
					) : null}
				</CardHeader>
			</div>

			<CardContent className="flex-1 space-y-3 px-5">
				<MetaLines lines={metaLines} />

				{item.eBookSet ? (
					<div className="space-y-1">
						<p className="text-sm font-semibold text-foreground">Your eBooks</p>
						<EBookTitleList titles={item.eBookSet.titles} />
					</div>
				) : null}

				{item.addOn ? <GarpLearningAddOnCard addOn={item.addOn} /> : null}
			</CardContent>

			{action.kind !== "none" ? (
				<CardFooter className="mt-auto flex flex-wrap items-center gap-x-6 gap-y-2 px-5 pb-5">
					<StudyMaterialAction action={action} />
				</CardFooter>
			) : (
				<div className="pb-5" />
			)}

			<StudyMaterialDetailsDialog
				item={item}
				open={detailsOpen}
				onOpenChange={setDetailsOpen}
			/>
		</Card>
	)
}

export { StudyMaterialCard }
