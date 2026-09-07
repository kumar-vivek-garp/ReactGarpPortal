import { HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { saveEppOptIn, toEppExamType } from "@/api/programs/epp-opt-in"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { eppOptInResult } from "@/testing/factories/programs"
import { eppOptInHandler } from "@/testing/msw/handlers/programs"
import { server } from "@/testing/msw/server"

describe("toEppExamType", () => {
	it("maps the programmes Apex can stamp, folding the rai alias", () => {
		expect(toEppExamType("FRM")).toBe("frm")
		expect(toEppExamType("RiskAI")).toBe("riskai")
		expect(toEppExamType("rai")).toBe("riskai")
		expect(toEppExamType("raij")).toBe("raij")
	})

	it("has nothing for a programme with no exam attempt to stamp", () => {
		expect(toEppExamType("ERP")).toBeNull()
		expect(toEppExamType("frr")).toBeNull()
		expect(toEppExamType(null)).toBeNull()
	})
})

describe("saveEppOptIn", () => {
	it("posts the answer against the exam type and unwraps the result", async () => {
		const { spy, handler } = eppOptInHandler()
		server.use(handler)

		await expect(
			saveEppOptIn({ examType: "frm", optIn: true }),
		).resolves.toEqual(eppOptInResult())
		expect(spy.hits).toBe(1)
		expect(spy.bodies[0]).toEqual({ examType: "frm", optIn: true })
	})

	it("throws the inner refusal — no sitting to stamp — even on an HTTP 200", async () => {
		const { handler } = eppOptInHandler(() =>
			HttpResponse.json(
				memberPortalEnvelope(
					eppOptInResult({
						statusMessage: "Exam Attempt not found",
						statusCode: 401,
						optedIn: null,
					}),
				),
			),
		)
		server.use(handler)

		await expect(
			saveEppOptIn({ examType: "scr", optIn: false }),
		).rejects.toMatchObject({
			messages: ["Exam Attempt not found"],
			status: 401,
		})
	})
})
