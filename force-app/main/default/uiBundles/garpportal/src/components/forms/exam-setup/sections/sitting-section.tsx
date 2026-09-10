import { CalendarDays, RotateCcw } from "lucide-react"

import type { ExamAdmin } from "@/api/exam-setup"
import { Button } from "@/components/atoms/button"
import {
	Card,
	CardAction,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Label } from "@/components/atoms/label"
import { RadioGroup, RadioGroupItem } from "@/components/atoms/radio-group"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { FieldError, FormField } from "@/components/molecules/form-field"
import { StatusBadge } from "@/components/molecules/status-badge"
import { EXAM_SETUP_NO_SITES_YET, EXAM_SETUP_SECTIONS } from "@/config/exam-setup"
import { sitesFor, type ExamSetupSelection } from "@/lib/exam-setup-presentation"
import { cn } from "@/lib/utils"

function siteCaption(admin: ExamAdmin): string {
	const count = admin.examSites?.length ?? 0
	if (count === 0) return "Sites open later"
	return count === 1 ? "1 site open" : `${count} sites open`
}

type PartPickerProps = {
	part: 1 | 2
	/** `null` for a single-part programme, which needs no heading to tell apart. */
	heading: string | null
	/**
	 * True when this part shares the card with another. Its column is then
	 * half the width, so the tiles stack full-width rather than splitting a
	 * half into quarters and wrapping a date onto three lines.
	 */
	stacked: boolean
	admins: ExamAdmin[]
	selectedAdminId: string
	selectedSiteId: string
	error?: string | null
	onAdminChange: (adminId: string) => void
	onSiteChange: (siteId: string) => void
}

/**
 * One exam part: the administrations as tiles, the site as a list.
 *
 * Tiles for the administration because there are only ever a few and the one
 * the member sits in today deserves to be seen, not found in a dropdown. A list
 * for the site because there can be forty. Changing the administration clears
 * the site: the sites hang off it, and a site carried across would name a
 * venue that is not on offer under the new date.
 */
function PartPicker({
	part,
	heading,
	stacked,
	admins,
	selectedAdminId,
	selectedSiteId,
	error,
	onAdminChange,
	onSiteChange,
}: PartPickerProps) {
	const sites = sitesFor(admins, selectedAdminId)
	const groupId = `exam-setup-admin-${part}`
	const siteId = `exam-setup-site-${part}`
	// Both parts ask the same question, so on a two-part programme the part
	// has to be in the accessible name — a screen reader reading the form's
	// controls would otherwise meet two groups with identical names.
	const of = heading ? ` for ${heading} of` : " for"
	const adminLabel = `When do you plan to sit${of} the exam?`
	const siteLabel = heading
		? `Where do you plan to sit ${heading} of the exam?`
		: "Where do you plan to sit the exam?"

	return (
		<div className="flex flex-col gap-4 rounded-xl border border-border p-4">
			{heading ? (
				<h3 className="font-heading text-base tracking-wide text-heading">
					{heading}
				</h3>
			) : null}

			<div className="flex flex-col gap-2">
				<Label id={`${groupId}-label`} className="font-bold">
					{adminLabel}
					<span className="text-destructive" aria-hidden>
						{" "}
						*
					</span>
				</Label>
				<RadioGroup
					value={selectedAdminId}
					onValueChange={onAdminChange}
					aria-labelledby={`${groupId}-label`}
					aria-invalid={error ? true : undefined}
					className={cn("grid gap-2", !stacked && "sm:grid-cols-2")}
				>
					{admins.map((admin) => {
						if (!admin.id || !admin.name) return null
						const itemId = `${groupId}-${admin.id}`
						const selected = selectedAdminId === admin.id
						return (
							<Label
								key={admin.id}
								htmlFor={itemId}
								className={cn(
									"flex cursor-pointer items-start gap-3 rounded-lg border p-3 transition-colors",
									selected
										? "border-primary bg-primary/10"
										: "border-border hover:bg-accent",
								)}
							>
								<RadioGroupItem id={itemId} value={admin.id} className="mt-1" />
								<span className="flex min-w-0 flex-1 flex-col gap-1">
									<span className="flex flex-wrap items-center gap-2">
										<span className="font-medium">{admin.name}</span>
										{admin.isSelected ? (
											<StatusBadge tone="info" label="Current" />
										) : null}
									</span>
									<span className="text-caption font-normal text-muted-foreground">
										{siteCaption(admin)}
									</span>
								</span>
							</Label>
						)
					})}
				</RadioGroup>
				<FieldError message={error ?? undefined} />
			</div>

			{/* Hidden, not disabled: a disabled control invites the member to wait
			    for it to become usable on this screen, and it never will. */}
			{sites.length > 0 ? (
				<FormField id={siteId} label={siteLabel} required>
					<Select value={selectedSiteId} onValueChange={onSiteChange}>
						<SelectTrigger id={siteId} className="w-full">
							<SelectValue placeholder="Select a location" />
						</SelectTrigger>
						<SelectContent>
							{sites.map((site) =>
								site.id && site.name ? (
									<SelectItem key={site.id} value={site.id}>
										{site.name}
									</SelectItem>
								) : null,
							)}
						</SelectContent>
					</Select>
				</FormField>
			) : selectedAdminId ? (
				<p className="text-body text-muted-foreground">{EXAM_SETUP_NO_SITES_YET}</p>
			) : null}
		</div>
	)
}

