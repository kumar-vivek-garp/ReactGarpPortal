import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchAccountOptions } from "@/api/account/options"
import { accountOptionsView } from "@/testing/factories/account-options"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { ACCOUNT_OPTIONS_PATH } from "@/testing/msw/handlers/account"
import { server } from "@/testing/msw/server"

describe("fetchAccountOptions", () => {
	it("passes the address-form lists through untouched", async () => {
		const options = accountOptionsView()
		server.use(
			http.get(ACCOUNT_OPTIONS_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(options)),
			),
		)

		await expect(fetchAccountOptions()).resolves.toEqual(options)
	})

	it("defaults every list when the payload omits it", async () => {
		server.use(
			http.get(ACCOUNT_OPTIONS_PATH, () =>
				HttpResponse.json(memberPortalEnvelope({})),
			),
		)

		await expect(fetchAccountOptions()).resolves.toEqual({
			picklists: {},
			chapters: [],
			mobilePhoneLocations: [],
			countries: [],
			schools: [],
			organizations: [],
			workingYears: [],
			graduationYears: [],
		})
	})
})
