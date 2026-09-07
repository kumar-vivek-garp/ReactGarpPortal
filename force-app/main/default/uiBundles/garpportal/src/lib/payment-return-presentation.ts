/**
 * The pure rules of the payment RETURN leg — what the status poll means and
 * which screen it lands on. Ported from GarpAppv1's PaymentReturn, where the
 * rules were interleaved with the JSX; here they are testable on their own
 * and the screen only maps the outcome onto our own components.
 */

import { AppError } from "@/api/client"
import type { PaymentStatusResult } from "@/api/registration/exam-types"

/**
 * ~30s at a widening interval. It is waiting for STRIPE'S WEBHOOK, not for
 * the records: the queued job that writes them can take as long as the org's
 * async queue needs, and the screen settles the moment the payment is
 * confirmed, because that is the only thing the candidate came back to learn.
 */
export const PAYMENT_RETURN_DELAYS_MS = [
	800, 1200, 1600, 2000, 2500, 3000, 3500, 4000, 5000, 6000,
] as const

export type PaymentReturnOutcome =
	/** Still polling — the webhook has not answered yet. */
	| "confirming"
	/** The status endpoint refused the id, or never saw the registration. */
	| "issue"
	/** The card was declined; the staged row is still payable. */
	| "declined"
	/** Paid — records written or still being written. */
	| "succeeded"
	/** Paid, but the registration did not survive: rolled back or Failed. */
	| "failed"

/**
 * Stop polling here. `isPaymentSuccess`, not `isComplete`: the payment landing
 * is the answer. "Payment Failed" settles too — a declined async payment is an
 * answer, and polling past it would end on the optimistic copy, which is the
 * wrong thing to tell someone whose card was refused.
 */
export function isSettledStatus(status: PaymentStatusResult): boolean {
	return (
		status.isPaymentSuccess === true ||
		status.isOrderRolledback === true ||
		status.registrationStatus === "Failed" ||
		status.registrationStatus === "Payment Failed"
	)
}

/**
 * A response with no trace of the registration at all is a wrong or dead id —
 * it will not become right by asking again.
 */
export function isNothingFound(status: PaymentStatusResult): boolean {
	return (
		status.isOrderFound !== true &&
		status.isPaymentFound !== true &&
		!status.registrationStatus
	)
}

/**
 * Only a network hiccup earns a retry. `normalizeHttpResponse` reports an
 * unreachable service as `AppError{status: 0}`; a raw `fetch` rejection is a
 * `TypeError`. A server refusal ("Order not found") is deterministic — stop.
 */
export function isTransientNetworkError(error: unknown): boolean {
	if (error instanceof TypeError) return true
	return error instanceof AppError && error.status === 0
}

export type PaymentReturnState = {
	/** The id the page is polling on. Without one there is nothing to ask. */
	statusId: string | null | undefined
	settled: boolean
	status: PaymentStatusResult | null
	/** A deterministic refusal from the status endpoint. */
	pollError: string | null
}

/**
 * Which screen the return leg shows, in GarpAppv1's order of precedence.
 *
 * Only a clean success reaches the survey: a failure, a rollback, or an
 * inconclusive poll keeps the explanatory copy.
 */
export function resolvePaymentReturnOutcome({
	statusId,
	settled,
	status,
	pollError,
}: PaymentReturnState): PaymentReturnOutcome {
	if (!settled) return "confirming"
	const nothingFound = Boolean(statusId) && (!status || isNothingFound(status))
	if (pollError || nothingFound || !status) return "issue"
	if (status.registrationStatus === "Payment Failed") return "declined"
	if (
		status.isPaymentSuccess === true &&
		status.registrationStatus !== "Failed" &&
		status.isOrderRolledback !== true
	) {
		return "succeeded"
	}
	return "failed"
}

/**
 * The reference shown to the candidate: the order number once the order
 * exists, the REG- reference while it is still being written, or whatever the
 * legacy `on` param carried.
 */
export function paymentReference(
	status: PaymentStatusResult | null,
	urlOrderNumber: string | null | undefined,
): string | null {
	return status?.orderNumber || status?.registrationRef || urlOrderNumber || null
}
