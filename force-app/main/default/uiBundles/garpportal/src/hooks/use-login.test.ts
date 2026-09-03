import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { getLoginErrorMessages, useLogin } from "@/hooks/use-login"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

const LOGIN_PATH = "/services/apexrest/auth/login"

describe("useLogin", () => {
	it("resolves the redirect the caller must hard-navigate to", async () => {
		server.use(
			http.post(LOGIN_PATH, () =>
				HttpResponse.json({ success: true, redirectUrl: "/s/dashboard" }),
			),
		)

		const { result } = renderHookWithProviders(() => useLogin())
		act(() => {
			result.current.mutate({
				email: "Grace@GARP.org",
				password: "pw",
				startUrl: "/dashboard",
			})
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(result.current.data).toEqual({
			success: true,
			redirectUrl: "/s/dashboard",
		})
	})
})

describe("getLoginErrorMessages", () => {
	it("prefers the AppError's own server messages", () => {
		expect(
			getLoginErrorMessages(
				new AppError({ messages: ["Bad password", "Try again"] }),
			),
		).toEqual(["Bad password", "Try again"])
	})

	it("falls back to a plain Error's message", () => {
		expect(getLoginErrorMessages(new Error("boom"))).toEqual(["boom"])
	})

	it("keeps a generic sentence for anything unrecognisable", () => {
		expect(getLoginErrorMessages("nope")).toEqual([
			"Login failed. Please try again.",
		])
		expect(getLoginErrorMessages(new Error(""))).toEqual([
			"Login failed. Please try again.",
		])
	})
})
