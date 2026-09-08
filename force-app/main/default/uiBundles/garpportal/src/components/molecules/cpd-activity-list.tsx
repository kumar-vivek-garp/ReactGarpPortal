import { CalendarCheck, ClipboardList, Pencil, Trash2 } from "lucide-react"

import type { CpdClaim } from "@/api/cpd"
import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { EmptyState } from "@/components/molecules/empty-state"
import { MetaLines } from "@/components/molecules/meta-lines"
import { StatusBadge } from "@/components/molecules/status-badge"
import { CPD_SECTION_COPY, type CpdSection } from "@/config/cpd"
import { buildClaimRowPresentation } from "@/lib/cpd-presentation"
import { cn } from "@/lib/utils"

/** Per-section chrome: the row's glyph and the badge every row in it carries. */
const SECTION_META = {
	pending: {
		icon: ClipboardList,
		badge: { label: "Pending", tone: "warning" },
	},
	approved: {
		icon: CalendarCheck,
		badge: { label: "Approved", tone: "success" },
	},
} as const

type CpdActivityListProps = {
	section: CpdSection
	claims: CpdClaim[]
	/** Pending rows only — approved claims cannot be edited or removed. */
	onEdit?: (claim: CpdClaim) => void
	onDelete?: (claim: CpdClaim) => void
	/** Approved rows only. */
	onView?: (claim: CpdClaim) => void
	/**
	 * Off when a tab already names the section — the tab and an identical `h2`
	 * an inch below it say the same word twice.
	 */
	showTitle?: boolean
	className?: string
}

/**
 * Pending or approved activities for a cycle.
 *
 * Rows are cards in the shape `OrderRow` established — glyph tile, title, meta
 * run, then the figure and its status — rather than the four-column table this
 * started as. The legacy table had no column headers at all, and a table of
 * four cells only earns its scanning cost when there are columns worth
 * comparing down; a claim is one thing with a date, a type and a figure.
 */
function CpdActivityList({
	section,
	claims,
	onEdit,
	onDelete,
	onView,
	showTitle = true,
	className,
}: CpdActivityListProps) {
	const copy = CPD_SECTION_COPY[section]
	const meta = SECTION_META[section]
	const Icon = meta.icon

	/*
	 * When "see the rest of it" is a row's ONLY action, the row itself is the
	 * control: the shared interactive Card already carries the hover lift, the
	 * press squash and a focus ring, and a lone Details button beside a fully
	 * clickable card is a second target for one job. A pending row keeps its
	 * buttons — Edit and Delete are two different actions, and neither is what
	 * a click on the row should be taken to mean.
	 */
	const rowOpensDetails = Boolean(onView) && !onEdit && !onDelete
	const hasActionButtons = Boolean(onEdit || onDelete || (onView && !rowOpensDetails))

	return (
		<section className={cn("space-y-3", className)}>
			{showTitle ? (
				<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
					{copy.title}
					{claims.length > 0 ? (
						<span className="ml-2 text-base font-normal text-muted-foreground">
							({claims.length})
						</span>
					) : null}
				</h2>
			) : null}

			{claims.length === 0 ? (
				<EmptyState icon={Icon} title={copy.emptyLabel} className="py-10" />
			) : (
				<ul className="space-y-3">
					{claims.map((claim, index) => {
						const row = buildClaimRowPresentation(claim)
						return (
							<li key={claim.claimId ?? `${section}-${index}`}>
								<Card
									interactive={rowOpensDetails}
									role={rowOpensDetails ? "button" : undefined}
									tabIndex={rowOpensDetails ? 0 : undefined}
									aria-label={
										rowOpensDetails ? `View ${row.title}` : undefined
									}
									onActivate={
										rowOpensDetails && onView
											? () => onView(claim)
											: undefined
									}
									className={cn(
										"gap-4 p-4 sm:flex-row sm:items-center",
										// An interactive card owns its elevation through
										// the spring, so it must not carry a static one.
										!rowOpensDetails && "shadow-none",
									)}
								>
									{/*
									 * Neutral-primary tile, not status-toned — the badge
									 * beside it already carries the semantic colour, and
									 * two status signals on one row compete.
									 */}
									<span
										className="flex size-11 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
										aria-hidden
									>
										<Icon className="size-5" />
									</span>

									<div className="min-w-0 flex-1 space-y-1.5">
										<h3 className="font-heading text-base leading-snug tracking-wide text-foreground">
											{row.title}
										</h3>
										<MetaLines
											lines={row.metaLines}
											className="flex flex-wrap gap-x-4 gap-y-1 space-y-0"
										/>
									</div>

									<div className="flex shrink-0 flex-wrap items-center gap-x-4 gap-y-2 sm:flex-col sm:items-end">
										<p className="text-base font-semibold tabular-nums text-foreground">
											{row.creditsLabel}
										</p>
										<StatusBadge
											label={meta.badge.label}
											tone={meta.badge.tone}
										/>
									</div>

									{/*
									 * Rendered only when it holds something: an empty
									 * flex box still spends the row's `gap` and pushes
									 * the figures in off the right edge.
									 */}
									{hasActionButtons ? (
										<div className="flex shrink-0 items-center gap-1 sm:ml-2">
											{onView && !rowOpensDetails ? (
												<Button
													type="button"
													variant="outline"
													size="sm"
													onClick={() => onView(claim)}
												>
													Details
												</Button>
											) : null}
											{onEdit ? (
												<Button
													type="button"
													variant="ghost"
													size="icon-sm"
													aria-label={`Edit ${row.title}`}
													onClick={() => onEdit(claim)}
												>
													<Pencil className="size-4" />
												</Button>
											) : null}
											{onDelete ? (
												<Button
													type="button"
													variant="ghost"
													size="icon-sm"
													aria-label={`Delete ${row.title}`}
													className="text-muted-foreground hover:text-destructive"
													onClick={() => onDelete(claim)}
												>
													<Trash2 className="size-4" />
												</Button>
											) : null}
										</div>
									) : null}
								</Card>
							</li>
						)
					})}
				</ul>
			)}
		</section>
	)
}

export { CpdActivityList }
