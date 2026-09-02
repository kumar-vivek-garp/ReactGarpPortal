import { Button } from "@/components/atoms/button"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from "@/components/atoms/dialog"
import { formatMoney } from "@/lib/account-format"

type ConfirmEventRegistrationDialogProps = {
	open: boolean
	eventTitle: string
	amountDue: number
	confirming: boolean
	onConfirm: () => void
	onCancel: () => void
}

/**
 * One more look at the money before an unretryable write — paid events only;
 * free registrations submit directly. The staged request is held by the form
 * until Confirm fires the mutation, and a failure closes the dialog so the
 * error reads against the form it has to be fixed in.
 */
function ConfirmEventRegistrationDialog({
	open,
	eventTitle,
	amountDue,
	confirming,
	onConfirm,
	onCancel,
}: ConfirmEventRegistrationDialogProps) {
	return (
		<Dialog open={open} onOpenChange={(next) => (next ? undefined : onCancel())}>
			<DialogContent>
				<DialogHeader>
					<DialogTitle>Confirm your registration</DialogTitle>
					<DialogDescription>
						You will be taken to our payment provider to complete it.
					</DialogDescription>
				</DialogHeader>

				<dl className="flex items-center justify-between gap-4 rounded-xl bg-muted px-4 py-3">
					<dt className="min-w-0 truncate text-sm text-foreground">
						{eventTitle}
					</dt>
					<dd className="text-base font-semibold tabular-nums">
						{formatMoney(amountDue, "USD")}
					</dd>
				</dl>

				<DialogFooter>
					<Button variant="outline" onClick={onCancel} disabled={confirming}>
						Back
					</Button>
					<Button onClick={onConfirm} disabled={confirming}>
						{confirming ? "Taking you to payment…" : "Confirm and Pay"}
					</Button>
				</DialogFooter>
			</DialogContent>
		</Dialog>
	)
}

export { ConfirmEventRegistrationDialog }
