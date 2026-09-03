import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchEBookAccess, fetchMyEBooks } from "@/api/study-materials/ebooks"
import type { ApexArchiveEBook } from "@/api/study-materials/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const MY_EBOOKS_PATH = "/services/apexrest/memberportal/myEBooks"
const EBOOK_ACCESS_PATH = "/services/apexrest/memberportal/eBookAccess"

const ownedBook: ApexArchiveEBook = {
	title: "FRM Part I Books",
	provider: "Mobius",
	eBookItems: [{ title: "Book 1", vendorId: 101 }],
}

describe("fetchMyEBooks", () => {
	it("returns the year-keyed map exactly as sent", async () => {
		server.use(
			http.get(MY_EBOOKS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						eBooks: { "2026": [ownedBook] },
					}),
				),
			),
		)

		await expect(fetchMyEBooks()).resolves.toMatchObject({
			eBooks: { "2026": [ownedBook] },
		})
	})

	it("substitutes an empty map when the payload has none", async () => {
		server.use(
			http.get(MY_EBOOKS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ statusMessage: null, statusCode: 200 }),
				),
			),
		)

		await expect(fetchMyEBooks()).resolves.toMatchObject({ eBooks: {} })
	})

	it("throws the inner refusal even on an HTTP 200", async () => {
		server.use(
			http.get(MY_EBOOKS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "No purchases found",
						statusCode: 404,
						eBooks: null,
					}),
				),
			),
		)

		await expect(fetchMyEBooks()).rejects.toMatchObject({
			messages: ["No purchases found"],
			status: 404,
		})
	})
})

describe("fetchEBookAccess", () => {
	it("refuses a blank vendor id before it reaches the network", async () => {
		await expect(fetchEBookAccess("  ")).rejects.toMatchObject({
			messages: ["A book id is required."],
			status: 400,
		})
	})

	it("exchanges the encoded vendor id for the signed link", async () => {
		let search: URLSearchParams | undefined
		server.use(
			http.get(EBOOK_ACCESS_PATH, ({ request }) => {
				search = new URL(request.url).searchParams
				return HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						accessURL: " https://reader.example/open?t=abc ",
					}),
				)
			}),
		)

		await expect(fetchEBookAccess(" 101/a ")).resolves.toBe(
			"https://reader.example/open?t=abc",
		)
		expect(search?.get("vendorId")).toBe("101/a")
	})

	it("treats a 200 with no link as a failure", async () => {
		server.use(
			http.get(EBOOK_ACCESS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						accessURL: "  ",
					}),
				),
			),
		)

		await expect(fetchEBookAccess("101")).rejects.toMatchObject({
			messages: ["This book could not be opened."],
		})
	})

	it("surfaces the server's error message on a transport failure", async () => {
		server.use(
			http.get(EBOOK_ACCESS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Vendor unavailable"), {
					status: 500,
				}),
			),
		)

		await expect(fetchEBookAccess("101")).rejects.toMatchObject({
			messages: ["Vendor unavailable"],
		})
	})
})
