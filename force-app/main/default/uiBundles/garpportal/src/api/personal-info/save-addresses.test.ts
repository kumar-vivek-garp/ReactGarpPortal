import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { saveAddresses } from "@/api/personal-info/save-addresses"
import type { AddressSubmission } from "@/api/personal-info/types"
import { toAddressInput } from "@/api/personal-info/address-utils"
import { memberPortalError } from "@/testing/factories/envelope"
import { portalAddressFields } from "@/testing/factories/personal-info"
import {
	ADDRESSES_PATH,
	personalInfoWriteHandlers,
} from "@/testing/msw/handlers/personal-info"
import { server } from "@/testing/msw/server"

function submission(): AddressSubmission {
	return {
		mailingAddress: toAddressInput(portalAddressFields({ city: "Boston" })),
		billingAddress: toAddressInput(portalAddressFields()),
		isBillingAndMailingAddressSame: false,
	}
}

describe("saveAddresses", () => {
	it("posts the raw submission and resolves the result", async () => {
		const org = personalInfoWriteHandlers()
		server.use(...org.handlers)

		await expect(saveAddresses(submission())).resolves.toMatchObject({
			statusCode: 200,
			appliedBillingToMailing: false,
		})
		expect(org.addressesSpy.bodies[0]).toEqual(submission())
	})

	it("surfaces a partial-success 501 as the server's own message", async () => {
		server.use(
			...personalInfoWriteHandlers({
				addressesRespond: () => ({
					statusMessage: "Contact updated; Account billing address failed.",
					statusCode: 501,
					appliedBillingToMailing: false,
				}),
			}).handlers,
		)

		const failure = saveAddresses(submission())
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Contact updated; Account billing address failed."],
			status: 501,
		})
	})

	it("surfaces a router-level refusal", async () => {
		server.use(
			http.post(ADDRESSES_PATH, () =>
				HttpResponse.json(memberPortalError(403, "No member record."), {
					status: 403,
				}),
			),
		)

		await expect(saveAddresses(submission())).rejects.toMatchObject({
			messages: ["No member record."],
		})
	})
})
