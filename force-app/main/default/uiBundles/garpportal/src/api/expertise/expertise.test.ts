/**
 * Only the refusal branches — happy paths for load and save are already
 * exercised through the expertise card suite.
 */
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchExpertise, saveExpertise } from "@/api/expertise/expertise"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const EXPERTISE_PATH = "/services/apexrest/memberportal/expertise"

describe("fetchExpertise", () => {
	it("throws the inner refusal even on an HTTP 200", async () => {
		server.use(
			http.get(EXPERTISE_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "No SME registration",
						statusCode: 404,
					}),
				),
			),
		)

		await expect(fetchExpertise()).rejects.toMatchObject({
			messages: ["No SME registration"],
			status: 404,
		})
	})
})

describe("saveExpertise", () => {
	it("throws the inner refusal, falling back to its own wording", async () => {
		server.use(
			http.post(EXPERTISE_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ statusMessage: null, statusCode: 500 }),
				),
			),
		)

		await expect(saveExpertise({})).rejects.toMatchObject({
			messages: ["Your expertise could not be saved."],
			status: 500,
		})
	})
})
