import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { requestEmailPreferences } from "@/api/contact-preferences/update-email-preference"
import { memberPortalError } from "@/testing/factories/envelope"
import {
	EMAIL_PREFERENCE_UPDATE_PATH,
	emailPreferenceHandler,
} from "@/testing/msw/handlers/contact-preferences"
import { server } from "@/testing/msw/server"

describe("requestEmailPreferences", () => {
	it("posts once and resolves when the stamp is recorded", async () => {
		const org = emailPreferenceHandler()
		server.use(org.handler)

		await expect(requestEmailPreferences()).resolves.toBeUndefined()
		expect(org.spy.hits).toBe(1)
	})

	it("surfaces the service's own refusal", async () => {
		server.use(
			emailPreferenceHandler(() => ({
				statusMessage: "Email preference field is not available.",
				statusCode: 501,
			})).handler,
		)

		const failure = requestEmailPreferences()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Email preference field is not available."],
			status: 501,
		})
	})

	it("surfaces a router-level refusal", async () => {
		server.use(
			http.post(EMAIL_PREFERENCE_UPDATE_PATH, () =>
				HttpResponse.json(memberPortalError(403, "No member record."), {
					status: 403,
				}),
			),
		)

		await expect(requestEmailPreferences()).rejects.toMatchObject({
			messages: ["No member record."],
		})
	})
})
