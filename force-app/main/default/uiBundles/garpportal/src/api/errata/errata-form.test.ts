import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchErrataForm } from "@/api/errata/errata-form"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const ERRATA_FORM_PATH = "/services/apexrest/memberportal/errataForm"

describe("fetchErrataForm input and 200-with-error defence", () => {
	it("refuses a blank program type before it reaches the network", async () => {
		await expect(fetchErrataForm("   ")).rejects.toMatchObject({
			status: 400,
			messages: ["A program type is required."],
		})
	})

	/**
	 * The envelope can say Success at the HTTP layer while the payload itself
	 * carries a failure — the inner statusCode is the truth.
	 */
	it("surfaces an inner failure hidden inside an HTTP 200", async () => {
		server.use(
			http.get(ERRATA_FORM_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 500,
						statusMessage: "Errata options unavailable",
						errataPicklistOption: null,
					}),
				),
			),
		)

		await expect(fetchErrataForm("frm")).rejects.toMatchObject({
			status: 500,
			messages: ["Errata options unavailable"],
		})
	})

	it("falls back to its own sentence when the inner failure is silent", async () => {
		server.use(
			http.get(ERRATA_FORM_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 500,
						statusMessage: null,
						errataPicklistOption: null,
					}),
				),
			),
		)

		await expect(fetchErrataForm("frm")).rejects.toMatchObject({
			messages: ["Unable to load the errata form."],
		})
	})
})
