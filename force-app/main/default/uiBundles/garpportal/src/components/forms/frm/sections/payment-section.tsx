import { Banknote, CreditCard, Landmark } from "lucide-react"
import { Controller, type Control, type FieldErrors } from "react-hook-form"

import type { RegistrationCountry } from "@/api/registration/exam-types"
import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import { FieldError } from "@/components/molecules/form-field"
import type { FrmFormValues } from "@/components/forms/frm/frm-form-values"
import { OFFLINE_PAYMENT_COPY, PAYMENT_TILES } from "@/config/registration"
import { isPaymentAllowed } from "@/lib/registration-presentation"
import { cn } from "@/lib/utils"

const TILE_ICON = {
	Stripe: CreditCard,
	"Wire Transfer": Banknote,
	ACH: Landmark,
} as const

type PaymentSectionProps = {
	control: Control<FrmFormValues>
	errors: FieldErrors<FrmFormValues>
	/** The chosen billing country, which decides what is on offer. */
	country: RegistrationCountry | null
	/** Org-level Stripe switch from the load payload. */
	useStripe: boolean
	paymentType: string
	/** Card orders with a complimentary membership can opt into auto-renew. */
	showAutorenew: boolean
	disabled?: boolean
}

/**
 * How the candidate wants to pay.
 *
 * The options are the country's, not ours — a country may permit card, wire,
 * ACH or any combination, and the org can switch card off entirely. A
 * forbidden method is shown disabled rather than hidden, so the absence is
 * explained rather than mysterious.
 *
 * Auto-renew lives here rather than in its own card because it is a property
 * of paying by card: there is no saved payment method to renew against
 * otherwise.
 */
function PaymentSection({
	control,
	errors,
	country,
	useStripe,
	paymentType,
	showAutorenew,
	disabled,
}: PaymentSectionProps) {
	const isOffline = paymentType === "Wire Transfer" || paymentType === "ACH"

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<CreditCard className="size-5 text-muted-foreground" aria-hidden />
					Payment
				</CardTitle>
			</CardHeader>
			<CardContent className="flex flex-col gap-4">
				<Controller
					control={control}
					name="paymentType"
					rules={{ required: "Please choose how you would like to pay." }}
					render={({ field }) => (
						<div
							className="grid grid-cols-1 gap-3 sm:grid-cols-3"
							role="radiogroup"
							aria-label="Payment type"
						>
							{PAYMENT_TILES.map((tile) => {
								const allowed = isPaymentAllowed(tile.value, country, useStripe)
								const selected = allowed && field.value === tile.value
								const Icon = TILE_ICON[tile.value]

								return (
									<button
										key={tile.value}
										type="button"
										role="radio"
										aria-checked={selected}
										disabled={disabled || !allowed}
										onClick={() => field.onChange(tile.value)}
										className={cn(
											"flex flex-col items-center gap-2 rounded-xl border p-4 text-body transition-colors",
											selected
												? "border-primary bg-primary/10 text-primary"
												: "border-border hover:bg-accent",
											!allowed && "cursor-not-allowed opacity-50 hover:bg-transparent",
										)}
									>
										<Icon className="size-5" aria-hidden />
										<span className="font-medium">{tile.label}</span>
										{!allowed ? (
											<span className="text-caption text-muted-foreground">
												Not available here
											</span>
										) : null}
									</button>
								)
							})}
						</div>
					)}
				/>
				<FieldError message={errors.paymentType?.message} />

				{isOffline ? (
					<div
						className="flex flex-col gap-2 rounded-xl bg-light-yellow p-4 text-caption text-light-yellow-foreground"
						role="note"
					>
						<p>{OFFLINE_PAYMENT_COPY.instructions}</p>
						<p className="font-bold">{OFFLINE_PAYMENT_COPY.feeNotice}</p>
					</div>
				) : null}

				{paymentType === "Stripe" ? (
					<p className="text-caption text-muted-foreground">
						{OFFLINE_PAYMENT_COPY.cardNotice}
					</p>
				) : null}

				{showAutorenew ? (
					<div className="flex items-start gap-3 border-t border-border pt-4">
						<Controller
							control={control}
							name="autoRenew"
							render={({ field }) => (
								<Checkbox
									id="autoRenew"
									checked={field.value}
									onCheckedChange={(next) => field.onChange(next === true)}
									disabled={disabled}
									className="mt-0.5"
								/>
							)}
						/>
						<Label
							htmlFor="autoRenew"
							className="text-body leading-5 font-normal"
						>
							{OFFLINE_PAYMENT_COPY.autoRenew}
						</Label>
					</div>
				) : null}
			</CardContent>
		</Card>
	)
}

export { PaymentSection }
