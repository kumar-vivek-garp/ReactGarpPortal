import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchAccount } from "@/api/account/account"
import { AppError } from "@/api/client"
import { accountView } from "@/testing/factories/account"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const ACCOUNT_PATH = "/services/apexrest/memberportal/account"

describe("fetchAccount", () => {
	it("unwraps the composed My Account view", async () => {
		const view = accountView({ identity: { garpId: "G-100" } })
		server.use(
			http.get(ACCOUNT_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(view)),
			),
		)

		await expect(fetchAccount()).resolves.toEqual(view)
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.get(ACCOUNT_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Account backend down"), {
					status: 500,
				}),
			),
		)

		const failure = fetchAccount()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Account backend down"],
		})
	})

	it("throws when a healthy envelope carries no data", async () => {
		server.use(
			http.get(ACCOUNT_PATH, () =>
				HttpResponse.json({
					status: "Success",
					statusCode: 200,
					errorMessage: null,
				}),
			),
		)

		await expect(fetchAccount()).rejects.toMatchObject({
			messages: ["No account data was returned."],
		})
	})
})

