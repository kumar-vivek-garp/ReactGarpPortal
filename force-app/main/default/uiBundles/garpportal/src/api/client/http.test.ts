import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client/errors"
import { normalizeHttpResponse, readJsonBody } from "@/api/client/http"

function jsonResponse(body: unknown, status = 200): Response {
	return new Response(JSON.stringify(body), {
		status,
		headers: { "content-type": "application/json" },
	})
}

describe("readJsonBody", () => {
	it("parses a JSON body", async () => {
		await expect(readJsonBody(jsonResponse({ a: 1 }))).resolves.toEqual({ a: 1 })
	})

	it("consumes and discards a non-JSON body", async () => {
		const response = new Response("<html>error</html>", {
			status: 200,
			headers: { "content-type": "text/html" },
		})
		await expect(readJsonBody(response)).resolves.toBeNull()
		// The body was consumed either way — a second read must fail.
		expect(response.bodyUsed).toBe(true)
	})
})

describe("normalizeHttpResponse", () => {
	it("treats a missing response as unreachable, with the caller's wording", async () => {
		const result = await normalizeHttpResponse(undefined, {
			unreachableMessage: "Service is down.",
		})
		expect(result.ok).toBe(false)
		if (!result.ok) {
			expect(result.error).toBeInstanceOf(AppError)
			expect(result.error.messages).toEqual(["Service is down."])
			expect(result.status).toBe(0)
		}
	})

	it("returns ok with the parsed body and status", async () => {
		const result = await normalizeHttpResponse<{ a: number }>(
			jsonResponse({ a: 1 }, 201),
		)
		expect(result).toMatchObject({ ok: true, status: 201, data: { a: 1 } })
	})

	it("substitutes an empty object for an ok response with no JSON body", async () => {
		const response = new Response("done", {
			status: 200,
			headers: { "content-type": "text/plain" },
		})
		const result = await normalizeHttpResponse(response)
		expect(result).toMatchObject({ ok: true, data: {} })
	})

	it("prefers the Apex errors[] array, dropping blank entries", async () => {
		const result = await normalizeHttpResponse(
			jsonResponse({ errors: ["Bad email", "", "Bad password"] }, 400),
		)
		expect(result.ok).toBe(false)
		if (!result.ok) {
			expect(result.error.messages).toEqual(["Bad email", "Bad password"])
			expect(result.status).toBe(400)
			expect(result.body).toEqual({ errors: ["Bad email", "", "Bad password"] })
		}
	})

	it("falls back through message, then error, then errorMessage", async () => {
		const fromMessage = await normalizeHttpResponse(
			jsonResponse({ message: "From message" }, 500),
		)
		if (!fromMessage.ok) {
			expect(fromMessage.error.messages).toEqual(["From message"])
		}

		const fromError = await normalizeHttpResponse(
			jsonResponse({ error: "From legacy error" }, 500),
		)
		if (!fromError.ok) {
			expect(fromError.error.messages).toEqual(["From legacy error"])
		}

		const fromEnvelope = await normalizeHttpResponse(
			jsonResponse({ errorMessage: "From envelope" }, 500),
		)
		if (!fromEnvelope.ok) {
			expect(fromEnvelope.error.messages).toEqual(["From envelope"])
		}
	})

	it("uses the caller's fallback when the failure body says nothing", async () => {
		const result = await normalizeHttpResponse(jsonResponse({}, 503), {
			fallbackErrorMessage: "Custom fallback.",
		})
		expect(result.ok).toBe(false)
		if (!result.ok) {
			expect(result.error.messages).toEqual(["Custom fallback."])
			expect(result.status).toBe(503)
		}
	})
})
