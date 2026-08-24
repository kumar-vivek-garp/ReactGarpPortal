import type { WorkExperience } from "@/api/work-experience"
import { Button } from "@/components/atoms/button"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from "@/components/atoms/dialog"
import { useDeleteExperience } from "@/hooks/use-cv"
import { buildCvRowPresentation } from "@/lib/work-experience-presentation"

type CvDeleteDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	experience: WorkExperience | null
}

/**
 * Confirm removal of one logged role.
 *
 * Named here rather than a bare "this experience": the legacy asked "Are you
 * sure you want to permanently delete this work experience?" with no way to
 * tell which row was about to go. Deleting also removes its attachments, which
 * the member is told before it happens.
 */
function CvDeleteDialog({
	open,
	onOpenChange,
	experience,
}: CvDeleteDialogProps) {
	const mutation = useDeleteExperience()
	const row = experience ? buildCvRowPresentation(experience) : null

	const confirm = async () => {
		if (!experience?.id) return
		try {
			await mutation.mutateAsync(experience.id)
			onOpenChange(false)
		} catch {
			// Toast comes from the shared MutationCache; keep the dialog open.
		}
	}

	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent className="sm:max-w-md">
				<DialogHeader>
					<DialogTitle>Remove this experience?</DialogTitle>
					<DialogDescription>
						{row
							? `${row.title} — ${row.period}. This also removes any documents attached to it, and cannot be undone.`
							: "This cannot be undone."}
					</DialogDescription>
				</DialogHeader>
				<DialogFooter className="sm:justify-end">
					<Button
						type="button"
						variant="outline"
						onClick={() => onOpenChange(false)}
						disabled={mutation.isPending}
					>
						Cancel
					</Button>
					<Button
						type="button"
						variant="destructive"
						onClick={() => void confirm()}
						disabled={mutation.isPending}
					>
						{mutation.isPending ? "Removing…" : "Remove"}
					</Button>
				</DialogFooter>
			</DialogContent>
		</Dialog>
	)
}

export { CvDeleteDialog }
