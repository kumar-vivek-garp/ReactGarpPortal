/**
 * Only the refusal branch — the happy path and bucket defaults are already
 * exercised through the events page and hook suites.
 */
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchEvents } from "@/api/events/events"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const EVENTS_PATH = "/services/apexrest/memberportal/events"

describe("fetchEvents", () => {
	it("throws the inner refusal even on an HTTP 200", async () => {
		server.use(
			http.get(EVENTS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "No portal access",
						statusCode: 401,
					}),
				),
			),
		)

		await expect(fetchEvents()).rejects.toMatchObject({
			messages: ["No portal access"],
			status: 401,
		})
	})

	it("falls back to its own wording for a silent refusal", async () => {
		server.use(
			http.get(EVENTS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ statusMessage: null, statusCode: 500 }),
				),
			),
		)

		await expect(fetchEvents()).rejects.toMatchObject({
			messages: ["Unable to load events."],
		})
	})
})
