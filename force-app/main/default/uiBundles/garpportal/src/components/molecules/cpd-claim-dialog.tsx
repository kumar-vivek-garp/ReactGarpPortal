import type { CpdClaim } from "@/api/cpd"
import { AccountEditDialog } from "@/components/molecules/account-edit-dialog"
import { CpdClaimForm } from "@/components/organisms/cpd-claim-form"

type CpdClaimDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	/** Null for Add Credits; a claim for Edit. */
	claim: CpdClaim | null
}

/**
 * Add / edit a CPD activity. Titled "Credit Details" for both, as the legacy
 * does — only the submit button differs (Submit vs Update).
 */
function CpdClaimDialog({ open, onOpenChange, claim }: CpdClaimDialogProps) {
	return (
		<AccountEditDialog
			title="Credit Details"
			description={
				claim
					? "Update this activity. It stays pending until GARP reviews it."
					: "Log an activity for your current CPD cycle. It stays pending until GARP reviews it."
			}
			trigger={null}
			open={open}
			onOpenChange={onOpenChange}
			/*
			 * Sized to its content instead of the shell's fixed 52rem. The form is
			 * short — five controls unless the activity type asks for extras — and
			 * at a fixed height the footer sat a screen below the last field with
			 * nothing in between. `min-h` keeps the loading skeleton and the shortest
			 * form the same size, so nothing jumps as it hydrates, and `max-h` caps
			 * it at the viewport, at which point the form body scrolls (it already
			 * owns `overflow-y-auto` between the pinned header and footer).
			 */
			contentClassName="h-auto max-h-[min(90vh,44rem)] min-h-[26rem]"
		>
			{/*
			 * Remount per claim so the form re-seeds cleanly — react-hook-form's
			 * `values` would otherwise carry a previous row's dynamic fields.
			 */}
			<CpdClaimForm
				key={claim?.claimId ?? "new"}
				claim={claim}
				onSaved={() => onOpenChange(false)}
				onCancel={() => onOpenChange(false)}
			/>
		</AccountEditDialog>
	)
}

export { CpdClaimDialog }
