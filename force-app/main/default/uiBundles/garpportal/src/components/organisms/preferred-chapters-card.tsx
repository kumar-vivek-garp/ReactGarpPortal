import { X } from "lucide-react"

import type { AccountView, ChapterOption } from "@/api/account/types"
import { Label } from "@/components/atoms/label"
import { cn } from "@/lib/utils"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { Skeleton } from "@/components/atoms/skeleton"
import {
	AccountSectionCard,
	type AccountCardSlotProps,
} from "@/components/molecules/account-section-card"
import { CardCta } from "@/components/molecules/card-cta"
import { useAccountOptions } from "@/hooks/use-account-options"
import { useSaveState } from "@/hooks/use-save-state"
import { useSavePreferredChapters } from "@/hooks/use-save-account-profile"

const NONE_VALUE = "__none__"

type PreferredChaptersCardProps = AccountCardSlotProps & {
	account: AccountView
}

function chapterLabel(chapter: ChapterOption): string {
	return chapter.region ? `${chapter.name} (${chapter.region})` : chapter.name
}

function selectOptions(
	chapters: ChapterOption[],
	current: string | null,
): Array<{ value: string; label: string }> {
	const byName = new Map<string, string>()
	for (const chapter of chapters) {
		if (!chapter.name.trim()) continue
		byName.set(chapter.name, chapterLabel(chapter))
	}
	if (current && !byName.has(current)) {
		byName.set(current, current)
	}
	return [...byName.entries()].map(([value, label]) => ({ value, label }))
}

function ChapterSelect({
	id,
	label,
	value,
	options,
	disabled,
	onChange,
}: {
	id: string
	label: string
	value: string | null
	options: Array<{ value: string; label: string }>
	disabled: boolean
	onChange: (next: string | null) => void
}) {
	return (
		<div className="flex flex-col gap-1.5">
			<Label htmlFor={id} className="font-heading font-semibold">
				{label}
			</Label>
			{/*
			 * The clear button is a SIBLING of the trigger laid over it, never a
			 * child: the trigger is itself a `<button>`, and nesting one inside
			 * another is invalid markup that assistive tech reads unpredictably.
			 * It therefore needs to out-rank the trigger's own `z-10`.
			 */}
			<div className="relative">
				<Select
					value={value ?? NONE_VALUE}
					onValueChange={(next) => onChange(next === NONE_VALUE ? null : next)}
					disabled={disabled}
				>
					<SelectTrigger
						id={id}
						// The margin reserves the clear button's slot out of the
						// VALUE's width rather than the trigger's padding — padding
						// would push the chevron left as well, landing it on the
						// wrong side of the button.
						className={cn(
							"w-full",
							value && "*:data-[slot=select-value]:me-6",
						)}
					>
						<SelectValue placeholder="Select Chapter" />
					</SelectTrigger>
					<SelectContent>
						<SelectItem value={NONE_VALUE}>Select Chapter</SelectItem>
						{options.map((option) => (
							<SelectItem key={option.value} value={option.value}>
								{option.label}
							</SelectItem>
						))}
					</SelectContent>
				</Select>

				{/*
				 * Only once there is something to clear. Named for the field it
				 * clears, because the page carries two of these and "Clear" alone
				 * would announce both identically.
				 */}
				{value ? (
					<button
						type="button"
						onClick={() => onChange(null)}
						disabled={disabled}
						aria-label={`Clear ${label}`}
						className={cn(
							"absolute inset-y-0 end-7 z-20 my-auto grid size-6 cursor-pointer place-items-center rounded-full",
							"text-muted-foreground hover:bg-muted hover:text-foreground",
							"focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
							"disabled:cursor-not-allowed disabled:opacity-50",
						)}
					>
						<X className="size-3.5" aria-hidden />
					</button>
				) : null}
			</div>
		</div>
	)
}

function PreferredChaptersCard({
	account,
	handle,
}: PreferredChaptersCardProps) {
	const { chapters } = account
	const optionsQuery = useAccountOptions(true)
	const saveMutation = useSavePreferredChapters()
	const chapterOptions = optionsQuery.data?.chapters ?? []
	const busy = saveMutation.isPending || optionsQuery.isPending
	const saveState = useSaveState(saveMutation)

	const save = (primary: string | null, secondary: string | null) => {
		saveMutation.mutate({
			KPI_Primary_Chapter_Name__c: primary,
			KPI_Secondary_Chapter_Name__c: secondary,
		})
	}

	return (
		<AccountSectionCard
			section="chapters"
			saveState={saveState}
			handle={handle}
		>
			{optionsQuery.isPending ? (
				<div
					className="flex flex-col gap-3"
					aria-busy
					aria-label="Loading chapters"
				>
					<Skeleton className="h-3.5 w-28" />
					<Skeleton className="h-9 w-full rounded-md" />
					<Skeleton className="h-3.5 w-32" />
					<Skeleton className="h-9 w-full rounded-md" />
				</div>
			) : (
				<div className="flex flex-col gap-3">
					<ChapterSelect
						id="primary-chapter"
						label="Primary Chapter"
						value={chapters.primary}
						options={selectOptions(chapterOptions, chapters.primary)}
						disabled={busy}
						onChange={(primary) => save(primary, chapters.secondary)}
					/>
					<ChapterSelect
						id="secondary-chapter"
						label="Secondary Chapter"
						value={chapters.secondary}
						options={selectOptions(chapterOptions, chapters.secondary)}
						disabled={busy}
						onChange={(secondary) => save(chapters.primary, secondary)}
					/>
				</div>
			)}

			<div className="mt-auto pt-1">
				<CardCta
					label="View Upcoming Meetings"
					url="/events?type=chapter"
					isExternal={false}
				/>
			</div>
		</AccountSectionCard>
	)
}

export { PreferredChaptersCard }
