import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { saveAccountProfile } from "@/api/account/save-profile"
import type { SaveAccountProfileResult } from "@/api/account/types"
import { AppError } from "@/api/client"
import { completeness } from "@/testing/factories/account"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const PROFILE_PATH = "/services/apexrest/memberportal/profile"

function saveResult(
	overrides: Partial<SaveAccountProfileResult> = {},
): SaveAccountProfileResult {
	return {
		applied: ["Company__c"],
		rejected: [],
		completeness: completeness(),
		...overrides,
	}
}

describe("saveAccountProfile", () => {
	it("posts the values map and returns the applied result", async () => {
		let body: unknown
		const result = saveResult()
		server.use(
			http.post(PROFILE_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(memberPortalEnvelope(result))
			}),
		)

		const values = { Company__c: "Analytical Engines", GARP_Directory_Opt_In__c: true }
		await expect(saveAccountProfile(values)).resolves.toEqual(result)
		expect(body).toEqual({ values })
	})

	it("treats rejected fields as a failure naming them", async () => {
		server.use(
			http.post(PROFILE_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						saveResult({ applied: [], rejected: ["Email", "Bogus__c"] }),
					),
				),
			),
		)

		await expect(saveAccountProfile({ Email: "x" })).rejects.toMatchObject({
			messages: ["These fields could not be saved: Email, Bogus__c."],
		})
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.post(PROFILE_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Profile service down"), {
					status: 500,
				}),
			),
		)

		const failure = saveAccountProfile({ Company__c: "x" })
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Profile service down"],
		})
	})
})
