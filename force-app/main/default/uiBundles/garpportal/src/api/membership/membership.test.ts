import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client/errors"
import { fetchMembership } from "@/api/membership/membership"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const MEMBERSHIP_PATH = "/services/apexrest/memberportal/membership"

/**
 * Pilot for the MSW test stack: unlike the legacy SDK-module mocks, these
 * requests run through the real `createDataSDK` transport — CSRF acquisition
 * (via the jsdom `caches` stub), URL building, and envelope unwrapping all
 * execute for real.
 */
describe("fetchMembership (via MSW)", () => {
	it("loads the membership view through the real SDK transport", async () => {
		const view = { hero: { name: "Ada Lovelace" }, sections: [] }
		let csrfHits = 0

		server.use(
			http.get("/services/data/v65.0/ui-api/session/csrf", () => {
				csrfHits += 1
				return HttpResponse.json({ csrfToken: "pilot-token" })
			}),
			http.get(MEMBERSHIP_PATH, ({ request }) => {
				expect(request.headers.get("accept")).toContain("application/json")
				return HttpResponse.json(memberPortalEnvelope(view))
			}),
		)

		await expect(fetchMembership()).resolves.toEqual(view)
		// The SDK treats every apexrest URL as CSRF-protected — proof the real
		// transport (not a mock of it) carried the request.
		expect(csrfHits).toBeGreaterThan(0)
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.get(MEMBERSHIP_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Membership backend down"), {
					status: 500,
				}),
			),
		)

		const failure = fetchMembership()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Membership backend down"],
		})
	})
})
