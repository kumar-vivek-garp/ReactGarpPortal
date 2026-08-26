import { useMutation } from "@tanstack/react-query"

import { AppError } from "@/api/client"
import {
	fetchExamPaymentStatus,
	payExamOrder,
	registerExam,
	startExamCheckout,
	verifyExamAddress,
	verifyExamCustomer,
} from "@/api/registration/exam-registration"
import type {
	ExamRegisterRequest,
	ExamRegisterResult,
	VerifyCustomerResult,
} from "@/api/registration/exam-types"

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
}

export type ExamSubmitOutcome =
	| { kind: "registered"; result: ExamRegisterResult }
	| { kind: "invoiced"; result: ExamRegisterResult }
	/** The browser is leaving for the payment provider; nothing else to render. */
	| { kind: "redirecting" }

/** Three tries, ~1.5s apart — the webhook is usually quicker than that. */
const STATUS_POLL_ATTEMPTS = 3
const STATUS_POLL_DELAY_MS = 1500

async function pollPaymentStatus(orderId: string): Promise<void> {
	for (let attempt = 0; attempt < STATUS_POLL_ATTEMPTS; attempt += 1) {
		const status = await fetchExamPaymentStatus(orderId)
		if (status.isOrderRolledback === true) {
			throw new AppError({
				messages: [
					"Payment was not completed and your registration was cancelled.",
				],
				status: 402,
			})
		}
		if (status.isPaymentFound === true) return
		await new Promise((resolve) => {
			window.setTimeout(resolve, STATUS_POLL_DELAY_MS)
		})
	}
	// Not an error. Wire and ACH are settled by finance days later, so an
	// unconfirmed status here is the normal case, not a failure to report.
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
 * 3. **register** — writes the order. From here a failure has left records
 *    behind, which is why nothing after this point is retried.
 * 4. **pay** — a card order leaves for the provider; everything else is
 *    completed server-side and then polled.
 *
 * `payOrder` is deliberately called once and never retried: Apex refuses a
 * second call on a completed order, and a duplicate would write a second
 * approved transaction — an order that looks paid twice.
 */
export function useExamRegistrationSubmit() {
	return useMutation<ExamSubmitOutcome, unknown, ExamSubmitInput>({
		mutationFn: async ({ request, checkAddress, session }) => {
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
							})),
							email,
						}

			if (verified.mustSignIn) throw new MustSignInError()

			const body: ExamRegisterRequest = {
				...request,
				sessionId: verified.sessionId ?? request.sessionId ?? null,
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
			const billed = result.hasBilling === true && (result.total ?? 0) > 0

			if (result.orderId && billed && body.paymentType === "Stripe") {
				// The provider returns to whichever URL we hand it, so this is
				// built from where the form is actually being served.
				const base = `${window.location.origin}${window.location.pathname}`
				const params = new URLSearchParams({
					stripe_return: "1",
					oid: result.orderId,
				})
				if (result.orderNumber) params.set("on", result.orderNumber)

				const checkout = await startExamCheckout({
					orderId: result.orderId,
					successUrl: `${base}?${params.toString()}`,
					cancelUrl: base,
				})

				if (checkout.checkoutUrl) {
					window.location.href = checkout.checkoutUrl
					return { kind: "redirecting" }
				}
				throw new AppError({
					messages: [checkout.msg?.trim() || "Unable to start checkout."],
					status: 502,
				})
			}

			if (result.orderId) {
				await payExamOrder(result.orderId, body.paymentType)
				await pollPaymentStatus(result.orderId).catch(() => undefined)
				const isOffline =
					body.paymentType === "Wire Transfer" || body.paymentType === "ACH"
				return { kind: isOffline ? "invoiced" : "registered", result }
			}

			return { kind: "registered", result }
		},
	})
}
