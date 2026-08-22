import { SlidersHorizontal } from "lucide-react"

import { Button } from "@/components/atoms/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import {
	CPD_FACETS,
	CPD_FACET_SCOPE_NOTE,
	CPD_SORT_OPTIONS,
	type CpdFacetKey,
	type CpdSortOption,
} from "@/config/cpd"

export type CpdFacetValues = Record<CpdFacetKey, string[]>

type CpdActivityFiltersProps = {
	options: Record<CpdFacetKey, string[]>
	selected: CpdFacetValues
	sort: CpdSortOption
	onToggle: (facet: CpdFacetKey, value: string, checked: boolean) => void
	onSortChange: (sort: CpdSortOption) => void
	onClear: () => void
}

/**
 * Sort + facets for Browse Credit Opportunities.
 *
 * Both apply immediately rather than behind the legacy's "Apply" button — the
 * result set is server-paged and the URL carries the state, so a change is one
 * navigation and there is nothing to batch. The legacy also shipped no way to
 * clear a filter at all; "Clear all" is new.
 */
function CpdActivityFilters({
	options,
	selected,
	sort,
	onToggle,
	onSortChange,
	onClear,
}: CpdActivityFiltersProps) {
	const hasSelection = CPD_FACETS.some((facet) => selected[facet.key].length > 0)

	return (
		<div className="space-y-4">
			<Card className="gap-0 py-0 shadow-none">
				<CardHeader className="px-4 pt-4 pb-2">
					<CardTitle className="text-sm font-semibold text-foreground">
						Sort by
					</CardTitle>
				</CardHeader>
				<CardContent className="px-4 pb-4">
					<Select
						value={sort}
						onValueChange={(value) => onSortChange(value as CpdSortOption)}
					>
						<SelectTrigger className="w-full" aria-label="Sort activities">
							<SelectValue />
						</SelectTrigger>
						<SelectContent>
							{CPD_SORT_OPTIONS.map((option) => (
								<SelectItem key={option} value={option}>
									{option}
								</SelectItem>
							))}
						</SelectContent>
					</Select>
				</CardContent>
			</Card>

			<Card className="gap-0 py-0 shadow-none">
				<CardHeader className="flex-row items-center justify-between gap-2 px-4 pt-4 pb-2">
					<CardTitle className="flex items-center gap-2 text-sm font-semibold text-foreground">
						<SlidersHorizontal className="size-4 text-primary" aria-hidden />
						Filter
					</CardTitle>
					{hasSelection ? (
						<Button
							type="button"
							variant="link"
							size="sm"
							className="h-auto px-0 text-xs"
							onClick={onClear}
						>
							Clear all
						</Button>
					) : null}
				</CardHeader>
				<CardContent className="space-y-4 px-4 pb-4">
					{CPD_FACETS.map((facet) => {
						const values = options[facet.key]
						if (values.length === 0) return null
						return (
							<fieldset key={facet.key} className="space-y-2">
								<legend className="text-xs font-semibold tracking-wider text-muted-foreground uppercase">
									{facet.label}
								</legend>
								{values.map((value) => {
									const id = `cpd-facet-${facet.key}-${value}`
									return (
										<div key={value} className="flex items-start gap-2">
											<Checkbox
												id={id}
												checked={selected[facet.key].includes(value)}
												onCheckedChange={(next) =>
													onToggle(facet.key, value, next === true)
												}
												className="mt-0.5"
											/>
											<Label htmlFor={id} className="text-sm font-normal">
												{value}
											</Label>
										</div>
									)
								})}
							</fieldset>
						)
					})}
					<p className="text-xs text-muted-foreground">{CPD_FACET_SCOPE_NOTE}</p>
				</CardContent>
			</Card>
		</div>
	)
}

export { CpdActivityFilters }
