import { Pencil, Trash2 } from "lucide-react"

import type { CpdClaim } from "@/api/cpd"
import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { CPD_SECTION_COPY, type CpdSection } from "@/config/cpd"
import { buildClaimRowPresentation } from "@/lib/cpd-presentation"
import { cn } from "@/lib/utils"

type CpdActivityListProps = {
	section: CpdSection
	claims: CpdClaim[]
	/** Pending rows only — approved claims cannot be edited or removed. */
	onEdit?: (claim: CpdClaim) => void
	onDelete?: (claim: CpdClaim) => void
	/** Approved rows only. */
	onView?: (claim: CpdClaim) => void
	className?: string
}

/**
 * Pending or approved activities for a cycle.
 *
 * The legacy table had no column headers at all — four unlabelled cells told
 * apart only by CSS — so the header row here is an addition, not a port.
 */
function CpdActivityList({
	section,
	claims,
	onEdit,
	onDelete,
	onView,
	className,
}: CpdActivityListProps) {
	const copy = CPD_SECTION_COPY[section]
	const hasActions = Boolean(onEdit || onDelete || onView)

	return (
		<section className={cn("space-y-3", className)}>
			<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
				{copy.title}
				{claims.length > 0 ? (
					<span className="ml-2 text-base font-normal text-muted-foreground">
						({claims.length})
					</span>
				) : null}
			</h2>

			{claims.length === 0 ? (
				<div className="rounded-xl border border-dashed border-border bg-muted/20 px-6 py-8 text-center">
					<p className="text-sm text-muted-foreground">{copy.emptyLabel}</p>
				</div>
			) : (
				<Card className="gap-0 px-5 py-4 shadow-none">
					<div
						className="hidden grid-cols-[9rem_minmax(0,1fr)_7rem_6rem] gap-4 border-b border-border/80 pb-2 text-xs font-semibold tracking-wider text-muted-foreground uppercase sm:grid"
						aria-hidden
					>
						<span>Completed</span>
						<span>Activity</span>
						<span className="text-right">Credits</span>
						<span className="text-right">{hasActions ? "Actions" : ""}</span>
					</div>
					<ul className="divide-y divide-border/80">
						{claims.map((claim, index) => {
							const row = buildClaimRowPresentation(claim)
							return (
								<li
									key={claim.claimId ?? `${section}-${index}`}
									className="grid gap-1 py-3 first:pt-3 last:pb-0 sm:grid-cols-[9rem_minmax(0,1fr)_7rem_6rem] sm:items-center sm:gap-4"
								>
									<span className="text-sm text-muted-foreground">
										{row.dateLabel ?? "—"}
									</span>
									<span className="text-sm font-medium text-foreground">
										{row.title}
									</span>
									<span className="text-sm tabular-nums text-foreground sm:text-right">
										{row.creditsLabel}
									</span>
									{hasActions ? (
										<span className="flex items-center gap-1 sm:justify-end">
											{onView ? (
												<Button
													type="button"
													variant="link"
													size="sm"
													className="h-auto px-0 text-sm"
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
										</span>
									) : null}
								</li>
							)
						})}
					</ul>
				</Card>
			)}
		</section>
	)
}

export { CpdActivityList }
