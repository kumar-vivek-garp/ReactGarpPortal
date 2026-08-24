import type { CvProgramType, WorkExperience } from "@/api/work-experience"
import { AccountEditDialog } from "@/components/molecules/account-edit-dialog"
import { CvExperienceForm } from "@/components/organisms/cv-experience-form"

type CvExperienceDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	programType: CvProgramType
	/** Null for Add; a saved row for Edit. */
	experience: WorkExperience | null
}

/** Add / edit one logged role. */
function CvExperienceDialog({
	open,
	onOpenChange,
	programType,
	experience,
}: CvExperienceDialogProps) {
	return (
		<AccountEditDialog
			title={experience ? "Edit experience" : "Add experience"}
			description={
				experience
					? "Update this role. GARP re-checks the months whenever it changes."
					: "Add a role you want counted towards your 24 months."
			}
			trigger={null}
			open={open}
			onOpenChange={onOpenChange}
		>
			{/*
			 * Remount per row so the form re-seeds cleanly — react-hook-form's
			 * `values` would otherwise carry the previously-opened role's fields.
			 */}
			<CvExperienceForm
				key={experience?.id ?? "new"}
				programType={programType}
				experience={experience}
				onSaved={() => onOpenChange(false)}
				onCancel={() => onOpenChange(false)}
			/>
		</AccountEditDialog>
	)
}

export { CvExperienceDialog }
