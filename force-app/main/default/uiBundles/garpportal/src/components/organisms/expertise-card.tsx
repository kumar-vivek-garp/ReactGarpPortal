import { useMemo, useState } from "react"
import { animated, useTrail } from "@react-spring/web"
import { ChevronDownIcon, X } from "lucide-react"

import type { PicklistOption } from "@/api/account/types"
import {
	EXPERTISE_FIELDS,
	type ExpertiseField,
	type ExpertiseValues,
} from "@/api/expertise"
import { Badge } from "@/components/atoms/badge"
import {
	DropdownMenu,
	DropdownMenuCheckboxItem,
	DropdownMenuContent,
	DropdownMenuTrigger,
} from "@/components/atoms/dropdown-menu"
import { Label } from "@/components/atoms/label"
import { Skeleton } from "@/components/atoms/skeleton"
import { AccountSectionCard } from "@/components/molecules/account-section-card"
import { useExpertise, useSaveExpertise } from "@/hooks/use-expertise"
import { useSaveState } from "@/hooks/use-save-state"
import { cn } from "@/lib/utils"

/** Same cascade as `StaggerReveal`, so chips feel of a piece with the cards. */
const CHIP_TRAIL_SPRING = { mass: 0.8, tension: 340, friction: 26 }

const FIELD_LABELS: Record<ExpertiseField, string> = {
	Self_Identification_Topic_Tags__c: "Area of Expertise",
	Publishing_Experience__c: "Publishing Experience",
	Teaching_Experience__c: "Teaching Experience",
	Expert_Participation__c: "Expert Participation",
}

const FIELD_PLACEHOLDERS: Record<ExpertiseField, string> = {
	Self_Identification_Topic_Tags__c: "Select Area of Expertise",
	Publishing_Experience__c: "Select Publishing Experience",
	Teaching_Experience__c: "Select Teaching Experience",
	Expert_Participation__c: "Select Expert Participation",
}

function decodeLabel(value: string): string {
	return value.replace(/&amp;/g, "&")
}

function splitValues(raw: string | null | undefined): string[] {
	if (!raw?.trim()) return []
	return raw
		.split(";")
		.map((part) => decodeLabel(part.trim()))
		.filter(Boolean)
}

function joinValues(chosen: string[]): string {
	return chosen.join(";")
}

function orderedChosen(
	options: PicklistOption[],
	selected: Set<string>,
): string[] {
	const known = options
		.map((option) => decodeLabel(option.value))
		.filter((value) => selected.has(value))
	const extras = [...selected].filter((value) => !known.includes(value))
	return [...known, ...extras]
}

function displayLabel(
	options: PicklistOption[],
	value: string,
): string {
	const match = options.find((option) => decodeLabel(option.value) === value)
	return decodeLabel(match?.label ?? value)
}

function toPayload(draft: Record<ExpertiseField, string[]>): ExpertiseValues {
	const values: ExpertiseValues = {}
	for (const field of EXPERTISE_FIELDS) {
		values[field] = joinValues(draft[field])
	}
	return values
}

function payloadsEqual(a: ExpertiseValues, b: ExpertiseValues): boolean {
	return EXPERTISE_FIELDS.every((field) => (a[field] ?? "") === (b[field] ?? ""))
}

