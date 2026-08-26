import { ReceiptText } from "lucide-react"

import type { FeesResult } from "@/api/registration/exam-types"
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
import { showSubtotal, sortFeeLines } from "@/lib/registration-presentation"
import { cn } from "@/lib/utils"

type ConfirmRegistrationDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	fees: FeesResult | null
	/** What the confirm button says — mirrors the bar's own label. */
	submitLabel: string
	/** Human name for the chosen method, shown so it is not a surprise. */
	paymentType: string
	isPending: boolean
	onConfirm: () => void
}

function Row({
	label,
	amount,
	currency,
	included,
	total,
}: {
	label: string
	amount?: number | null
	currency: string
	included?: boolean
	total?: boolean
}) {
	return (
		<div
			className={cn(
				"flex items-baseline justify-between gap-4",
				total ? "text-base font-semibold" : "text-body",
			)}
		>
			<span className={total ? "text-foreground" : "text-muted-foreground"}>
				{label}
			</span>
			{included ? (
				<span className="shrink-0 text-success-green">Included</span>
			) : (
				<span
					className={cn("shrink-0 tabular-nums", total && "text-primary")}
				>
					{formatMoney(amount ?? 0, currency)}
				</span>
			)}
		</div>
	)
}

/**
 * Last look before the order is placed.
 *
 * The rail carries the same figures, but it is beside the form rather than in
 * front of it, and by the time someone reaches the button it has usually
 * scrolled out of their attention. Everything past this point writes records —
 * `register` creates the order and `payOrder` cannot be called twice — so the
 * total is repeated here, where it has to be read.
 *
 * Deliberately not a second validation step: the form is already valid by the
 * time this opens, because the submit button stays disabled until it is.
 */
function ConfirmRegistrationDialog({
	open,
	onOpenChange,
	fees,
	submitLabel,
	paymentType,
	isPending,
	onConfirm,
}: ConfirmRegistrationDialogProps) {
	const currency = fees?.currencyCode || "USD"
	const lines = sortFeeLines(fees?.lines ?? [])
	const withSubtotal = showSubtotal(lines, fees?.vatAmount, fees?.njSalesTax)

	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent className="sm:max-w-lg">
				<DialogHeader>
					<DialogTitle className="flex items-center gap-2">
						<ReceiptText className="size-5 text-muted-foreground" aria-hidden />
						Confirm your registration
					</DialogTitle>
					<DialogDescription>
						{paymentType === "Stripe"
							? "You will be taken to our payment provider to pay."
							: "An invoice will be raised for this order."}
					</DialogDescription>
				</DialogHeader>

				<div className="flex flex-col gap-2 rounded-xl border border-border p-4">
					{lines.map((line) => (
						<Row
							key={`${line.productCode ?? line.name}-${line.amount}`}
							label={line.name ?? ""}
							amount={line.amount}
							currency={currency}
							included={line.isComp === true}
						/>
					))}

					{withSubtotal ? (
						<Row
							label="Subtotal"
							amount={fees?.subTotal}
							currency={currency}
						/>
					) : null}
					{fees?.njSalesTax ? (
						<Row label="NJ sales tax" amount={fees.njSalesTax} currency={currency} />
					) : null}
					{fees?.vatAmount ? (
						<Row label="VAT" amount={fees.vatAmount} currency={currency} />
					) : null}

					<div className="mt-1 border-t border-border pt-2">
						<Row label="Total" amount={fees?.total} currency={currency} total />
					</div>
				</div>

				<DialogFooter className="sm:justify-end">
					<Button
						type="button"
						variant="outline"
						onClick={() => onOpenChange(false)}
						disabled={isPending}
					>
						Back
					</Button>
					<Button type="button" onClick={onConfirm} disabled={isPending}>
						{isPending ? "Submitting…" : submitLabel}
					</Button>
				</DialogFooter>
			</DialogContent>
		</Dialog>
	)
}

export { ConfirmRegistrationDialog }
