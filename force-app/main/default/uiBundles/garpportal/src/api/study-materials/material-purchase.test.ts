import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import {
	memberPortalEnvelope,
	memberPortalError,
	memberPortalRefusal,
} from "@/testing/factories/envelope"
import {
	materialPurchaseResult,
	materialQuote,
	materialShipTo,
} from "@/testing/factories/study-material-purchase"
import { server } from "@/testing/msw/server"

import {
	fetchMaterialQuote,
	MATERIAL_PURCHASE_PATH,
	MATERIAL_QUOTE_PATH,
	purchaseMaterial,
} from "./material-purchase"

describe("fetchMaterialQuote", () => {
	it("asks for the encoded product code and returns the quote", async () => {
		let asked: string | null = null
		server.use(
			http.get(MATERIAL_QUOTE_PATH, ({ request }) => {
				asked = new URL(request.url).searchParams.get("productCode")
				return HttpResponse.json(memberPortalEnvelope(materialQuote()))
			}),
		)

		const quote = await fetchMaterialQuote(" SCR/H ")
		expect(asked).toBe("SCR/H")
		expect(quote).toMatchObject({ productCode: "SCRH", total: 115, isShippable: true })
	})

	it("refuses a blank code before touching the network", async () => {
		await expect(fetchMaterialQuote("  ")).rejects.toMatchObject({ status: 400 })
	})

	it("resolves null for the service's deliberate 404 — owned, unavailable or unknown", async () => {
		server.use(
			http.get(MATERIAL_QUOTE_PATH, () =>
				HttpResponse.json(
					memberPortalRefusal(
						404,
						"This item is not available to purchase.",
						materialQuote({ statusCode: 404, isShippable: false }),
					),
					{ status: 404 },
				),
			),
		)

		await expect(fetchMaterialQuote("FRMBP")).resolves.toBeNull()
	})

	it("still throws for a 404 with an empty body — a routing problem, not a refusal", async () => {
		server.use(
			http.get(MATERIAL_QUOTE_PATH, () =>
				HttpResponse.json(memberPortalError(404, "Unknown action"), { status: 404 }),
			),
		)

		await expect(fetchMaterialQuote("SCRH")).rejects.toMatchObject({
			messages: ["Unknown action"],
		})
	})

	it("throws Portal Access Denied rather than dressing it up as unavailable", async () => {
		server.use(
			http.get(MATERIAL_QUOTE_PATH, () =>
				HttpResponse.json(
					memberPortalRefusal(
						403,
						"Portal Access Denied",
						materialQuote({ statusCode: 403, statusMessage: "Portal Access Denied" }),
					),
					{ status: 403 },
				),
			),
		)

		await expect(fetchMaterialQuote("SCRH")).rejects.toBeInstanceOf(AppError)
	})

	it("throws an inner non-200 with the server's sentence", async () => {
		server.use(
			http.get(MATERIAL_QUOTE_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						materialQuote({ statusCode: 501, statusMessage: "Missing required information" }),
					),
				),
			),
		)

		await expect(fetchMaterialQuote("SCRH")).rejects.toMatchObject({
			messages: ["Missing required information"],
			status: 501,
		})
	})

	it("normalises the optional shape — no address, no list, no shippable flag", async () => {
		server.use(
			http.get(MATERIAL_QUOTE_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						...materialQuote(),
						isShippable: undefined,
						shipTo: undefined,
						shippableCountries: undefined,
					}),
				),
			),
		)

		await expect(fetchMaterialQuote("SCRH")).resolves.toMatchObject({
			isShippable: false,
			shipTo: null,
			shippableCountries: [],
		})
	})
})

describe("purchaseMaterial", () => {
	const request = { productCode: "SCRH", shipTo: materialShipTo() }

	it("posts the product code and address exactly, and returns the order", async () => {
		let body: unknown = null
		server.use(
			http.post(MATERIAL_PURCHASE_PATH, async ({ request: incoming }) => {
				body = await incoming.json()
				return HttpResponse.json(memberPortalEnvelope(materialPurchaseResult()))
			}),
		)

		const created = await purchaseMaterial(request)
		expect(body).toEqual(request)
		expect(created).toMatchObject({ orderId: "006PUR00000000001", orderNumber: "INV-0009" })
	})

	it("surfaces the address refusal as the server wrote it", async () => {
		server.use(
			http.post(MATERIAL_PURCHASE_PATH, () =>
				HttpResponse.json(
					memberPortalRefusal(
						501,
						"A full shipping address is required for a printed book.",
						materialPurchaseResult({
							statusCode: 501,
							statusMessage: "A full shipping address is required for a printed book.",
							orderId: null,
							orderNumber: null,
						}),
					),
					{ status: 501 },
				),
			),
		)

		await expect(purchaseMaterial(request)).rejects.toMatchObject({
			messages: ["A full shipping address is required for a printed book."],
			status: 501,
		})
	})

	it("surfaces a rate limit", async () => {
		server.use(
			http.post(MATERIAL_PURCHASE_PATH, () =>
				HttpResponse.json(memberPortalError(429, "Too many orders"), { status: 429 }),
			),
		)

		await expect(purchaseMaterial(request)).rejects.toMatchObject({
			messages: ["Too many orders"],
			status: 429,
		})
	})

	it("throws an inner non-200 inside an HTTP 200", async () => {
		server.use(
			http.post(MATERIAL_PURCHASE_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						materialPurchaseResult({
							statusCode: 501,
							statusMessage: "Your order could not be created.",
						}),
					),
				),
			),
		)

		await expect(purchaseMaterial(request)).rejects.toMatchObject({
			messages: ["Your order could not be created."],
		})
	})
})
