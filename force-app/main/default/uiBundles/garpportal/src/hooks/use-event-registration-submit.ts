import { useMutation } from "@tanstack/react-query"

import { AppError } from "@/api/client"
import {
	declineEventRsvp,
	registerForEvent,
	rollbackEventRegistration,
	startRegistrationCheckout,
} from "@/api/registration/event-registration"
import type {
	EventRegisterRequest,
	EventRegisterResult,
	EventVariant,
} from "@/api/registration/event-types"
import { buildEventCheckoutUrls } from "@/lib/event-registration-payloads"

export type EventSubmitOutcome =
	/** Free registration, complete on return. */
	| { kind: "registered"; result: EventRegisterResult }
	/** Paid: the browser is on its way to the hosted checkout page. */
	| { kind: "redirecting" }

/**
 * The submit sequence: register, then — when the RESULT says the order costs
 * money (`isFree: false` with an `orderId`, never the load's flags) — hand the
 * staged order to the shared hosted checkout and leave for Stripe.
 *
 * If checkout will not open, the registration is rolled back before the error
 * is surfaced: past `register` a failure leaves records behind, and an orphan
 * pending order locks the person out as `alreadyRegistered`.
 *
 * `meta.silent`: a failure renders against the form it has to be fixed in.
 */
export function useEventRegistrationSubmit() {
	return useMutation<
		EventSubmitOutcome,
		unknown,
		{ request: EventRegisterRequest; variant: EventVariant }
	>({
		mutationFn: async ({ request, variant }) => {
			const result = await registerForEvent(request, variant)

			if (result.isFree === false && result.orderId) {
				const { successUrl, cancelUrl } = buildEventCheckoutUrls(
					window.location,
					result,
				)
				const checkout = await startRegistrationCheckout({
					orderId: result.orderId,
					successUrl,
					cancelUrl,
				}).catch(() => null)

				if (!checkout?.checkoutUrl) {
					await rollbackEventRegistration(
						result.orderId,
						"Checkout unavailable",
					).catch(() => undefined)
					throw new AppError({
						messages: [
							"We could not open the payment page, so your registration was not completed. Please try again.",
						],
						status: 502,
					})
				}

				window.location.href = checkout.checkoutUrl
				return { kind: "redirecting" }
			}

			return { kind: "registered", result }
		},
		meta: { silent: true },
	})
}

/**
 * Records an invite-only decline. Silent for the same reason — the gate shows
 * its own error inline, and success replaces the gate with the declined
 * screen.
 */
export function useDeclineEventRsvp() {
	return useMutation<unknown, unknown, { eventId: string; userEmail: string }>({
		mutationFn: declineEventRsvp,
		meta: { silent: true },
	})
}
