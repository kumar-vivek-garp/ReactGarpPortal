import type { AccountView, ChapterOption } from "@/api/account/types"
import { Label } from "@/components/atoms/label"
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
			<Select
				value={value ?? NONE_VALUE}
				onValueChange={(next) => onChange(next === NONE_VALUE ? null : next)}
				disabled={disabled}
			>
				<SelectTrigger id={id} className="w-full">
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
		</div>
	)
}

function PreferredChaptersCard({
	account,
	handle,
}: PreferredChaptersCardProps) {
	const { identity, chapters } = account
	const optionsQuery = useAccountOptions(true)
	const saveMutation = useSavePreferredChapters(identity.contactId)
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
