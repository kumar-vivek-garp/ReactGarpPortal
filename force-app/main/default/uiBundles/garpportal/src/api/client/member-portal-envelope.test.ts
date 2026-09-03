import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client/errors"
import {
	assertMemberPortalEnvelopeOk,
	isMemberPortalEnvelopeOk,
	memberPortalRefusalPayload,
	unwrapMemberPortalEnvelope,
} from "@/api/client/member-portal-envelope"
import { apiFail, apiOk } from "@/api/client/result"

const fail = (body: unknown, status = 401) =>
	apiFail(new AppError({ messages: ["x"], status }), status, body)

describe("memberPortalRefusalPayload", () => {
	it("returns null for a success result — nothing was refused", () => {
		expect(memberPortalRefusalPayload(apiOk({ any: 1 }))).toBeNull()
	})

	it("returns null when the failure body is not an envelope", () => {
		expect(memberPortalRefusalPayload(fail(undefined))).toBeNull()
		expect(memberPortalRefusalPayload(fail("plain text"))).toBeNull()
		expect(
			memberPortalRefusalPayload(fail({ statusCode: "401", data: { a: 1 } })),
		).toBeNull()
	})

	it("returns null for the empty payloads that mean a dead session", () => {
		expect(memberPortalRefusalPayload(fail({ statusCode: 401 }))).toBeNull()
		expect(
			memberPortalRefusalPayload(fail({ statusCode: 401, data: {} })),
		).toBeNull()
		expect(
			memberPortalRefusalPayload(fail({ statusCode: 401, data: [] })),
		).toBeNull()
	})

	it("returns the payload when the refusal describes itself", () => {
		const payload = { reason: "CPD Contract not found" }
		expect(
			memberPortalRefusalPayload(fail({ statusCode: 401, data: payload })),
		).toEqual(payload)
	})
})

describe("isMemberPortalEnvelopeOk", () => {
	it("requires a 200 and no error message", () => {
		expect(
			isMemberPortalEnvelopeOk({ status: "Success", statusCode: 200, errorMessage: null }),
		).toBe(true)
		expect(
			isMemberPortalEnvelopeOk({ status: "Error", statusCode: 500, errorMessage: null }),
		).toBe(false)
		expect(
			isMemberPortalEnvelopeOk({ status: "Error", statusCode: 200, errorMessage: "bad" }),
		).toBe(false)
	})
})

describe("assertMemberPortalEnvelopeOk", () => {
	it("does nothing for a healthy envelope", () => {
		expect(() =>
			assertMemberPortalEnvelopeOk({
				status: "Success",
				statusCode: 200,
				errorMessage: null,
			}),
		).not.toThrow()
	})

	it("prefers the server's message, then the caller's, then a default", () => {
		expect(() =>
			assertMemberPortalEnvelopeOk(
				{ status: "Error", statusCode: 500, errorMessage: "  Server said no  " },
				{ fallbackErrorMessage: "Caller fallback" },
			),
		).toThrow("Server said no")

		expect(() =>
			assertMemberPortalEnvelopeOk(
				{ status: "Error", statusCode: 500, errorMessage: "   " },
				{ fallbackErrorMessage: "Caller fallback" },
			),
		).toThrow("Caller fallback")

		expect(() =>
			assertMemberPortalEnvelopeOk({
				status: "Error",
				statusCode: 500,
				errorMessage: null,
			}),
		).toThrow("An unexpected error occurred. Please try again.")
	})

	it("takes the status from the envelope, falling back to the option", () => {
		try {
			assertMemberPortalEnvelopeOk(
				{ status: "Error", statusCode: 0, errorMessage: "x" },
				{ status: 502 },
			)
			expect.unreachable()
		} catch (error) {
			expect((error as AppError).status).toBe(502)
		}
	})
})

describe("unwrapMemberPortalEnvelope", () => {
	it("returns the data of a healthy envelope", () => {
		expect(
			unwrapMemberPortalEnvelope({
				status: "Success",
				statusCode: 200,
				errorMessage: null,
				data: { hello: true },
			}),
		).toEqual({ hello: true })
	})

	it("throws for missing data, with the caller's wording when given", () => {
		const healthy = {
			status: "Success",
			statusCode: 200,
			errorMessage: null,
		}
		expect(() => unwrapMemberPortalEnvelope(healthy)).toThrow(
			"No data was returned.",
		)
		expect(() =>
			unwrapMemberPortalEnvelope(healthy, { missingDataMessage: "Nothing came back." }),
		).toThrow("Nothing came back.")
	})
})
