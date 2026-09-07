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

	return (
		<Card
			className={cn(
				"h-full gap-4 overflow-hidden py-0 shadow-none",
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
						{studyCodeLabel(item.programKey)}
					</Badge>
					{badge ? <StatusBadge label={badge.label} tone={badge.tone} /> : null}
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
				{item.description ? (
					<p className="line-clamp-3 text-sm text-muted-foreground">
						{item.description}
					</p>
				) : null}

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
		</Card>
	)
}

export { StudyMaterialCard }
