import { X } from "lucide-react"

import { Button } from "@/components/atoms/button"
import type {
	DirectoryFilterState,
} from "@/components/molecules/directory-filters-dialog"
import { DIRECTORY_FILTERS, type DirectoryFilterKey } from "@/config/directory"
import { cn } from "@/lib/utils"

export type ActiveFilterChip = {
	id: string
	label: string
	remove: (current: DirectoryFilterState) => DirectoryFilterState
}

/**
 * Every filter currently in effect, as one flat list.
 *
 * The point is that a filter you cannot see is a filter you forget you set —
 * the usual "0 results" mystery. These sit under the search box so the reason
 * a list is narrow is always on screen, and each is removable without
 * reopening the dialog.
 */
export function activeFilterChips(
	state: DirectoryFilterState,
): ActiveFilterChip[] {
	const chips: ActiveFilterChip[] = []

	if (state.company.trim()) {
		chips.push({
			id: "company",
			label: `Company: ${state.company.trim()}`,
			remove: (current) => ({ ...current, company: "" }),
		})
	}

	for (const code of state.certifications) {
		chips.push({
			id: `cert-${code}`,
			label: code,
			remove: (current) => ({
				...current,
				certifications: current.certifications.filter((e) => e !== code),
			}),
		})
	}

	for (const filter of DIRECTORY_FILTERS) {
		for (const value of state.values[filter.key as DirectoryFilterKey]) {
			chips.push({
				id: `${filter.key}-${value}`,
				label: value,
				remove: (current) => ({
					...current,
					values: {
						...current.values,
						[filter.key]: current.values[
							filter.key as DirectoryFilterKey
						].filter((e) => e !== value),
					},
				}),
			})
		}
	}

	return chips
}

type DirectoryFilterChipsProps = {
	state: DirectoryFilterState
	onChange: (next: DirectoryFilterState) => void
	onClearAll: () => void
	className?: string
}

function DirectoryFilterChips({
	state,
	onChange,
	onClearAll,
	className,
}: DirectoryFilterChipsProps) {
	const chips = activeFilterChips(state)
	if (chips.length === 0) return null

	return (
		<div className={cn("flex flex-wrap items-center gap-2", className)}>
			{chips.map((chip) => (
				<button
					key={chip.id}
					type="button"
					onClick={() => onChange(chip.remove(state))}
					className="inline-flex items-center gap-1.5 rounded-full border border-border bg-muted/50 py-1 pe-1.5 ps-3 text-xs text-foreground hover:bg-accent"
				>
					{chip.label}
					<X className="size-3.5 text-muted-foreground" aria-hidden />
					<span className="sr-only">Remove filter</span>
				</button>
			))}
			{chips.length > 1 ? (
				<Button
					type="button"
					variant="ghost"
					size="sm"
					className="h-7 px-2 text-xs"
					onClick={onClearAll}
				>
					Clear all
				</Button>
			) : null}
		</div>
	)
}

export { DirectoryFilterChips }