type SittingSectionProps = {
	part1Admins: ExamAdmin[]
	part2Admins: ExamAdmin[]
	selection: ExamSetupSelection
	onSelectionChange: (next: ExamSetupSelection) => void
	/** The rule's message and the part it belongs under, or null. */
	error: { part: 1 | 2; message: string } | null
	hasChanges: boolean
	onReset: () => void
}

/** "Choose your sitting" — one part, or two side by side for FRM. */
function SittingSection({
	part1Admins,
	part2Admins,
	selection,
	onSelectionChange,
	error,
	hasChanges,
	onReset,
}: SittingSectionProps) {
	const twoPart = part2Admins.length > 0

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<CalendarDays className="size-5 text-muted-foreground" aria-hidden />
					{EXAM_SETUP_SECTIONS.sitting.title}
				</CardTitle>
				<p className="text-body text-muted-foreground">
					{EXAM_SETUP_SECTIONS.sitting.description}
				</p>
				{hasChanges ? (
					<CardAction>
						<Button type="button" variant="ghost" size="sm" onClick={onReset}>
							<RotateCcw aria-hidden />
							Reset
						</Button>
					</CardAction>
				) : null}
			</CardHeader>
			<CardContent className={cn("grid gap-4", twoPart && "lg:grid-cols-2")}>
				{part1Admins.length > 0 ? (
					<PartPicker
						part={1}
						heading={twoPart ? "Part I" : null}
						stacked={twoPart}
						admins={part1Admins}
						selectedAdminId={selection.a1}
						selectedSiteId={selection.s1}
						error={error?.part === 1 ? error.message : null}
						onAdminChange={(a1) => onSelectionChange({ ...selection, a1, s1: "" })}
						onSiteChange={(s1) => onSelectionChange({ ...selection, s1 })}
					/>
				) : null}
				{twoPart ? (
					<PartPicker
						part={2}
						heading="Part II"
						stacked
						admins={part2Admins}
						selectedAdminId={selection.a2}
						selectedSiteId={selection.s2}
						error={error?.part === 2 ? error.message : null}
						onAdminChange={(a2) => onSelectionChange({ ...selection, a2, s2: "" })}
						onSiteChange={(s2) => onSelectionChange({ ...selection, s2 })}
					/>
				) : null}
			</CardContent>
		</Card>
	)
}

export { SittingSection }
