import { Plus } from "lucide-react"

import { cn } from "@/lib/utils"

export type AccountFieldGridRow = {
	label: string
	value: string | null | undefined
	/** Span full width (e.g. email). */
	span?: 1 | 2
	/**
	 * Show a dashed "Add" affordance when empty instead of hiding the row.
	 * Only set this for fields the owning edit dialog can actually write —
	 * an Add button that opens a dialog without the field is a dead end.
	 */
	addable?: boolean
}

type AccountFieldGridProps = {
	rows: AccountFieldGridRow[]
	emptyMessage?: string
	/** Opens the owning edit dialog. Required for `addable` rows to render. */
	onAdd?: (row: AccountFieldGridRow) => void
	className?: string
}

function AddFieldButton({
	label,
	onClick,
}: {
	label: string
	onClick: () => void
}) {
	return (
		<button
			type="button"
			onClick={onClick}
			className="inline-flex items-center gap-1 rounded-md border border-dashed border-primary/40 bg-primary/5 px-2 py-0.5 text-xs font-semibold text-primary hover:bg-primary/10"
		>
			<Plus className="size-3" aria-hidden />
			Add
			<span className="sr-only"> {label}</span>
		</button>
	)
}

function hasValue(value: string | null | undefined): boolean {
	return value !== null && value !== undefined && value !== ""
}

/**
 * Label-above-value fields in a responsive grid — fills card width better than
 * a single column.
 *
 * Empty rows are hidden unless they are `addable` and an `onAdd` handler is
 * supplied, in which case they surface as a dashed prompt. That is what closes
 * the loop between the completeness meter naming a gap and the user fixing it.
 */
function AccountFieldGrid({
	rows,
	emptyMessage = "Nothing added yet.",
	onAdd,
	className,
}: AccountFieldGridProps) {
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
		<dl
			className={cn(
				"grid grid-cols-1 gap-x-4 gap-y-3 sm:grid-cols-2",
				className,
			)}
		>
			{shown.map((row) => (
				<div
					key={row.label}
					className={cn("min-w-0", row.span === 2 && "sm:col-span-2")}
				>
					<dt className="text-xs font-medium text-muted-foreground">
						{row.label}
					</dt>
					<dd className="mt-0.5 break-words text-sm text-foreground">
						{hasValue(row.value) ? (
							row.value
						) : (
							<AddFieldButton
								label={row.label}
								onClick={() => onAdd?.(row)}
							/>
						)}
					</dd>
				</div>
			))}
		</dl>
	)
}

export { AccountFieldGrid }
