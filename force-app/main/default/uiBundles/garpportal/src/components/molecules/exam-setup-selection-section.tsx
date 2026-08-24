import type { ExamAdmin, ExamSetupSelectionInput } from "@/api/exam-setup"
import { Alert, AlertDescription } from "@/components/atoms/alert"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { ExamSetupField } from "@/components/molecules/exam-setup-field"
import { EXAM_SETUP_SAME_DAY_WARNING } from "@/config/exam-setup"
import { isSameAdministration, sitesFor } from "@/lib/exam-setup-presentation"
import { cn } from "@/lib/utils"

type PartProps = {
	part: 1 | 2
	label: string
	admins: ExamAdmin[]
	selectedAdminId: string | null
	selectedSiteId: string | null
	/** False renders the administration select read-only — the site may still move. */
	canChangeAdmin: boolean
	onAdminChange: (adminId: string) => void
	onSiteChange: (siteId: string) => void
}

/**
 * One exam part's two selects.
 *
 * Changing the administration clears the site: the sites hang off the
 * administration, so keeping the old id would leave the control showing a
 * venue that is not on offer under the new date.
 */
function ExamPartSelect({
	part,
	label,
	admins,
	selectedAdminId,
	selectedSiteId,
	canChangeAdmin,
	onAdminChange,
	onSiteChange,
}: PartProps) {
	const sites = sitesFor(admins, selectedAdminId)
	const adminId = `exam-setup-admin-${part}`
	const siteId = `exam-setup-site-${part}`

	return (
		<fieldset className="space-y-4 rounded-xl border border-border p-4">
			<legend className="px-1 text-sm font-semibold text-foreground">
				{label}
			</legend>

			<ExamSetupField
				id={adminId}
				label="Exam date"
				required
				hint={
					canChangeAdmin
						? undefined
						: "Your exam date is fixed for this sitting."
				}
			>
				{/* `?? ""`, never undefined — see the note in exam-setup-id-section. */}
				<Select
					value={selectedAdminId ?? ""}
					onValueChange={onAdminChange}
					disabled={!canChangeAdmin}
				>
					<SelectTrigger id={adminId} className="w-full">
						<SelectValue placeholder="Select an exam date" />
					</SelectTrigger>
					<SelectContent>
						{admins.map((admin) =>
							admin.id ? (
								<SelectItem key={admin.id} value={admin.id}>
									{admin.name ?? admin.id}
								</SelectItem>
							) : null,
						)}
					</SelectContent>
				</Select>
			</ExamSetupField>

			<ExamSetupField
				id={siteId}
				label="Exam site"
				required
				hint={
					sites.length === 0
						? "No sites are open for this exam date yet."
						: undefined
				}
			>
				<Select
					value={selectedSiteId ?? ""}
					onValueChange={onSiteChange}
					disabled={sites.length === 0}
				>
					<SelectTrigger id={siteId} className="w-full">
						<SelectValue placeholder="Select an exam site" />
					</SelectTrigger>
					<SelectContent>
						{sites.map((site) =>
							site.id ? (
								<SelectItem key={site.id} value={site.id}>
									{site.name ?? site.id}
								</SelectItem>
							) : null,
						)}
					</SelectContent>
				</Select>
			</ExamSetupField>
		</fieldset>
	)
}

type ExamSetupSelectionSectionProps = {
	part1Admins: ExamAdmin[]
	part2Admins: ExamAdmin[]
	selection: ExamSetupSelectionInput
	canChangeAdminPart1: boolean
	canChangeAdminPart2: boolean
	onSelectionChange: (next: ExamSetupSelectionInput) => void
	className?: string
}

/**
 * "When and where will you sit?" — one column per exam part.
 *
 * A programme with no Part II simply has no second list, so the second column
 * is absent rather than disabled. FRM is the only two-part programme.
 */
function ExamSetupSelectionSection({
	part1Admins,
	part2Admins,
	selection,
	canChangeAdminPart1,
	canChangeAdminPart2,
	onSelectionChange,
	className,
}: ExamSetupSelectionSectionProps) {
	const hasPart2 = part2Admins.length > 0

	return (
		<div className={cn("space-y-4", className)}>
			{isSameAdministration(selection) ? (
				<Alert role="status">
					<AlertDescription>{EXAM_SETUP_SAME_DAY_WARNING}</AlertDescription>
				</Alert>
			) : null}

			<div className={cn("grid gap-4", hasPart2 && "sm:grid-cols-2")}>
				{part1Admins.length > 0 ? (
					<ExamPartSelect
						part={1}
						label={hasPart2 ? "Part I" : "Your exam"}
						admins={part1Admins}
						selectedAdminId={selection.selectedAdminPart1}
						selectedSiteId={selection.selectedSitePart1}
						canChangeAdmin={canChangeAdminPart1}
						onAdminChange={(adminId) =>
							onSelectionChange({
								...selection,
								selectedAdminPart1: adminId,
								selectedSitePart1: null,
							})
						}
						onSiteChange={(siteId) =>
							onSelectionChange({ ...selection, selectedSitePart1: siteId })
						}
					/>
				) : null}

				{hasPart2 ? (
					<ExamPartSelect
						part={2}
						label="Part II"
						admins={part2Admins}
						selectedAdminId={selection.selectedAdminPart2}
						selectedSiteId={selection.selectedSitePart2}
						canChangeAdmin={canChangeAdminPart2}
						onAdminChange={(adminId) =>
							onSelectionChange({
								...selection,
								selectedAdminPart2: adminId,
								selectedSitePart2: null,
							})
						}
						onSiteChange={(siteId) =>
							onSelectionChange({ ...selection, selectedSitePart2: siteId })
						}
					/>
				) : null}
			</div>
		</div>
	)
}

export { ExamSetupSelectionSection }
