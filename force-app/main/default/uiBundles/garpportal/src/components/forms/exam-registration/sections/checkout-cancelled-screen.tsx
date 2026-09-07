import { useEffect, useRef } from "react"
import { useLocation } from "@tanstack/react-router"

import { notifyError } from "@/api/client"
import { rollbackExamRegistration } from "@/api/registration/exam-registration"
import { Button } from "@/components/atoms/button"
import { RegistrationOutcome } from "@/components/forms/exam-registration/sections/registration-outcome"

type CheckoutCancelledScreenProps = {
	/** The order the provider carried back. Nothing to undo without one. */
	orderId?: string | null
	isAuthenticated: boolean
}

/**
 * Where the payment provider sends a candidate who backs out of checkout.
 *
 * The registration already created an order, an exam attempt, candidate
 * requirements and — for a guest — a Contact and Account. None of it is paid
 * for, so the first thing this screen does is cancel it. Leaving it would put a
 * seat-looking record in front of back office that nobody ever bought.
 *
 * Rolled back exactly once (the ref survives StrictMode's double-invoke),
 * never retried, and its outcome is not gated on: whatever happens
 * server-side the candidate is told the same thing and offered the form
 * again. A failed rollback is reported in a toast and logged server-side.
 *
 * Under the deferred flow this screen is never reached: the staged cancel URL
 * carries `resume` as well, which wins, and there is nothing to roll back.
 */
function CheckoutCancelledScreen({
	orderId,
	isAuthenticated,
}: CheckoutCancelledScreenProps) {
	const location = useLocation()
	const rolledBack = useRef(false)

	useEffect(() => {
		if (!orderId || rolledBack.current) return
		rolledBack.current = true
		rollbackExamRegistration(orderId, "Checkout cancelled").catch(
			(error: unknown) => {
				notifyError(error, "Unable to cancel the registration")
			},
		)
	}, [orderId])

	return (
		<RegistrationOutcome
			kind="cancelled"
			isAuthenticated={isAuthenticated}
			extraAction={
				/* Full reload on purpose: a fresh load after the rollback is the
				   only state worth starting from. */
				<Button asChild variant="outline">
					<a href={location.pathname}>Start again</a>
				</Button>
			}
		/>
	)
}

export { CheckoutCancelledScreen }
