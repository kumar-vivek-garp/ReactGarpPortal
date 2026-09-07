import { BookOpenText, Minus, Plus } from "lucide-react"
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
import { RISK_NET_OFFER_COPY } from "@/config/registration"
import { formatMoney } from "@/lib/account-format"

type RiskNetOfferSectionProps = {
	control: Control<ExamFormValues>
	/** As priced by the server — flat for a plain year, per-month otherwise. */
	amount?: number
	/** The cover the price buys: months left on the membership plus twelve. */
	months?: number
	disabled?: boolean
}

/**
 * The Risk.net content-hub add-on — the membership programme's one add-on.
 *
 * A cart control rather than a checkbox, like the course membership upsell it
 * borrows its shape from: ticking it is a whole extra order line (MEMR), and
 * the rail's running total re-prices the moment it is toggled.
 *
 * The price is the server's and tracks the member's remaining cover; the body
 * copy's "12 months" is literal, as it is in GarpAppv1 and the legacy form,
 * and is left alone — the months the price actually buys sit beside the
 * amount instead, where they are a fact rather than a copy change.
 */
function RiskNetOfferSection({
	control,
	amount,
	months,
	disabled,
}: RiskNetOfferSectionProps) {
	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<BookOpenText className="size-5 text-muted-foreground" aria-hidden />
					{RISK_NET_OFFER_COPY.title}
					<span className="text-body font-normal text-muted-foreground">
						{RISK_NET_OFFER_COPY.optional}
					</span>
				</CardTitle>
			</CardHeader>
			<CardContent className="flex flex-col gap-4">
				<div className="flex flex-col gap-1">
					<p className="text-lg font-semibold text-foreground">
						{RISK_NET_OFFER_COPY.brand}
					</p>
					<p className="text-body font-semibold text-foreground">
						{RISK_NET_OFFER_COPY.tagline}
					</p>
				</div>
				<p className="text-body text-muted-foreground">
					{RISK_NET_OFFER_COPY.body}
				</p>
				<p className="text-caption text-muted-foreground">
					{RISK_NET_OFFER_COPY.privacyIntro}{" "}
					<a
						href={RISK_NET_OFFER_COPY.privacyUrl}
						target="_blank"
						rel="noreferrer"
						className="font-medium text-primary underline underline-offset-2"
					>
						{RISK_NET_OFFER_COPY.privacyLabel}
					</a>
					.
				</p>

				<Controller
					control={control}
					name="riskNetSelected"
					render={({ field }) => (
						<div className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-border p-4">
							<p className="text-lg font-semibold">
								{amount != null ? formatMoney(amount, "USD") : "—"}
								{months != null && months > 0 ? (
									<span className="text-body font-normal text-muted-foreground">
										{" "}
										for {months} months
									</span>
								) : null}
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

export { RiskNetOfferSection }
