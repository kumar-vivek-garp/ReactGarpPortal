import type { CvView } from "@/api/work-experience"
import { AccountEditDialog } from "@/components/molecules/account-edit-dialog"
import { CvAddressForm } from "@/components/organisms/cv-address-form"

type CvAddressDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	/** Supplies `isOSTA` and the seeded Chinese address. */
	view: CvView | null
}

/** Where the certificate is posted. */
function CvAddressDialog({ open, onOpenChange, view }: CvAddressDialogProps) {
	return (
		<AccountEditDialog
			title="Delivery address"
			description="Where GARP posts your certificate once your CV is approved."
			trigger={null}
			open={open}
			onOpenChange={onOpenChange}
		>
			<CvAddressForm
				view={view}
				onSaved={() => onOpenChange(false)}
				onCancel={() => onOpenChange(false)}
			/>
		</AccountEditDialog>
	)
}

export { CvAddressDialog }
