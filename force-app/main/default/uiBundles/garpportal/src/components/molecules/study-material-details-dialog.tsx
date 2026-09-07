import type { StudyMaterialItem } from "@/api/study-materials/types"
import { Badge } from "@/components/atoms/badge"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from "@/components/atoms/dialog"
import { EBookTitleList } from "@/components/molecules/ebook-title-list"
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

type StudyMaterialDetailsDialogProps = {
	item: StudyMaterialItem
	open: boolean
	onOpenChange: (open: boolean) => void
}

/**
 * The whole of one material, for a card that can only afford three lines of it.
 *
 * The listing clamps `description` to keep every card the same height, which
 * on the longer blurbs cuts mid-sentence. This is where the rest of it lives
 * (UI/UX request, Sep 2026).
 *
 * It re-derives its action from the item rather than being handed one, so the
 * button here and the button on the card can never drift apart: both are
 * `resolveMaterialAction`'s answer for the same material.
 *
 * The description arrives as HTML from the catalogue and is stripped to text
 * on the way in (`normalize.stripHtml`), so it is rendered as text — nothing
 * in this bundle sets `dangerouslySetInnerHTML` and this is not the place to
 * start.
 */
function StudyMaterialDetailsDialog({
	item,
	open,
	onOpenChange,
}: StudyMaterialDetailsDialogProps) {
	const brand = programBrandSurface(item.programKey)
	const badge = materialStatusBadge(item)
	const action = resolveMaterialAction(item)
	const metaLines = materialMetaLines(item)

	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent className="max-h-[85vh] gap-0 overflow-hidden p-0 sm:max-w-lg">
				{item.imageUrl ? (
					<div
						className={cn(
							"flex h-40 shrink-0 items-center justify-center p-4",
							brand.surface,
						)}
					>
						<img
							src={item.imageUrl}
							alt=""
							className="max-h-full max-w-full object-contain"
							onError={(event) => {
								event.currentTarget.style.display = "none"
							}}
						/>
					</div>
				) : null}

				<div className="min-h-0 flex-1 overflow-y-auto px-6 py-5">
					<DialogHeader className="gap-2 text-left">
						<div className="flex flex-wrap items-center gap-2">
							<Badge
								className={cn(
									"rounded-md font-bold tracking-wider",
									brand.chip,
								)}
							>
								{studyCodeLabel(item.programKey)}
							</Badge>
							{item.typeLabel ? (
								<Badge variant="secondary" className="rounded-md">
									{item.typeLabel}
								</Badge>
							) : null}
							{badge ? <StatusBadge label={badge.label} tone={badge.tone} /> : null}
						</div>

						<DialogTitle className="font-heading text-xl leading-snug tracking-wide">
							{item.title}
						</DialogTitle>

						{/*
						 * Unclamped — the entire reason this dialog exists. Blank
						 * rather than absent when the catalogue has no copy, so the
						 * dialog never opens onto a title and nothing else.
						 */}
						<DialogDescription className="text-sm whitespace-pre-line text-muted-foreground">
							{item.description ?? "No description is available for this item."}
						</DialogDescription>
					</DialogHeader>

					{metaLines.length > 0 ? (
						<div className="mt-4">
							<MetaLines lines={metaLines} />
						</div>
					) : null}

					{item.eBookSet ? (
						<div className="mt-4 space-y-1">
							<p className="text-sm font-semibold text-foreground">Your eBooks</p>
							<EBookTitleList titles={item.eBookSet.titles} />
						</div>
					) : null}
				</div>

				{action.kind !== "none" ? (
					<div className="flex shrink-0 flex-wrap items-center gap-x-6 gap-y-2 border-t border-border px-6 py-4">
						<StudyMaterialAction action={action} />
					</div>
				) : null}
			</DialogContent>
		</Dialog>
	)
}

export { StudyMaterialDetailsDialog }
