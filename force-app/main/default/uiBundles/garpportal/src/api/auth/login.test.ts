import { http, HttpResponse } from "msw"
import { beforeEach, describe, expect, it } from "vitest"

import { login } from "@/api/auth/login"
import { AppError, AuthApiError } from "@/api/client"
import { server } from "@/testing/msw/server"

const LOGIN_PATH = "/services/apexrest/auth/login"

const credentials = {
	email: "  Ada@Example.COM ",
	password: "hunter2",
	startUrl: "/dashboard",
}

beforeEach(() => {
	sessionStorage.clear()
})

describe("login", () => {
	it("normalizes the email and returns the redirect on success", async () => {
		sessionStorage.setItem("garpportal:local-logged-out", "1")
		let body: unknown
		server.use(
			http.post(LOGIN_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json({
					success: true,
					redirectUrl: "/s/portal?sid=abc",
				})
			}),
		)

		await expect(login(credentials)).resolves.toEqual({
			success: true,
			redirectUrl: "/s/portal?sid=abc",
		})
		expect(body).toEqual({
			email: "ada@example.com",
			password: "hunter2",
			startUrl: "/dashboard",
		})
		// Success clears the local Sign Out override.
		expect(sessionStorage.getItem("garpportal:local-logged-out")).toBeNull()
	})

	it("throws the server's own errors from a refused HTTP 200", async () => {
		server.use(
			http.post(LOGIN_PATH, () =>
				HttpResponse.json({ success: false, errors: ["Wrong email or password"] }),
			),
		)

		const failure = login(credentials)
		await expect(failure).rejects.toBeInstanceOf(AuthApiError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Wrong email or password"],
			status: 200,
		})
	})

	it("throws AppError with server messages for a non-2xx failure", async () => {
		server.use(
			http.post(LOGIN_PATH, () =>
				HttpResponse.json(
					{ errors: ["Site.login is unavailable"] },
					{ status: 500 },
				),
			),
		)

		const failure = login(credentials)
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Site.login is unavailable"],
			status: 500,
		})
	})

	it("falls back to a readable message when the body says nothing", async () => {
		server.use(http.post(LOGIN_PATH, () => HttpResponse.json({})))

		await expect(login(credentials)).rejects.toMatchObject({
			messages: ["Login failed. Please try again."],
		})
	})
})
