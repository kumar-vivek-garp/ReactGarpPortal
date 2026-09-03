import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchCpdActivityTypes } from "@/api/cpd/activity-types"
import type { CpdActivityFieldInfo } from "@/api/cpd/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const TYPES_PATH = "/services/apexrest/memberportal/cpdActivityTypes"

const webcast: CpdActivityFieldInfo = {
	id: "a0Txx1",
	name: "Webcast",
	organizationLabel: "Organization",
	providerLabel: "Provider",
	publicationLabel: null,
	titleLabel: "Webcast title",
	contactEmailLabel: null,
}

describe("fetchCpdActivityTypes", () => {
	it("returns the field-info rows for the Add Credits form", async () => {
		server.use(
			http.get(TYPES_PATH, () =>
				HttpResponse.json(memberPortalEnvelope([webcast])),
			),
		)

		await expect(fetchCpdActivityTypes()).resolves.toEqual([webcast])
	})

	it("degrades a non-array payload to an empty list", async () => {
		server.use(
			http.get(TYPES_PATH, () =>
				HttpResponse.json(memberPortalEnvelope({ nope: true })),
			),
		)

		await expect(fetchCpdActivityTypes()).resolves.toEqual([])
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.get(TYPES_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Types unavailable"), {
					status: 500,
				}),
			),
		)

		await expect(fetchCpdActivityTypes()).rejects.toMatchObject({
			messages: ["Types unavailable"],
		})
	})
})
