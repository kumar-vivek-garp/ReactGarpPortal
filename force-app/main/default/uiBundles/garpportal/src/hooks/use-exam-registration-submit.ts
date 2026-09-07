import { useMutation } from "@tanstack/react-query"

import { AppError } from "@/api/client"
import {
	fetchExamPaymentStatus,
	payExamOrder,
	registerExam,
	rollbackExamRegistration,
	startExamCheckout,
	verifyExamAddress,
	verifyExamCustomer,
} from "@/api/registration/exam-registration"
import type {
	ExamRegisterRequest,
	ExamRegisterResult,
	VerifyCustomerResult,
} from "@/api/registration/exam-types"
import {
	buildExamCheckoutUrls,
	isBilledResult,
	resolveSettlementId,
} from "@/lib/registration-checkout"
import { isOfflinePayment } from "@/lib/registration-presentation"

/** A `verifyCustomer` answer, tagged with the email it was obtained for. */
export type VerifiedSession = VerifyCustomerResult & { email: string }

/** Raised when the email already belongs to a member who must sign in first. */
export class MustSignInError extends AppError {
	constructor() {
		super({
			messages: [
				"An account already exists for this email address. Please sign in to continue.",
			],
			status: 409,
		})
		this.name = "MustSignInError"
	}
}

/** Raised when the server refuses the address — it carries its own wording. */
export class AddressRejectedError extends AppError {
	constructor(message: string) {
		super({ messages: [message], status: 400 })
		this.name = "AddressRejectedError"
	}
}

export type VerifyExamEmailInput = {
	/** The programme slug — `verifyCustomer` resolves against it. */
	type: string
	courseCode?: string | null
	email: string
	firstName: string
	lastName: string
	/**
	 * The `?track_cta=` tag the entry link carried, when it carried one. Apex
	 * writes it to the form session (`Form_Data__c.Track_CTA__c`), so a sale
	 * can be attributed to the My Account card, the benefits page or the
	 * gated-content upsell. `verifyCustomer` is the only call that takes it,
	 * as in GarpAppv1.
	 */
	trackCta?: string | null
}

/** The `tracking` block, or nothing at all — never `{ trackCta: undefined }`. */
function trackingFor(trackCta: string | null | undefined) {
	const tag = trackCta?.trim()
	return tag ? { tracking: { trackCta: tag } } : {}
}

/**
 * The identity check on blur, as GarpAppv1 runs it — so a guest whose email
 * already belongs to an account learns that before filling the rest of the
 * form rather than at submit. The tagged result doubles as the registration's
 * session: the submit mutation reuses it when the email still matches, so a
 * normal fill-and-submit makes one identity call, not two.
 */
export function useVerifyExamCustomer() {
	return useMutation<VerifiedSession, unknown, VerifyExamEmailInput>({
		mutationFn: async (input) => {
			const email = input.email.trim()
			const result = await verifyExamCustomer({
				type: input.type,
				courseCode: input.courseCode ?? null,
				email,
				firstName: input.firstName.trim(),
				lastName: input.lastName.trim(),
				...trackingFor(input.trackCta),
			})
			return { ...result, email }
		},
	})
}

export type ExamSubmitInput = {
	/** The body for both `verifyAddress` and `register` — identical shapes. */
	request: ExamRegisterRequest
	/** Skip the address check when no address was collected. */
	checkAddress: boolean
	/** A session from an earlier verify, reused when it is for this email. */
	session?: VerifiedSession | null
	/**
	 * The staged row this form was rebuilt from, when it was. Sent so the
	 * retry updates that row instead of stranding it with a live Stripe
	 * session nobody will pay.
	 */
	resumeStagedId?: string | null
	/**
	 * Attribution for the in-submit identity call — the member path, where no
	 * blur check ran because the email field is not on screen.
	 */
	trackCta?: string | null
}

export type ExamSubmitOutcome =
	| {
			kind: "registered"
			result: ExamRegisterResult
			/** The order or staged id — the survey's save key. */
			settlementId: string | null
	  }
	| { kind: "invoiced"; result: ExamRegisterResult; settlementId: string | null }
	/** The browser is leaving for the payment provider; nothing else to render. */
	| { kind: "redirecting" }

/** Three tries, ~1.5s apart — the webhook is usually quicker than that. */
export const STATUS_POLL_ATTEMPTS = 3
export const STATUS_POLL_DELAY_MS = 1500

function defaultSleep(ms: number): Promise<void> {
	return new Promise((resolve) => {
		window.setTimeout(resolve, ms)
	})
}

/**
 * After `payOrder`, a short look at the order.
 *
 * Stops as soon as the answer is settled either way: a payment that has
 * landed (`isPaymentSuccess`), or no payment recorded at all — which for a
 * wire or ACH order is the normal state, since finance settles those days
 * later, and for a free order means there was nothing to record. Only a
 * transaction that exists and has NOT succeeded is worth asking about again.
 * A rolled-back order is the one outcome reported as a failure.
 */
