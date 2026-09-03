import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { saveCvAddress } from "@/api/work-experience/save-address"
import type { CvAddressInput } from "@/api/work-experience/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const CV_ADDRESS_PATH = "/services/apexrest/memberportal/cvAddress"

const mailingAddress: CvAddressInput = {
	company: "GARP",
	street: "1 Main St",
	city: "Hoboken",
	state: "NJ",
	postalCode: "07030",
	country: "United States",
	phone: "5550100",
}

describe("saveCvAddress", () => {
	it("refuses a payload with no mailing address before the network", async () => {
		await expect(
			saveCvAddress({ mailingAddress: undefined as unknown as CvAddressInput }),
		).rejects.toMatchObject({
			messages: ["A delivery address is required."],
			status: 400,
		})
	})

	it("posts the raw payload, omitting the OSTA block when absent", async () => {
		let body: unknown
		server.use(
			http.post(CV_ADDRESS_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "Saved",
						statusCode: 200,
						newExperienceId: null,
					}),
				)
			}),
		)

		await expect(saveCvAddress({ mailingAddress })).resolves.toMatchObject({
			statusCode: 200,
		})
		expect(body).toEqual({ mailingAddress })
	})

	it("sends the OSTA block and recipient when present", async () => {
		let body: Record<string, unknown> = {}
		const ostaAddress: CvAddressInput = {
			...mailingAddress,
			country: "China",
			district: "Haidian",
			town: "Beijing",
		}
		server.use(
			http.post(CV_ADDRESS_PATH, async ({ request }) => {
				body = (await request.json()) as Record<string, unknown>
				return HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						newExperienceId: null,
					}),
				)
			}),
		)

		await saveCvAddress({ mailingAddress, ostaAddress, ostaRecipient: "李雷" })
		expect(body.ostaAddress).toEqual(ostaAddress)
		expect(body.ostaRecipient).toBe("李雷")
	})

	it("falls back to readable wording for a silent refusal", async () => {
		server.use(
			http.post(CV_ADDRESS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: " ",
						statusCode: 500,
						newExperienceId: null,
					}),
				),
			),
		)

		await expect(saveCvAddress({ mailingAddress })).rejects.toMatchObject({
			messages: ["Your address could not be saved."],
			status: 500,
		})
	})

	it("surfaces the server's error message on a transport failure", async () => {
		server.use(
			http.post(CV_ADDRESS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Address service down"), {
					status: 500,
				}),
			),
		)

		await expect(saveCvAddress({ mailingAddress })).rejects.toMatchObject({
			messages: ["Address service down"],
		})
	})
})
