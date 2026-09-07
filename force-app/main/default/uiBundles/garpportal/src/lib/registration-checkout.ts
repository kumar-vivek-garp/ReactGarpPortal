/**
 * The pure rules of the payment leg, shared by the submit hook and the return
 * screens so the two cannot disagree about which id names a registration or
 * where the provider sends the browser back.
 */

import type { ExamRegisterResult } from "@/api/registration/exam-types"

/**
 * Whichever id `register` handed back — the order when the flow is immediate,
 * the staged `Order_History__c` row under the deferred flow. Every later call
 * (`checkout`, `paymentStatus`, `rollback`, the survey save) takes this one
 * value; the server routes on what the id actually points at.
 */
export function resolveSettlementId(
	result: Pick<ExamRegisterResult, "orderId" | "stagedId">,
): string | null {
	return result.orderId || result.stagedId || null
}

/** Something to pay for. Nothing billed means no checkout and no `payOrder`. */
export function isBilledResult(
	result: Pick<ExamRegisterResult, "hasBilling" | "total">,
): boolean {
	return result.hasBilling === true && (result.total ?? 0) > 0
}

/**
 * The checkout return addresses, built from wherever the form was served so
 * the provider comes back to the same route.
 *
 * Two parameters on the success leg and no more: `stripe_return` names the
 * leg, `oid` names the registration. The order NUMBER does not travel — under
 * the deferred flow there is none yet, and the status poll answers with it.
 *
 * The cancel leg carries `oid` so the page can roll the order back. For a
 * STAGED checkout the server appends `resume=<stagedId>` to this URL itself,
 * which the page reads ahead of `checkout_cancelled`.
 */
export function buildExamCheckoutUrls(
	location: { origin: string; pathname: string },
	settlementId: string,
): { successUrl: string; cancelUrl: string } {
	const base = `${location.origin}${location.pathname}`
	const success = new URLSearchParams({ stripe_return: "1", oid: settlementId })
	const cancel = new URLSearchParams({
		checkout_cancelled: "1",
		oid: settlementId,
	})
	return {
		successUrl: `${base}?${success.toString()}`,
		cancelUrl: `${base}?${cancel.toString()}`,
	}
}

/**
 * Where "Try again" points after a declined payment: the same form, rebuilt
 * from the staged row so the retry keeps what was typed and its REG- number.
 */
export function resumeHref(pathname: string, stagedId: string): string {
	const params = new URLSearchParams({ resume: stagedId })
	return `${pathname}?${params.toString()}`
}
