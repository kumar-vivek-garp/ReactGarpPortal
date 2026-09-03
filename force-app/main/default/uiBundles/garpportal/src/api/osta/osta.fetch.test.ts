/**
 * The read side of the OSTA identity module, via MSW through the real SDK
 * transport. The write side's guards live in `osta.test.ts` (legacy SDK mock,
 * kept by explicit decision) — this file covers only what that one does not:
 * `fetchOsta`, the silent-refusal fallback on save, and the query options.
 */
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { fetchOsta, saveOsta } from "@/api/osta/osta"
import { ostaQueryOptions } from "@/api/osta/query-options"
import type { OstaView } from "@/api/osta/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const OSTA_PATH = "/services/apexrest/memberportal/osta"

function ostaView(overrides: Partial<OstaView> = {}): OstaView {
	return {
		statusMessage: null,
		statusCode: 200,
		ostaIdInfo: {
			idType: "Passport",
			idLocation: "China",
			/** The masked tail — the read never returns the full number. */
			idNumber: "45678",
			idExpireDate: "04/09/2030",
			ostaConsent: false,
		},
		...overrides,
	}
}

describe("fetchOsta", () => {
	it("returns the identity details on file", async () => {
		const view = ostaView()
		server.use(
			http.get(OSTA_PATH, () => HttpResponse.json(memberPortalEnvelope(view))),
		)

		await expect(fetchOsta()).resolves.toEqual(view)
	})

	it("throws the inner refusal even on an HTTP 200", async () => {
		server.use(
			http.get(OSTA_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						ostaView({ statusCode: 404, statusMessage: "No exam attempt" }),
					),
				),
			),
		)

		await expect(fetchOsta()).rejects.toMatchObject({
			messages: ["No exam attempt"],
			status: 404,
		})
	})

	it("surfaces the server's error message on a transport failure", async () => {
		server.use(
			http.get(OSTA_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Identity service down"), {
					status: 500,
				}),
			),
		)

		const failure = fetchOsta()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Identity service down"],
		})
	})
})

describe("saveOsta (silent refusal)", () => {
	it("falls back to readable wording when the refusal has no message", async () => {
		server.use(
			http.post(OSTA_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ statusMessage: "  ", statusCode: 501 }),
				),
			),
		)

		await expect(
			saveOsta({
				idType: "Passport",
				idLocation: "China",
				idNumber: "G12345678",
				idExpireDate: "04/09/2030",
				ostaConsent: true,
			}),
		).rejects.toMatchObject({
			messages: ["Your identity details could not be saved."],
			status: 501,
		})
	})
})

describe("ostaQueryOptions", () => {
	it("never caches — the read is masked and the consent always unticked", () => {
		expect(ostaQueryOptions.staleTime).toBe(0)
		expect(ostaQueryOptions.gcTime).toBe(0)
		expect(ostaQueryOptions.queryKey).toEqual(["osta", "identity"])
	})
})
