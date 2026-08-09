import { cn } from "@/lib/utils"

export type AccountFieldGridRow = {
	label: string
	value: string | null | undefined
	/** Span full width (e.g. email). */
	span?: 1 | 2
}

type AccountFieldGridProps = {
	rows: AccountFieldGridRow[]
	emptyMessage?: string
	className?: string
}

/**
 * Label-above-value fields in a responsive grid — fills card width better than a single column.
 */
function AccountFieldGrid({
	rows,
	emptyMessage = "Nothing added yet.",
	className,
}: AccountFieldGridProps) {
	const populated = rows.filter(
		(row) => row.value !== null && row.value !== undefined && row.value !== "",
	)

	if (populated.length === 0) {
		return <p className={cn("text-sm text-muted-foreground", className)}>{emptyMessage}</p>
	}

	return (
		<dl className={cn("grid grid-cols-1 gap-x-4 gap-y-3 sm:grid-cols-2", className)}>
			{populated.map((row) => (
				<div
					key={row.label}
					className={cn("min-w-0", row.span === 2 && "sm:col-span-2")}
				>
					<dt className="text-xs font-medium text-muted-foreground">{row.label}</dt>
					<dd className="mt-0.5 break-words text-sm text-foreground">{row.value}</dd>
				</div>
			))}
		</dl>
	)
}

export { AccountFieldGrid }
