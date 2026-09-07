import { BookOpen, ExternalLink, Loader2 } from "lucide-react"

import type { EBookTitle } from "@/api/study-materials/types"
import { Button } from "@/components/atoms/button"
import { useOpenEBook } from "@/hooks/use-ebook-archive"
import { cn } from "@/lib/utils"

type EBookTitleListProps = {
	titles: EBookTitle[]
	/** The button's verb — "Read" on a material card, "Access" in the archive. */
	actionLabel?: string
	className?: string
}

/**
 * The titles an eBook key unlocks, each opened on demand.
 *
 * The reader link is minted when the button is pressed, not when the list
 * renders: the vendor signs a short-lived URL, so one fetched up front would
 * have expired by the time it is clicked. Pending and failure are per title —
 * one book that will not open must not lock its siblings.
 */
function EBookTitleList({
	titles,
	actionLabel = "Read",
	className,
}: EBookTitleListProps) {
	const open = useOpenEBook()
	const pendingId = open.isPending ? open.variables : null
	const failedId = open.isError ? open.variables : null

	return (
		<ul className={cn("divide-y divide-border/80", className)}>
			{titles.map((title) => (
				<li
					key={title.id}
					className="flex flex-wrap items-center gap-x-4 gap-y-2 py-2 first:pt-0 last:pb-0"
				>
					<BookOpen className="size-4 shrink-0 text-muted-foreground" aria-hidden />
					<div className="min-w-0 flex-1">
						<p className="text-sm text-foreground">{title.label}</p>
						{title.provider ? (
							<p className="text-xs text-muted-foreground">{title.provider}</p>
						) : null}
					</div>
					{title.vendorId ? (
						<div className="flex flex-wrap items-center gap-2">
							{failedId === title.vendorId ? (
								<span className="text-xs text-destructive" role="status">
									Link unavailable — try again shortly
								</span>
							) : null}
							<Button
								type="button"
								variant="outline"
								size="sm"
								disabled={pendingId === title.vendorId}
								onClick={() =>
									void open
										.mutateAsync(title.vendorId ?? "")
										.catch(() => undefined)
								}
							>
								{pendingId === title.vendorId ? (
									<Loader2 className="size-4 animate-spin" aria-hidden />
								) : (
									<ExternalLink className="size-4" aria-hidden />
								)}
								{actionLabel}
							</Button>
						</div>
					) : (
						/*
						 * Owned, but the key never resolved to a vendor item — there is
						 * nothing to open. Shown rather than hidden so the member can see
						 * what they paid for and ask about it.
						 */
						<span className="text-xs text-muted-foreground">
							Not available online
						</span>
					)}
				</li>
			))}
		</ul>
	)
}

export { EBookTitleList }
