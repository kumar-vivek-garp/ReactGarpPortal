import { Plus } from "lucide-react"

import { cn } from "@/lib/utils"

export type AccountFieldRow = {
	label: string
	value: string | null | undefined
	/**
	 * Show a dashed "Add" affordance when empty instead of hiding the row.
	 * Only set this for fields the owning edit dialog can actually write.
	 */
	addable?: boolean
}

type AccountFieldListProps = {
	rows: AccountFieldRow[]
	emptyMessage?: string
	/** Opens the owning edit dialog. Required for `addable` rows to render. */
	onAdd?: (row: AccountFieldRow) => void
	className?: string
}

function hasValue(value: string | null | undefined): boolean {
	return value !== null && value !== undefined && value !== ""
}

/**
 * Label / value rows with hairline dividers — the dense counterpart to
 * `AccountFieldGrid`, for long single-column runs (career, membership).
 */
function AccountFieldList({
	rows,
	emptyMessage = "Nothing added yet.",
	onAdd,
	className,
}: AccountFieldListProps) {
	const shown = rows.filter(
		(row) => hasValue(row.value) || (row.addable && onAdd),
	)

	if (shown.length === 0) {
		return (
			<p className={cn("text-sm text-muted-foreground", className)}>
				{emptyMessage}
			</p>
		)
	}

	return (
		<dl className={cn("flex flex-col", className)}>
			{shown.map((row) => (
				<div
					key={row.label}
					className="flex items-baseline justify-between gap-4 border-b border-border/60 py-1.5 last:border-0"
				>
					<dt className="min-w-0 shrink text-xs text-muted-foreground">
						{row.label}
					</dt>
					<dd className="min-w-0 break-words text-right text-sm text-foreground">
						{hasValue(row.value) ? (
							row.value
						) : (
							<button
								type="button"
								onClick={() => onAdd?.(row)}
								className="inline-flex items-center gap-1 rounded-md border border-dashed border-primary/40 bg-primary/5 px-2 py-0.5 text-xs font-semibold text-primary hover:bg-primary/10"
							>
								<Plus className="size-3" aria-hidden />
								Add
								<span className="sr-only"> {row.label}</span>
							</button>
						)}
					</dd>
				</div>
			))}
		</dl>
	)
}

export { AccountFieldList }
