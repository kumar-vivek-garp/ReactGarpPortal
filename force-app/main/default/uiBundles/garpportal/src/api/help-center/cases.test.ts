import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { fetchCases } from "@/api/help-center/cases"
import { casesQueryOptions } from "@/api/help-center/query-options"
import type { CaseSummary } from "@/api/help-center/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const CASES_PATH = "/services/apexrest/memberportal/cases"

function caseSummary(overrides: Partial<CaseSummary> = {}): CaseSummary {
	return {
		id: "500xx1",
		caseNumber: "00001042",
		subject: "Exam voucher not applied",
		status: "New",
		createdDate: "2026-08-30T10:15:00.000Z",
		...overrides,
	}
}

describe("fetchCases", () => {
	it("returns the member's case list", async () => {
		const rows = [caseSummary(), caseSummary({ id: "500xx2", status: "Closed" })]
		server.use(
			http.get(CASES_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(rows)),
			),
		)

		await expect(fetchCases()).resolves.toEqual(rows)
	})

	it("treats a non-array payload as a failure, not as data", async () => {
		server.use(
			http.get(CASES_PATH, () =>
				HttpResponse.json(memberPortalEnvelope({ not: "a list" })),
			),
		)

		await expect(fetchCases()).rejects.toMatchObject({
			messages: ["No request list was returned."],
		})
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.get(CASES_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Case service down"), {
					status: 500,
				}),
			),
		)

		const failure = fetchCases()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Case service down"],
		})
	})
})

describe("casesQueryOptions", () => {
	it("keys the case list and opts into toasting failures", () => {
		expect(casesQueryOptions.queryKey).toEqual(["help-center", "cases"])
		expect(casesQueryOptions.meta).toMatchObject({ toastError: true })
	})
})
