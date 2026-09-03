import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchProgramDetail } from "@/api/programs/program-detail"
import { programDetailQueryOptions } from "@/api/programs/query-options"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const PROGRAM_DETAIL_PATH = "/services/apexrest/memberportal/programDetail"

describe("fetchProgramDetail", () => {
	it("refuses a blank program type before it reaches the network", async () => {
		await expect(fetchProgramDetail("  ")).rejects.toMatchObject({
			messages: ["A program type is required."],
			status: 400,
		})
	})

	it("sends the slug as a query param and unwraps the detail", async () => {
		let search: URLSearchParams | undefined
		const view = {
			statusMessage: null,
			statusCode: 200,
			programsDetailInfo: null,
		}
		server.use(
			http.get(PROGRAM_DETAIL_PATH, ({ request }) => {
				search = new URL(request.url).searchParams
				return HttpResponse.json(memberPortalEnvelope(view))
			}),
		)

		await expect(fetchProgramDetail(" frm ")).resolves.toEqual(view)
		expect(search?.get("programType")).toBe("frm")
	})

	it("throws the inner refusal even on an HTTP 200", async () => {
		server.use(
			http.get(PROGRAM_DETAIL_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "Program not held",
						statusCode: 404,
						programsDetailInfo: null,
					}),
				),
			),
		)

		await expect(fetchProgramDetail("frm")).rejects.toMatchObject({
			messages: ["Program not held"],
			status: 404,
		})
	})

	it("surfaces the server's error message on a transport failure", async () => {
		server.use(
			http.get(PROGRAM_DETAIL_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Detail service down"), {
					status: 500,
				}),
			),
		)

		await expect(fetchProgramDetail("frm")).rejects.toMatchObject({
			messages: ["Detail service down"],
		})
	})
})

describe("programDetailQueryOptions", () => {
	it("keys by the lowercased slug and disables itself when blank", () => {
		const options = programDetailQueryOptions(" FRM ")
		expect(options.queryKey).toEqual(["programs", "detail", "frm"])
		expect(options.enabled).toBe(true)
		expect(programDetailQueryOptions("   ").enabled).toBe(false)
	})
})
