import { AccountEditDialog } from "@/components/molecules/account-edit-dialog"
import { OstaIdForm } from "@/components/organisms/osta-id-form"

type OstaIdDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
}

/** Government ID for an OSTA test centre. */
function OstaIdDialog({ open, onOpenChange }: OstaIdDialogProps) {
	return (
		<AccountEditDialog
			title="Identity details"
			description="OSTA test centres require government ID before your exam can be scheduled."
			trigger={null}
			open={open}
			onOpenChange={onOpenChange}
		>
			<OstaIdForm
				onSaved={() => onOpenChange(false)}
				onCancel={() => onOpenChange(false)}
			/>
		</AccountEditDialog>
	)
}

export { OstaIdDialog }
