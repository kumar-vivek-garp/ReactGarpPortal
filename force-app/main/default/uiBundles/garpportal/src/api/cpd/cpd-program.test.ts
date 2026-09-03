import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchCpdProgram } from "@/api/cpd/cpd-program"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const CPD_PROGRAM_PATH = "/services/apexrest/memberportal/cpdProgram"

describe("fetchCpdProgram", () => {
	it("returns the cycles with the opening cycle name", async () => {
		server.use(
			http.get(CPD_PROGRAM_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						currentCycle: "2025-2026",
						cycles: [{ cycleName: "2025-2026" }],
					}),
				),
			),
		)

		await expect(fetchCpdProgram()).resolves.toEqual({
			currentCycle: "2025-2026",
			cycles: [{ cycleName: "2025-2026" }],
		})
	})

	it("maps a member with no CPE contract to the empty state, not an error", async () => {
		server.use(
			http.get(CPD_PROGRAM_PATH, () =>
				HttpResponse.json(memberPortalEnvelope({})),
			),
		)

		await expect(fetchCpdProgram()).resolves.toEqual({
			currentCycle: null,
			cycles: [],
		})
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.get(CPD_PROGRAM_PATH, () =>
				HttpResponse.json(memberPortalError(500, "CPD backend down"), {
					status: 500,
				}),
			),
		)

		await expect(fetchCpdProgram()).rejects.toMatchObject({
			messages: ["CPD backend down"],
		})
	})
})
