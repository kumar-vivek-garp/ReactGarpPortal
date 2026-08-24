import { useState } from "react"
import { SlidersHorizontal } from "lucide-react"

import { Button } from "@/components/atoms/button"
import { Checkbox } from "@/components/atoms/checkbox"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from "@/components/atoms/dialog"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import {
	DIRECTORY_CERTIFICATIONS,
	DIRECTORY_FILTERS,
	type DirectoryFilterKey,
} from "@/config/directory"
import { cn } from "@/lib/utils"

export type DirectoryFilterState = {
	company: string
	certifications: string[]
	values: Record<DirectoryFilterKey, string[]>
}

export const EMPTY_DIRECTORY_FILTERS: DirectoryFilterState = {
	company: "",
	certifications: [],
	values: {
		industries: [],
		jobFunctions: [],
		riskSpecialties: [],
		corporateTitles: [],
	},
}

type PicklistOption = { label: string; value: string }

type DirectoryFiltersDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	/** The filters currently in effect. */
	value: DirectoryFilterState
	onApply: (next: DirectoryFilterState) => void
	picklists: Record<string, PicklistOption[]> | undefined
}

function Group({
	legend,
	children,
	columns = 2,
}: {
	legend: string
	children: React.ReactNode
	columns?: number
}) {
	return (
		<fieldset className="space-y-2.5">
			<legend className="text-sm font-semibold text-foreground">
				{legend}
			</legend>
			<div
				className={cn(
					"grid gap-x-4 gap-y-2",
					columns === 2 ? "sm:grid-cols-2" : "grid-cols-2 sm:grid-cols-4",
				)}
			>
				{children}
			</div>
		</fieldset>
	)
}

function Tick({
	id,
	label,
	checked,
	onToggle,
}: {
	id: string
	label: string
	checked: boolean
	onToggle: () => void
}) {
	return (
		<div className="flex items-start gap-2">
			<Checkbox id={id} checked={checked} onCheckedChange={onToggle} />
			<Label htmlFor={id} className="text-sm font-normal leading-snug">
				{label}
			</Label>
		</div>
	)
}

/**
 * Advanced filters, in a dialog.
 *
 * Inline, these four picklists are close to eighty checkboxes — a wall that
 * pushed the results themselves below the fold, which is the opposite of what
 * a directory is for. In a dialog the results stay put and the filters are
 * something you open, set, and dismiss.
 *
 * Edits are held locally and only lifted on Apply, so closing without applying
 * genuinely discards them rather than half-committing a search.
 */
function DirectoryFiltersDialog({
	open,
	onOpenChange,
	value,
	onApply,
	picklists,
}: DirectoryFiltersDialogProps) {
	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent className="flex h-[min(85vh,44rem)] flex-col gap-0 overflow-hidden p-0 sm:max-w-2xl">
				{/*
				 * The draft lives inside the content, which Radix unmounts on close,
				 * so each open starts from the filters actually in effect. Syncing it
				 * in with an effect instead would cascade a render every time.
				 */}
				<FiltersForm
					initial={value}
					picklists={picklists}
					onCancel={() => onOpenChange(false)}
					onApply={(next) => {
						onApply(next)
						onOpenChange(false)
					}}
				/>
			</DialogContent>
		</Dialog>
	)
}

function FiltersForm({
	initial,
	picklists,
	onApply,
	onCancel,
}: {
	initial: DirectoryFilterState
	picklists: Record<string, PicklistOption[]> | undefined
	onApply: (next: DirectoryFilterState) => void
	onCancel: () => void
}) {
	const [draft, setDraft] = useState<DirectoryFilterState>(initial)

	const toggleCert = (code: string) =>
		setDraft((current) => ({
			...current,
			certifications: current.certifications.includes(code)
				? current.certifications.filter((entry) => entry !== code)
				: [...current.certifications, code],
		}))

	const toggleValue = (key: DirectoryFilterKey, option: string) =>
		setDraft((current) => ({
			...current,
			values: {
				...current.values,
				[key]: current.values[key].includes(option)
					? current.values[key].filter((entry) => entry !== option)
					: [...current.values[key], option],
			},
		}))

	return (
		<>
				<DialogHeader className="shrink-0 space-y-1.5 border-b border-border px-6 py-4 pr-12 text-left">
					<DialogTitle className="flex items-center gap-2">
						<SlidersHorizontal className="size-4" aria-hidden />
						Filters
					</DialogTitle>
					<DialogDescription>
						Narrow the directory by certification, role or organisation.
					</DialogDescription>
				</DialogHeader>

				<div className="min-h-0 flex-1 space-y-6 overflow-y-auto px-6 py-5">
					<div className="space-y-1.5">
						<Label htmlFor="directory-company" className="text-sm font-semibold">
							Company
						</Label>
						<Input
							id="directory-company"
							value={draft.company}
							placeholder="Any organisation"
							onChange={(event) =>
								setDraft((current) => ({
									...current,
									company: event.target.value,
								}))
							}
						/>
					</div>

					<Group legend="Certification" columns={4}>
						{DIRECTORY_CERTIFICATIONS.map((code) => (
							<Tick
								key={code}
								id={`cert-${code}`}
								label={code}
								checked={draft.certifications.includes(code)}
								onToggle={() => toggleCert(code)}
							/>
						))}
					</Group>

					{DIRECTORY_FILTERS.map((filter) => {
						const options = picklists?.[filter.picklist] ?? []
						if (options.length === 0) return null
						return (
							<Group key={filter.key} legend={filter.label}>
								{options.map((option) => (
									<Tick
										key={option.value}
										id={`${filter.key}-${option.value}`}
										label={option.label}
										checked={draft.values[filter.key].includes(option.value)}
										onToggle={() => toggleValue(filter.key, option.value)}
									/>
								))}
							</Group>
						)
					})}
				</div>

				<DialogFooter className="shrink-0 border-t border-border px-6 py-4 sm:justify-between">
					<Button
						type="button"
						variant="ghost"
						onClick={() => setDraft(EMPTY_DIRECTORY_FILTERS)}
					>
						Clear all
					</Button>
					<div className="flex gap-2">
						<Button
							type="button"
							variant="outline"
							onClick={onCancel}
						>
							Cancel
						</Button>
						<Button type="button" onClick={() => onApply(draft)}>
							Show results
						</Button>
					</div>
				</DialogFooter>
		</>
	)
}

export { DirectoryFiltersDialog }
