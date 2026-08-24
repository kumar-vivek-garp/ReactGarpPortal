import { CircleAlert } from "lucide-react"

import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { Button } from "@/components/atoms/button"
import { CardCta } from "@/components/molecules/card-cta"
import { EXAM_SETUP_FEE_GATE } from "@/config/exam-setup"
import type { ExamSetupFeeForecast } from "@/lib/exam-setup-presentation"
import { cn } from "@/lib/utils"

function formatUsd(amount: number): string {
	return new Intl.NumberFormat("en-US", {
		style: "currency",
		currency: "USD",
		minimumFractionDigits: 0,
	}).format(amount)
}

type ExamSetupFeeGateProps = {
	forecast: ExamSetupFeeForecast
	myGarpHref: string | null
	onReset: () => void
	/**
	 * True once Apex has already raised the modification — the OSTA case the
	 * forecast cannot see. Changes the copy from "nothing has happened" to
	 * "this is pending", because by then it has.
	 */
	isPending?: boolean
	className?: string
}

/**
 * A stop, not a payment screen.
 *
 * `examSetupFees` prices a change but returns no order and no checkout URL, and
 * `examSetupAuthorize` refuses any sitting whose Opportunity is not already
 * Closed. Nothing in the portal API raises that Opportunity, so a member who
 * paid here would be paying into nothing.
 *
 * Reached two ways, and the difference matters to the member:
 *
 *   before the save  the forecast caught an administration change. Nothing has
 *                    been written; backing out costs nothing.
 *   after the save   Apex answered `Pay Fees` for a fee the forecast could not
 *                    see (an OSTA site move — the flag that decides it is not
 *                    on the wire). A modification now exists in Pending, so the
 *                    copy says so rather than implying the change can simply be
 *                    abandoned.
 */
function ExamSetupFeeGate({
	forecast,
	myGarpHref,
	onReset,
	isPending = false,
	className,
}: ExamSetupFeeGateProps) {
	return (
		<Alert
			variant="destructive"
			role="status"
			className={cn("gap-y-2", className)}
		>
			<CircleAlert aria-hidden />
			<AlertTitle>
				{EXAM_SETUP_FEE_GATE.title} — {formatUsd(forecast.amount)}
			</AlertTitle>
			<AlertDescription className="gap-2">
				<span>{forecast.reason}.</span>
				<span>
					{isPending
						? "We've recorded your change, but it won't take effect until the fee is paid. Payment isn't available in this portal yet — finish in MyGarp."
						: EXAM_SETUP_FEE_GATE.message}
				</span>
				<div className="mt-1 flex flex-wrap items-center gap-3">
					{myGarpHref ? (
						<CardCta
							label={EXAM_SETUP_FEE_GATE.ctaLabel}
							url={myGarpHref}
							isExternal
							className="text-sm text-destructive hover:text-destructive/80"
						/>
					) : null}
					{isPending ? null : (
						<Button
							type="button"
							variant="outline"
							size="sm"
							onClick={onReset}
						>
							{EXAM_SETUP_FEE_GATE.resetLabel}
						</Button>
					)}
				</div>
			</AlertDescription>
		</Alert>
	)
}

export { ExamSetupFeeGate }
