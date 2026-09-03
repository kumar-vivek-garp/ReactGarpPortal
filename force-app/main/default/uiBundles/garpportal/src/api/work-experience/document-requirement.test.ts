import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchCvDocumentRequirement } from "@/api/work-experience/document-requirement"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const REQUIREMENT_PATH = "/services/apexrest/memberportal/cvDocumentRequirement"

function serveRequirement(payload: Record<string, unknown>) {
	const bodies: unknown[] = []
	const handler = http.post(REQUIREMENT_PATH, async ({ request }) => {
		bodies.push(await request.json())
		return HttpResponse.json(memberPortalEnvelope(payload))
	})
	return { bodies, handler }
}

describe("fetchCvDocumentRequirement", () => {
	it("sends all five formData keys, nulling the unset ones, and no id", async () => {
		const org = serveRequirement({
			required: true,
			hasAttachments: false,
			isValidExperience: true,
			validationMessage: null,
			documentMessage: "Please attach an employment letter.",
			requiredDocuments: ["Employment letter"],
		})
		server.use(org.handler)

		const result = await fetchCvDocumentRequirement({
			jobFunction: "Risk Manager",
			company: "Analytical Engines",
		})

		expect(org.bodies[0]).toEqual({
			formData: {
				jobFunction: "Risk Manager",
				riskSpecialty: null,
				educationalRole: null,
				jobType: null,
				company: "Analytical Engines",
			},
		})
		expect(result).toMatchObject({
			required: true,
			requiredDocuments: ["Employment letter"],
		})
	})

	it("includes institutionType only when it has content", async () => {
		const org = serveRequirement({ required: false })
		server.use(org.handler)

		await fetchCvDocumentRequirement({}, "University")
		await fetchCvDocumentRequirement({}, "   ")

		expect(org.bodies[0]).toMatchObject({ institutionType: "University" })
		expect(org.bodies[1]).not.toHaveProperty("institutionType")
	})

	it("coerces required to a strict boolean and unguarded lists to null", async () => {
		const org = serveRequirement({
			required: "yes",
			requiredDocuments: "Employment letter",
		})
		server.use(org.handler)

		await expect(fetchCvDocumentRequirement({})).resolves.toMatchObject({
			required: false,
			requiredDocuments: null,
		})
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.post(REQUIREMENT_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Requirement check down"), {
					status: 500,
				}),
			),
		)

		await expect(fetchCvDocumentRequirement({})).rejects.toMatchObject({
			messages: ["Requirement check down"],
		})
	})
})
