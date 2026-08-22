import { ChevronLeft, ChevronRight } from "lucide-react"

import { Button } from "@/components/atoms/button"
import { pageRange } from "@/lib/cpd-presentation"
import { cn } from "@/lib/utils"

type CpdPaginationProps = {
	page: number
	pageSize: number
	pageCount: number
	totalCount: number | null
	onPageChange: (page: number) => void
	/** True while the next page is in flight, to avoid double-stepping. */
	busy?: boolean
	className?: string
}

/**
 * Prev / next paging over a server-paged list.
 *
 * Deliberately not the legacy's "Load More", which grew `pageSize` by 50 and
 * refetched the whole list from the top each time — so page four re-queried 200
 * rows to show 50 new ones. It also decided whether more existed by comparing
 * `length === pageSize` while ignoring the `totalCount` the server already
 * sends; this uses that count.
 */
function CpdPagination({
	page,
	pageSize,
	pageCount,
	totalCount,
	onPageChange,
	busy = false,
	className,
}: CpdPaginationProps) {
	if (pageCount <= 1) return null

	const range = pageRange(page, pageSize, totalCount)

	return (
		<nav
			className={cn("flex flex-wrap items-center justify-between gap-3", className)}
			aria-label="Credit opportunities pages"
		>
			<p className="text-sm text-muted-foreground" aria-live="polite">
				Showing <span className="tabular-nums">{range.from}</span>–
				<span className="tabular-nums">{range.to}</span> of{" "}
				<span className="tabular-nums">{range.total}</span>
			</p>

			<div className="flex items-center gap-2">
				<Button
					type="button"
					variant="outline"
					size="sm"
					disabled={busy || page <= 1}
					onClick={() => onPageChange(page - 1)}
				>
					<ChevronLeft className="size-4" aria-hidden />
					Previous
				</Button>
				<span className="text-sm text-muted-foreground tabular-nums">
					Page {page} of {pageCount}
				</span>
				<Button
					type="button"
					variant="outline"
					size="sm"
					disabled={busy || page >= pageCount}
					onClick={() => onPageChange(page + 1)}
				>
					Next
					<ChevronRight className="size-4" aria-hidden />
				</Button>
			</div>
		</nav>
	)
}

export { CpdPagination }
