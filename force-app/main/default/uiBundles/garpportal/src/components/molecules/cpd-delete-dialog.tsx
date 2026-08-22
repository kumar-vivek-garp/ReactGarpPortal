import type { CpdClaim } from "@/api/cpd"
import { Button } from "@/components/atoms/button"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from "@/components/atoms/dialog"
import { useDeleteCpdClaim } from "@/hooks/use-save-cpd-claim"
import { buildClaimRowPresentation } from "@/lib/cpd-presentation"

type CpdDeleteDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	claim: CpdClaim | null
}

/** Confirm removal of a pending activity. */
function CpdDeleteDialog({ open, onOpenChange, claim }: CpdDeleteDialogProps) {
	const mutation = useDeleteCpdClaim()
	const title = claim ? buildClaimRowPresentation(claim).title : ""

	const confirm = async () => {
		if (!claim?.claimId) return
		try {
			await mutation.mutateAsync(claim.claimId)
			onOpenChange(false)
		} catch {
			// Toast comes from the shared MutationCache; keep the dialog open.
		}
	}

	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent className="sm:max-w-md">
				<DialogHeader>
					<DialogTitle>Delete this submission?</DialogTitle>
					<DialogDescription>
						Are you sure you&apos;d like to delete {title}? This cannot be undone.
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
						{mutation.isPending ? "Deleting…" : "Delete"}
					</Button>
				</DialogFooter>
			</DialogContent>
		</Dialog>
	)
}

export { CpdDeleteDialog }