function ExpertiseMultiSelect({
	id,
	label,
	placeholder,
	options,
	chosen,
	disabled,
	onChosenChange,
	onCommit,
	onClose,
}: {
	id: string
	label: string
	placeholder: string
	options: PicklistOption[]
	chosen: string[]
	disabled: boolean
	onChosenChange: (next: string[]) => void
	/** Set the draft AND save it in one step — used by the chip remove buttons. */
	onCommit: (next: string[]) => void
	onClose: () => void
}) {
	const selected = useMemo(() => new Set(chosen), [chosen])
	const summary =
		chosen.length === 0
			? ""
			: `${chosen.length} selected`

	const chipTrails = useTrail(chosen.length, {
		from: { opacity: 0, transform: "scale(0.9)" },
		to: { opacity: 1, transform: "scale(1)" },
		config: CHIP_TRAIL_SPRING,
	})

	const remove = (value: string) => {
		const nextSet = new Set(selected)
		nextSet.delete(value)
		// A chip removal never fires the dropdown's close event, so it commits
		// directly rather than relying on `onClose` — which would still be
		// holding the pre-removal draft in its closure.
		onCommit(orderedChosen(options, nextSet))
	}

	return (
		<div className="flex flex-col gap-1.5">
			<Label htmlFor={id} className="font-heading font-semibold">
				{label}
			</Label>
			<DropdownMenu
				modal={false}
				onOpenChange={(open) => {
					if (!open) onClose()
				}}
			>
				<DropdownMenuTrigger asChild>
					<button
						id={id}
						type="button"
						disabled={disabled}
						className={cn(
							"flex h-9 w-full items-center justify-between gap-2 rounded-xl border border-input bg-background px-3 py-2 text-left text-sm outline-none",
							"focus-visible:border-primary disabled:cursor-not-allowed disabled:opacity-50",
							summary ? "text-foreground" : "text-muted-foreground",
						)}
					>
						<span className="min-w-0 flex-1 truncate">
							{summary || placeholder}
						</span>
						<ChevronDownIcon className="size-4 shrink-0 opacity-50" aria-hidden />
					</button>
				</DropdownMenuTrigger>
				<DropdownMenuContent
					align="start"
					className="max-h-72 w-(--radix-dropdown-menu-trigger-width)"
				>
					{options.length === 0 ? (
						<p className="px-2 py-1.5 text-sm text-muted-foreground">
							No options available.
						</p>
					) : (
						options.map((option) => {
							const value = decodeLabel(option.value)
							const checked = selected.has(value)
							return (
								<DropdownMenuCheckboxItem
									key={option.value}
									checked={checked}
									onCheckedChange={(next) => {
										const nextSet = new Set(selected)
										if (next) nextSet.add(value)
										else nextSet.delete(value)
										onChosenChange(orderedChosen(options, nextSet))
									}}
									onSelect={(event) => event.preventDefault()}
								>
									{decodeLabel(option.label)}
								</DropdownMenuCheckboxItem>
							)
						})
					)}
				</DropdownMenuContent>
			</DropdownMenu>

			{chosen.length > 0 ? (
				<div className="flex flex-wrap gap-1.5 pt-0.5">
					{chipTrails.map((style, index) => {
						const value = chosen[index]
						return (
							<animated.span key={value} style={style} className="inline-flex">
								<Badge
									variant="outline"
									className="gap-1 border-primary/40 bg-primary/5 py-1 pr-1 pl-2.5 font-medium text-primary"
								>
									<span className="max-w-50 truncate">
										{displayLabel(options, value)}
									</span>
									<button
										type="button"
										disabled={disabled}
										onClick={() => remove(value)}
										aria-label={`Remove ${displayLabel(options, value)}`}
										className="inline-flex size-4 items-center justify-center rounded-full hover:bg-primary/15 disabled:pointer-events-none"
									>
										<X className="size-3" aria-hidden />
									</button>
								</Badge>
							</animated.span>
						)
					})}
				</div>
			) : null}
		</div>
	)
}

function ExpertiseCard() {
	const query = useExpertise(true)
	const saveMutation = useSaveExpertise()
	const saveState = useSaveState(saveMutation)
	const data = query.data
	const [draft, setDraft] = useState<Record<ExpertiseField, string[]> | null>(
		null,
	)

	const serverDraft = useMemo(() => {
		if (!data) return null
		const next = {} as Record<ExpertiseField, string[]>
		for (const field of EXPERTISE_FIELDS) {
			next[field] = splitValues(data.values[field])
		}
		return next
	}, [data])

	const shown = draft ?? serverDraft
	const busy = saveMutation.isPending
	const serverPayload = useMemo(() => {
		if (!serverDraft) return null
		return toPayload(serverDraft)
	}, [serverDraft])

	const save = (candidate: Record<ExpertiseField, string[]>) => {
		if (!serverPayload || busy) return
		const next = toPayload(candidate)
		if (payloadsEqual(next, serverPayload)) return
		saveMutation.mutate(next, {
			onSuccess: () => setDraft(null),
		})
	}

	/** Dropdown close — save whatever the draft accumulated while it was open. */
	const saveIfChanged = () => {
		if (!shown) return
		save(shown)
	}

	/** Chip removal — set the draft and save that exact state in one pass. */
	const commitField = (field: ExpertiseField, next: string[]) => {
		if (!shown) return
		const candidate = { ...shown, [field]: next }
		setDraft(candidate)
		save(candidate)
	}

	return (
		<AccountSectionCard section="expertise" saveState={saveState}>
			{query.isError ? (
				<p className="text-sm text-muted-foreground">
					We couldn&apos;t load your expertise. Please try again later.
				</p>
			) : query.isPending || !shown || !data ? (
				<div className="flex flex-col gap-3" aria-busy aria-label="Loading expertise">
					{[0, 1, 2, 3].map((key) => (
						<div key={key} className="flex flex-col gap-1.5">
							<Skeleton className="h-3.5 w-36" />
							<Skeleton className="h-9 w-full rounded-md" />
						</div>
					))}
				</div>
			) : (
				<div className="flex flex-col gap-3">
					{EXPERTISE_FIELDS.map((field) => (
						<ExpertiseMultiSelect
							key={field}
							id={`expertise-${field}`}
							label={FIELD_LABELS[field]}
							placeholder={FIELD_PLACEHOLDERS[field]}
							options={data.options[field] ?? []}
							chosen={shown[field]}
							disabled={busy}
							onChosenChange={(next) =>
								setDraft({ ...shown, [field]: next })
							}
							onCommit={(next) => commitField(field, next)}
							onClose={saveIfChanged}
						/>
					))}
				</div>
			)}
		</AccountSectionCard>
	)
}

export { ExpertiseCard }
