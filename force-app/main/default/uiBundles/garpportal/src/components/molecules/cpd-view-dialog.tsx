import type { CpdActivityFieldInfo, CpdClaim } from "@/api/cpd"
import { AccountEditDialog } from "@/components/molecules/account-edit-dialog"
import { useCpdActivityTypes } from "@/hooks/use-cpd-activity-types"
import {
	dynamicFieldsFor,
	findActivityType,
	formatAreaOfStudy,
	formatCredits,
} from "@/lib/cpd-presentation"
import { formatLongDate } from "@/lib/account-format"

type Row = { label: string; value: string | null }

function buildRows(
	claim: CpdClaim,
	activityType: CpdActivityFieldInfo | null,
): Row[] {
	const dynamic = dynamicFieldsFor(activityType).map((field) => ({
		label: field.label,
		value:
			field.name === "provider"
				? (claim.providerOther ?? claim.provider)
				: claim[field.name],
	}))

	return [
		{ label: "Activity Type", value: claim.activityTypeName },
		{ label: "Area of Study", value: formatAreaOfStudy(claim.areaOfStudy) },
		{
			label: "Date of Completion",
			value: formatLongDate(claim.dateOfCompletion),
		},
		{
			label: "Number of Credits",
			value: claim.credits == null ? null : formatCredits(claim.credits),
		},
		...dynamic,
		{ label: "Comment", value: claim.comments },
		{ label: "URL", value: claim.URL },
		/*
		 * The legacy fetched approvalComments on every claim and never rendered
		 * it, so a queried or rejected submission gave the member no reason.
		 * Showing it is the point of a read-only detail view.
		 */
		{ label: "Reviewer Comments", value: claim.approvalComments },
	].filter((row): row is Row => Boolean(row.value?.toString().trim()))
}

type CpdViewDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	claim: CpdClaim | null
}

/** Read-only detail for an approved activity. */
function CpdViewDialog({ open, onOpenChange, claim }: CpdViewDialogProps) {
	const { data: activityTypes } = useCpdActivityTypes(open)
	const activityType = findActivityType(activityTypes, claim?.activityType)
	const rows = claim ? buildRows(claim, activityType) : []

	return (
		<AccountEditDialog
			title="Credit Details"
			trigger={null}
			open={open}
			onOpenChange={onOpenChange}
			contentClassName="h-auto max-h-[min(90vh,52rem)] sm:max-w-xl"
		>
			<div className="min-h-0 flex-1 overflow-y-auto px-6 py-4">
				<dl className="grid gap-4 sm:grid-cols-2">
					{rows.map((row) => (
						<div key={row.label} className="flex flex-col gap-1">
							<dt className="text-xs font-semibold tracking-wider text-muted-foreground uppercase">
								{row.label}
							</dt>
							<dd className="text-sm break-words text-foreground">{row.value}</dd>
						</div>
					))}
				</dl>
			</div>
		</AccountEditDialog>
	)
}

export { CpdViewDialog }
