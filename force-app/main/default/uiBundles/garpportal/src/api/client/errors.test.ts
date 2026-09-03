import { describe, expect, it } from "vitest"

import { AppError, AuthApiError } from "@/api/client/errors"

describe("AppError", () => {
	it("uses the first message as the Error message", () => {
		const error = new AppError({ messages: ["First", "Second"], status: 401 })
		expect(error.message).toBe("First")
		expect(error.messages).toEqual(["First", "Second"])
		expect(error.status).toBe(401)
		expect(error.name).toBe("AppError")
	})

	it("falls back to a readable message when given none", () => {
		const error = new AppError({ messages: [] })
		expect(error.message).toBe("Request failed")
		expect(error.messages).toEqual(["Request failed"])
		expect(error.status).toBe(0)
	})

	it("keeps the deprecated errors alias in step with messages", () => {
		const error = new AppError({ messages: ["Bad credentials"] })
		expect(error.errors).toEqual(["Bad credentials"])
	})

	it("carries code and cause through", () => {
		const cause = new Error("boom")
		const error = new AppError({ messages: ["x"], code: "E1", cause })
		expect(error.code).toBe("E1")
		expect(error.cause).toBe(cause)
	})
})

describe("AppError.fromUnknown", () => {
	it("passes an existing AppError through unchanged", () => {
		const original = new AppError({ messages: ["kept"], status: 502 })
		expect(AppError.fromUnknown(original)).toBe(original)
	})

	it("wraps a plain Error, keeping its message as the cause trail", () => {
		const cause = new Error("network down")
		const wrapped = AppError.fromUnknown(cause)
		expect(wrapped).toBeInstanceOf(AppError)
		expect(wrapped.messages).toEqual(["network down"])
		expect(wrapped.cause).toBe(cause)
	})

	it("maps anything else to the fallback message", () => {
		expect(AppError.fromUnknown("string").messages).toEqual([
			"Something went wrong. Please try again.",
		])
		expect(AppError.fromUnknown(undefined, "Custom fallback").messages).toEqual([
			"Custom fallback",
		])
		// An Error with an empty message is as useless as no Error at all.
		expect(AppError.fromUnknown(new Error("")).messages).toEqual([
			"Something went wrong. Please try again.",
		])
	})
})

describe("AuthApiError", () => {
	it("is an AppError with the legacy name and a 400 default", () => {
		const error = new AuthApiError(["Wrong password"])
		expect(error).toBeInstanceOf(AppError)
		expect(error.name).toBe("AuthApiError")
		expect(error.status).toBe(400)
		expect(error.messages).toEqual(["Wrong password"])
		expect(new AuthApiError(["x"], 401).status).toBe(401)
	})
})
