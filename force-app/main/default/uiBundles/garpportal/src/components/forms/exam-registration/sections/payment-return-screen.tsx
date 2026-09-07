import { useState } from "react"
import { useLocation } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { RegistrationOutcome } from "@/components/forms/exam-registration/sections/registration-outcome"
import { RegistrationSurvey } from "@/components/forms/registration-survey/registration-survey"
import { EXAM_REGISTRATION_OUTCOMES } from "@/config/registration"
import { usePaymentReturnStatus } from "@/hooks/use-payment-return-status"
import {
	paymentReference,
	resolvePaymentReturnOutcome,
} from "@/lib/payment-return-presentation"
import { resumeHref } from "@/lib/registration-checkout"

type PaymentReturnScreenProps = {
	/** The `oid` the provider carried back — an order id, or a staged id. */
	statusId?: string | null
	/** The legacy `on` param, the last-resort reference. */
	orderNumber?: string | null
	/** The programme's short name, for the survey's title. */
	programName?: string | null
	isAuthenticated: boolean
}

/**
 * Where the payment provider sends a candidate who paid.
 *
 * Polls the order (or the staged row, under the deferred flow) rather than
 * declaring success on arrival, and settles on one of five screens — see
 * `resolvePaymentReturnOutcome`. A CONFIRMED payment shows the "Complete Your
 * Profile" survey inline, right here, before the closing copy: the survey's
 * save key is the same id this screen is polling on, passed internally, so it
 * behaves identically whether that id is a staged row or a real order.
 * Failures and rollbacks never reach the survey.
 */
function PaymentReturnScreen({
	statusId,
	orderNumber,
	programName,
	isAuthenticated,
}: PaymentReturnScreenProps) {
	const location = useLocation()
	const poll = usePaymentReturnStatus(statusId)
	const [surveyDone, setSurveyDone] = useState(false)

	const outcome = resolvePaymentReturnOutcome({ statusId, ...poll })
	const reference = paymentReference(poll.status, orderNumber)
	// A REG- number is a registration reference, not yet an order.
	const referenceLabel = poll.status?.orderNumber ? "Order" : "Reference"

	if (outcome === "confirming") {
		return (
			<RegistrationOutcome
				kind="confirming"
				orderNumber={reference}
				referenceLabel={referenceLabel}
				isAuthenticated={isAuthenticated}
				hideActions
				busy
			/>
		)
	}

	if (outcome === "issue") {
		const base = EXAM_REGISTRATION_OUTCOMES.paymentIssue
		return (
			<RegistrationOutcome
				kind="paymentIssue"
				copy={{
					...base,
					message: poll.pollError ? `${poll.pollError} ${base.message}` : base.message,
				}}
				orderNumber={reference}
				referenceLabel={referenceLabel}
				isAuthenticated={isAuthenticated}
			/>
		)
	}

	if (outcome === "declined") {
		const base = EXAM_REGISTRATION_OUTCOMES.paymentDeclined
		const reason = poll.status?.errorMessage?.trim() || "Your payment has not been received."
		return (
			<RegistrationOutcome
				kind="paymentDeclined"
				copy={{ ...base, message: `${reason} ${base.message}` }}
				orderNumber={reference}
				referenceLabel={referenceLabel}
				isAuthenticated={isAuthenticated}
				extraAction={
					statusId ? (
						/*
						 * Full reload on purpose: the staged row is still payable, and
						 * `?resume=` rebuilds the form from it so the retry keeps what
						 * was typed and its REG- reference.
						 */
						<Button asChild>
							<a href={resumeHref(location.pathname, statusId)}>Try again</a>
						</Button>
					) : null
				}
			/>
		)
	}

	if (outcome === "failed") {
		return (
			<RegistrationOutcome
				kind="registrationFailed"
				orderNumber={reference}
				referenceLabel={referenceLabel}
				isAuthenticated={isAuthenticated}
			/>
		)
	}

	// Succeeded. The survey first, then the closing copy — "paid" once the
	// order has closed, "finalising" while the webhook's job is still writing.
	const kind = poll.status?.isComplete === true || poll.status?.orderNumber ? "paid" : "finalising"
	return (
		<RegistrationOutcome
			kind={kind}
			orderNumber={reference}
			referenceLabel={referenceLabel}
			isAuthenticated={isAuthenticated}
			hideActions={!surveyDone}
		>
			{surveyDone ? null : (
				<RegistrationSurvey
					surveyKey={statusId ?? null}
					programName={programName}
					onFinished={() => setSurveyDone(true)}
				/>
			)}
		</RegistrationOutcome>
	)
}

export { PaymentReturnScreen }
