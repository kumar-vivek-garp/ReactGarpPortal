/**
 * Only the refusal branch — the happy path and list default are already
 * exercised through the dashboard suites.
 */
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchExamNotifications } from "@/api/notifications/notifications"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const NOTIFICATIONS_PATH = "/services/apexrest/memberportal/examNotifications"

describe("fetchExamNotifications", () => {
	it("throws the inner refusal even on an HTTP 200", async () => {
		server.use(
			http.get(NOTIFICATIONS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "No portal access",
						statusCode: 401,
						notifications: null,
					}),
				),
			),
		)

		await expect(fetchExamNotifications()).rejects.toMatchObject({
			messages: ["No portal access"],
			status: 401,
		})
	})
})