export async function pollPaymentStatus(
	orderId: string,
	{
		attempts = STATUS_POLL_ATTEMPTS,
		delayMs = STATUS_POLL_DELAY_MS,
		sleep = defaultSleep,
	}: { attempts?: number; delayMs?: number; sleep?: (ms: number) => Promise<void> } = {},
): Promise<void> {
	for (let attempt = 0; attempt < attempts; attempt += 1) {
		const status = await fetchExamPaymentStatus(orderId)
		if (status.isOrderRolledback === true) {
			throw new AppError({
				messages: [
					"Payment was not completed and your registration was cancelled.",
				],
				status: 402,
			})
		}
		if (status.isPaymentFound !== true || status.isPaymentSuccess === true) return
		await sleep(delayMs)
	}
}

/**
 * The whole submit, as one mutation.
 *
 * Four calls rather than one because that is the module's contract, and the
 * order matters:
 *
 * 1. **verify** — opens the `Form_Data__c` session `register` quotes back, and
 *    is the only place that can tell us the email belongs to a member who has
 *    to sign in. Skipped when an earlier check already covered this address.
 * 2. **verifyAddress** — skipped entirely when no address was collected (a
 *    card order gathers it at checkout) or when the programme disables it.
 *    Only the country is actually checked.
 * 3. **register** — writes the order, or under the deferred flow banks the
 *    payload on a staged row and returns its id instead. Either way, from
 *    here a failure has left something behind.
 * 4. **pay** — a card order leaves for the provider; everything else is
 *    completed server-side and then polled.
 *
 * From step 3 on, the org holds records — an Opportunity with its lines, an
 * exam attempt, draft contracts, and for a guest a brand-new Contact and
 * Account. Anything that ends this attempt short of a placed order has to
 * undo them, which is what `rollback` is for. `settled` is the one flag that
 * decides it: true once Stripe owns the order (the browser is on its way to
 * checkout), once finance does (`payOrder` placed a wire/ACH order), or when
 * nothing was billed and there is nothing to undo. Under the deferred flow
 * the staged id is what gets rolled back; the server answers "not found" for
 * it, which is swallowed — there is no order to unwind, and the row lapses
 * with its Stripe session.
 *
 * `payOrder` is deliberately called once and never retried: Apex refuses a
 * second call on a completed order, and a duplicate would write a second
 * approved transaction — an order that looks paid twice.
 */
export function useExamRegistrationSubmit() {
	return useMutation<ExamSubmitOutcome, unknown, ExamSubmitInput>({
		mutationFn: async ({
			request,
			checkAddress,
			session,
			resumeStagedId,
			trackCta,
		}) => {
			const email = request.customer.email.trim()

			const verified =
				session && session.email === email
					? session
					: {
							...(await verifyExamCustomer({
								type: request.type,
								courseCode: request.courseCode,
								email,
								firstName: request.customer.firstName,
								lastName: request.customer.lastName,
								...trackingFor(trackCta),
							})),
							email,
						}

			if (verified.mustSignIn) throw new MustSignInError()

			const body: ExamRegisterRequest = {
				...request,
				sessionId: verified.sessionId ?? request.sessionId ?? null,
				resumeStagedId: resumeStagedId ?? request.resumeStagedId ?? null,
				customer: {
					...request.customer,
					contactId: verified.contactId ?? request.customer.contactId ?? null,
					accountId: verified.accountId ?? request.customer.accountId ?? null,
					leadId: verified.leadId ?? request.customer.leadId ?? null,
				},
			}

			if (checkAddress) {
				const address = await verifyExamAddress(body)
				const refused =
					address.billingValid === false ||
					address.billingAllowed === false ||
					address.shippingValid === false ||
					address.shippingAllowed === false
				if (refused) {
					throw new AddressRejectedError(
						address.message?.trim() || "Please check the address you entered.",
					)
				}
			}

			const result = await registerExam(body)
			const settlementId = resolveSettlementId(result)
			const billed = isBilledResult(result)
			let settled = false

			try {
				if (settlementId && billed && body.paymentType === "Stripe") {
					// The provider returns to whichever URL we hand it, so this is
					// built from where the form is actually being served.
					const checkout = await startExamCheckout({
						orderId: settlementId,
						...buildExamCheckoutUrls(window.location, settlementId),
					})

					if (checkout.checkoutUrl && checkout.isError !== true) {
						// Stripe owns the order now. Leaving is not abandoning: the
						// cancel leg is what undoes it if the candidate walks.
						settled = true
						window.location.href = checkout.checkoutUrl
						return { kind: "redirecting" }
					}
					throw new AppError({
						messages: [checkout.msg?.trim() || "Unable to start checkout."],
						status: 502,
					})
				}

				if (settlementId) {
					await payExamOrder(settlementId, body.paymentType)
					// Placed. A polling failure after this point is a display
					// problem, not a reason to cancel a real order.
					settled = true
					await pollPaymentStatus(settlementId).catch(() => undefined)
					const kind = isOfflinePayment(body.paymentType ?? "")
						? "invoiced"
						: "registered"
					return { kind, result, settlementId }
				}

				// Nothing was billed and no order was written — nothing to undo.
				settled = true
				return { kind: "registered", result, settlementId }
			} finally {
				if (!settled && settlementId) {
					// Best effort, and deliberately not surfaced: the candidate is
					// already being shown why their registration failed, and a
					// rollback that itself fails must not replace that message
					// with a second, more confusing one. The server logs it.
					await rollbackExamRegistration(
						settlementId,
						"Registration not completed",
					).catch(() => undefined)
				}
			}
		},
	})
}
