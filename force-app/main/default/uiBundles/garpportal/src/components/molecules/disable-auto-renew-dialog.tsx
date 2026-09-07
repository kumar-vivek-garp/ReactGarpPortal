import { Button } from "@/components/atoms/button"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from "@/components/atoms/dialog"
import { useTurnOffMembershipAutoRenew } from "@/hooks/use-membership-auto-renew"

type DisableAutoRenewDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
}

/**
 * The confirm step in front of switching auto-renew off.
 *
 * GarpAppv1 asks the same question inline inside the Membership card; here it
 * is a dialog, but the copy and the two answers are its. Switching off stops
 * a recurring payment, so it asks first — and on a refusal it stays open with
 * the toast from the shared MutationCache, so the member can retry or keep
 * auto-renew rather than be left wondering which happened.
 */
function DisableAutoRenewDialog({ open, onOpenChange }: DisableAutoRenewDialogProps) {
	const mutation = useTurnOffMembershipAutoRenew()

	const confirm = async () => {
		try {
			await mutation.mutateAsync()
			onOpenChange(false)
		} catch {
			// Toast comes from the shared MutationCache; keep the dialog open.
		}
	}

	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent className="sm:max-w-md">
				<DialogHeader>
					<DialogTitle>Turn off auto-renew?</DialogTitle>
					<DialogDescription>
						Switching auto-renew off stops your recurring payment. Your membership
						stays active until it expires, and you can renew manually after that.
					</DialogDescription>
				</DialogHeader>
				<DialogFooter className="sm:justify-end">
					<Button
						type="button"
						variant="outline"
						onClick={() => onOpenChange(false)}
						disabled={mutation.isPending}
					>
						Keep auto-renew
					</Button>
					<Button
						type="button"
						onClick={() => void confirm()}
						disabled={mutation.isPending}
					>
						{mutation.isPending ? "Turning off…" : "Yes, turn it off"}
					</Button>
				</DialogFooter>
			</DialogContent>
		</Dialog>
	)
}

export { DisableAutoRenewDialog }
