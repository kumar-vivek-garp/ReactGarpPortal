import { cn } from "@/lib/utils"

export type AccountFieldRow = {
	label: string
	value: string | null | undefined
}

type AccountFieldListProps = {
	rows: AccountFieldRow[]
	emptyMessage?: string
	className?: string
}

function AccountFieldList({
	rows,
	emptyMessage = "Nothing added yet.",
	className,
}: AccountFieldListProps) {
	const populated = rows.filter(
		(row) => row.value !== null && row.value !== undefined && row.value !== "",
	)

	if (populated.length === 0) {
		return <p className={cn("text-sm text-muted-foreground", className)}>{emptyMessage}</p>
	}

	return (
		<dl className={cn("space-y-1.5", className)}>
			{populated.map((row) => (
				<div key={row.label} className="text-sm">
					<dt className="inline text-muted-foreground">{row.label}: </dt>
					<dd className="inline text-foreground">{row.value}</dd>
				</div>
			))}
		</dl>
	)
}

export { AccountFieldList }
