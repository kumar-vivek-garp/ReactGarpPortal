import { http, HttpResponse } from "msw"

import { ORDER_CHECKOUT_PATH } from "@/api/orders/order-checkout"
import type { OrderCheckoutRequest } from "@/api/orders/types"
import {
	MATERIAL_PURCHASE_PATH,
	MATERIAL_QUOTE_PATH,
} from "@/api/study-materials/material-purchase"
import { STUDY_MATERIALS_PATH } from "@/api/study-materials/study-materials"
import type {
	ApexStudyMaterialsPayload,
	MaterialPurchaseRequest,
	MaterialPurchaseResult,
	MaterialQuote,
	MyEBooksView,
} from "@/api/study-materials/types"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	materialPurchaseResult,
	materialQuote,
	orderCheckoutResult,
} from "@/testing/factories/study-material-purchase"
import {
	myEBooksEmpty,
	purchasable,
	studyMaterialsPayload,
} from "@/testing/factories/study-materials"

export const MY_EBOOKS_PATH = "/services/apexrest/memberportal/myEBooks"
export const EBOOK_ACCESS_PATH = "/services/apexrest/memberportal/eBookAccess"
export {
	MATERIAL_PURCHASE_PATH,
	MATERIAL_QUOTE_PATH,
	ORDER_CHECKOUT_PATH,
	STUDY_MATERIALS_PATH,
}

/** What a spied action observed: how often it was hit, with which bodies. */
export type ActionSpy<TBody> = {
	hits: number
	bodies: TBody[]
}

/**
 * The listing's org surface: the catalogue, the archive gate, and a spying
 * reader-link mint. Register with `server.use(...org.handlers)`; layer
 * scenario overrides (refusals, delays) on top with a later `server.use`.
 */
export function studyMaterialsOrg({
	payload = studyMaterialsPayload({ frmStudyMaterials: [purchasable()] }),
	eBooks = myEBooksEmpty(),
	accessUrl = "https://reader.example/book",
}: {
	payload?: ApexStudyMaterialsPayload
	eBooks?: MyEBooksView
	accessUrl?: string
} = {}) {
	const accessSpy: ActionSpy<string> = { hits: 0, bodies: [] }
	const handlers = [
		http.get(STUDY_MATERIALS_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(payload)),
		),
		http.get(MY_EBOOKS_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(eBooks)),
		),
		http.get(EBOOK_ACCESS_PATH, ({ request }) => {
			accessSpy.hits += 1
			accessSpy.bodies.push(
				new URL(request.url).searchParams.get("vendorId") ?? "",
			)
			return HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					accessURL: accessUrl,
				}),
			)
		}),
	]
	return { accessSpy, handlers }
}

/**
 * The purchase page's org surface: the quote, a spying `materialPurchase`
 * write, and a spying `orderCheckout`. `quote` may be `null` to model the
 * service's deliberate "not available" 404.
 */
export function materialPurchaseOrg({
	quote = materialQuote(),
	purchaseRespond = () => materialPurchaseResult(),
	checkoutRespond = () => orderCheckoutResult(),
}: {
	quote?: MaterialQuote | null
	purchaseRespond?: (body: MaterialPurchaseRequest, hits: number) => MaterialPurchaseResult
	checkoutRespond?: (
		body: OrderCheckoutRequest,
		hits: number,
	) => ReturnType<typeof orderCheckoutResult>
} = {}) {
	const purchaseSpy: ActionSpy<MaterialPurchaseRequest> = { hits: 0, bodies: [] }
	const checkoutSpy: ActionSpy<OrderCheckoutRequest> = { hits: 0, bodies: [] }
	const handlers = [
		http.get(MATERIAL_QUOTE_PATH, () =>
			quote
				? HttpResponse.json(memberPortalEnvelope(quote))
				: HttpResponse.json(
						{
							status: "Error",
							statusCode: 404,
							errorMessage: "This item is not available to purchase.",
							data: materialQuote({
								statusCode: 404,
								statusMessage: "This item is not available to purchase.",
								isShippable: false,
								shippableCountries: [],
							}),
						},
						{ status: 404 },
					),
		),
		http.post(MATERIAL_PURCHASE_PATH, async ({ request }) => {
			const body = (await request.json()) as MaterialPurchaseRequest
			purchaseSpy.hits += 1
			purchaseSpy.bodies.push(body)
			return HttpResponse.json(
				memberPortalEnvelope(purchaseRespond(body, purchaseSpy.hits)),
			)
		}),
		http.post(ORDER_CHECKOUT_PATH, async ({ request }) => {
			const body = (await request.json()) as OrderCheckoutRequest
			checkoutSpy.hits += 1
			checkoutSpy.bodies.push(body)
			return HttpResponse.json(
				memberPortalEnvelope(checkoutRespond(body, checkoutSpy.hits)),
			)
		}),
	]
	return { purchaseSpy, checkoutSpy, handlers }
}
