import { Minus, Plus, UserPlus } from "lucide-react"
import type { Control } from "react-hook-form"
import { Controller } from "react-hook-form"

import { Button } from "@/components/atoms/button"
import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import type { ExamFormValues } from "@/components/forms/exam-registration/exam-form-values"
import { MEMBERSHIP_OFFER_COPY } from "@/config/registration"
import { formatMoney } from "@/lib/account-format"

type MembershipOfferSectionProps = {
	control: Control<ExamFormValues>
	/** The offer as priced by the server — MEMI, or MEMC for a certified holder. */
	amount?: number
	disabled?: boolean
}

/**
 * The course membership upsell.
 *
 * Course kinds only, and only when the load payload carries an offer — the
 * exam programmes never do, and `GARP_ExamReg_LoadService` only builds one for
 * `kind: "course"`.
 *
 * Ticking this does two things server-side, which is why it is a cart control
 * rather than a checkbox: it adds the membership line, and it re-prices the
 * course itself, because `courseMainLine` reads the same flag to choose
 * between the member and non-member product.
 *
 * **No savings figure.** GarpAppv1 advertises "save USD 100.00" here; priced
 * live against this org, FRR25 saves 75 (500 → 425) and FFR saves 49
 * (199 → 150), so the legacy number is wrong for one of the two programmes.
 * The membership price is shown instead and the sticky bar's running total —
 * which re-prices the moment this is toggled — carries the rest. A claim we
 * cannot derive is a pricing decision for the business, not a port.
 */
function MembershipOfferSection({
	control,
	amount,
	disabled,
}: MembershipOfferSectionProps) {
	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<UserPlus className="size-5 text-muted-foreground" aria-hidden />
					{MEMBERSHIP_OFFER_COPY.title}
					<span className="text-body font-normal text-muted-foreground">
						{MEMBERSHIP_OFFER_COPY.optional}
					</span>
				</CardTitle>
			</CardHeader>
			<CardContent className="flex flex-col gap-4">
				<p className="text-body text-muted-foreground">
					{MEMBERSHIP_OFFER_COPY.body}
				</p>

				<Controller
					control={control}
					name="membershipSelected"
					render={({ field }) => (
						<div className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-border p-4">
							<p className="text-lg font-semibold">
								{amount != null ? formatMoney(amount, "USD") : "—"}
								<span className="text-body font-normal text-muted-foreground">
									{" "}
									{MEMBERSHIP_OFFER_COPY.term}
								</span>
							</p>
							{/*
							 * The label says what the click does, not what the state is —
							 * `Add` ⇄ `Remove`, never `Add` ⇄ `Added`. The cart line
							 * appearing in the rail already says it is in.
							 */}
							<Button
								type="button"
								size="sm"
								variant="outline"
								onClick={() => field.onChange(!field.value)}
								disabled={disabled}
								aria-pressed={field.value}
								className="shrink-0"
							>
								{field.value ? (
									<>
										<Minus aria-hidden /> Remove
									</>
								) : (
									<>
										<Plus aria-hidden /> Add
									</>
								)}
							</Button>
						</div>
					)}
				/>
			</CardContent>
		</Card>
	)
}

export { MembershipOfferSection }
