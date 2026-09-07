import { useRef } from "react"
import { useMutation, useQuery } from "@tanstack/react-query"

import { AppError } from "@/api/client"
import { orderCheckout } from "@/api/orders/order-checkout"
import { purchaseMaterial } from "@/api/study-materials/material-purchase"
import { materialQuoteQueryOptions } from "@/api/study-materials/query-options"
import type {
	MaterialPurchaseRequest,
	MaterialPurchaseResult,
} from "@/api/study-materials/types"
import { siteBasePath } from "@/auth/sfdc-env"
import {
	buildMaterialCheckoutUrls,
	resolvePayableId,
} from "@/lib/study-material-checkout"

/** The price and shipping facts for one material, or `null` when it cannot be bought. */
export function useMaterialQuote(productCode: string) {
	return useQuery(materialQuoteQueryOptions(productCode))
}

/**
 * Raised when the order exists but the payment page would not open.
 *
 * Under the immediate flow an unpaid Opportunity has been written and there
 * is no rollback for a material — so the form must hand the member to that
 * order (Order History can pay it) rather than re-offer Pay and write a
 * second one. Under the deferred flow nothing was written and Pay is safe.
 */
export class CheckoutUnavailableError extends AppError {
	readonly purchase: Pick<
		MaterialPurchaseResult,
		"orderId" | "orderNumber" | "stagedId"
	>

	constructor(
		purchase: Pick<MaterialPurchaseResult, "orderId" | "orderNumber" | "stagedId">,
	) {
		super({
			messages: [
				purchase.orderId
					? "Your order was saved, but we could not open the payment page. You can pay for it from Order History."
					: "We could not open the payment page. Nothing has been charged — please try again.",
			],
			status: 502,
		})
		this.name = "CheckoutUnavailableError"
		this.purchase = purchase
	}
}

export type MaterialPurchaseOutcome = { kind: "redirecting" }

/**
 * The submit sequence: raise the order, then hand whichever id came back to
 * the hosted checkout and leave for the provider.
 *
 * `retry: 0` is explicit because `materialPurchase` is not idempotent. The
 * form owns the messaging (`meta.silent`): a failure renders against the
 * address it has to be fixed in.
 *
 * The order is REMEMBERED for the life of the page. Pressing Back from the
 * hosted checkout restores this page from the browser's back-forward cache
 * with its state intact, and a second Continue must not write a second
 * order — for the same item and address it reopens checkout for the one
 * already raised. A different address is a different order.
 */
export function useMaterialPurchaseSubmit() {
	const raised = useRef<{ key: string; result: MaterialPurchaseResult } | null>(null)

	return useMutation<MaterialPurchaseOutcome, unknown, MaterialPurchaseRequest>({
		retry: 0,
		mutationFn: async (request) => {
			const key = JSON.stringify(request)
			const created =
				raised.current?.key === key
					? raised.current.result
					: await purchaseMaterial(request)
			raised.current = { key, result: created }
			const payableId = resolvePayableId(created)
			if (!payableId) {
				throw new AppError({
					messages: [
						created.statusMessage ?? "This purchase could not be started.",
					],
					status: 502,
				})
			}

			const { successUrl, cancelUrl } = buildMaterialCheckoutUrls(
				window.location,
				siteBasePath(),
			)
			const checkout = await orderCheckout({
				orderId: payableId,
				successUrl,
				cancelUrl,
			}).catch(() => null)
			if (!checkout) throw new CheckoutUnavailableError(created)

			window.location.assign(checkout.checkoutUrl)
			return { kind: "redirecting" }
		},
		meta: { silent: true },
	})
}
