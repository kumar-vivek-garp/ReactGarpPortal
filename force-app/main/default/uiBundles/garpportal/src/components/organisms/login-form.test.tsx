import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { toast } from "sonner"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

// The app's real QueryClient: its MutationCache owns the toast policy.
import { queryClient as appQueryClient } from "@/api/client"
import { Route } from "@/pages/_authLayout/Login/index"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

const LOGIN_PATH = "/services/apexrest/auth/login"

/**
 * Mounted through the real /Login route: the form reads its search params via
 * `useSearch({ from: "/_authLayout/Login/" })`, so it needs that exact route id.
 */
const mount = (entry = "/Login") =>
	renderFileRoute(Route, {
		id: "/_authLayout/Login/",
		path: "/Login/",
		initialEntries: [entry],
		user: null,
	})

type LoginBody = { email: string; password: string; startUrl: string }

function serveLogin(
	respond: () => Response = () =>
		HttpResponse.json({ success: true, redirectUrl: "/portal/s/dashboard" }),
) {
	const wire = { bodies: [] as LoginBody[] }
	server.use(
		http.post(LOGIN_PATH, async ({ request }) => {
			wire.bodies.push((await request.json()) as LoginBody)
			return respond()
		}),
	)
	return wire
}

const emailField = () => screen.getByLabelText("Email Address")
const passwordField = () => screen.getByLabelText("Password")
const submit = () => screen.getByRole("button", { name: /Sign In/i })

beforeEach(() => {
	vi.clearAllMocks()
})
afterEach(() => {
	appQueryClient.clear()
})

describe("LoginForm — validation", () => {
	it("names both missing fields and sends nothing", async () => {
		const wire = serveLogin()
		const user = userEvent.setup()
		await mount()

		await user.click(submit())

		expect(
			await screen.findByText("Email Address is required"),
		).toBeInTheDocument()
		expect(screen.getByText("Password is required")).toBeInTheDocument()
		expect(screen.getAllByRole("alert")).toHaveLength(2)
		expect(emailField()).toHaveAttribute("aria-invalid", "true")
		expect(wire.bodies).toHaveLength(0)
	})

	it("rejects a malformed email before the wire", async () => {
		const wire = serveLogin()
		const user = userEvent.setup()
		await mount()

		await user.type(emailField(), "not-an-email")
		await user.type(passwordField(), "hunter2")
		await user.click(submit())

		expect(
			await screen.findByText("Please enter a valid email address"),
		).toBeInTheDocument()
		expect(wire.bodies).toHaveLength(0)
	})
})

describe("LoginForm — the password reveal", () => {
	it("toggles between masked and visible without losing the value", async () => {
		const user = userEvent.setup()
		await mount()

		await user.type(passwordField(), "hunter2")
		expect(passwordField()).toHaveAttribute("type", "password")

		const reveal = screen.getByRole("button", { name: "Show password" })
		expect(reveal).toHaveAttribute("aria-pressed", "false")
		await user.click(reveal)

		expect(passwordField()).toHaveAttribute("type", "text")
		expect(passwordField()).toHaveValue("hunter2")
		await user.click(screen.getByRole("button", { name: "Hide password" }))
		expect(passwordField()).toHaveAttribute("type", "password")
	})
})

describe("LoginForm — submitting", () => {
	it("posts trimmed, lowercased credentials with the default start URL", async () => {
		const wire = serveLogin()
		const user = userEvent.setup()
		await mount()

		await user.type(emailField(), "  Ada@Example.COM  ")
		await user.type(passwordField(), "hunter2")
		await user.click(submit())

		await waitFor(() => expect(wire.bodies).toHaveLength(1))
		expect(wire.bodies[0]).toEqual({
			email: "ada@example.com",
			password: "hunter2",
			startUrl: "/dashboard",
		})
		// window.location.replace(redirectUrl) runs here but jsdom's Location is
		// [LegacyUnforgeable] — unassertable, same as use-pay-order's hand-off.
	})

	it("carries a safe ?startUrl= through to the login request", async () => {
		const wire = serveLogin()
		const user = userEvent.setup()
		await mount("/Login?startUrl=/programs")

		await user.type(emailField(), "ada@example.com")
		await user.type(passwordField(), "hunter2")
		await user.click(submit())

		await waitFor(() => expect(wire.bodies).toHaveLength(1))
		expect(wire.bodies[0].startUrl).toBe("/programs")
	})

	it("falls back to /dashboard when the ?startUrl= is not safe", async () => {
		const wire = serveLogin()
		const user = userEvent.setup()
		await mount("/Login?startUrl=https://evil.example.com/phish")

		await user.type(emailField(), "ada@example.com")
		await user.type(passwordField(), "hunter2")
		await user.click(submit())

		await waitFor(() => expect(wire.bodies).toHaveLength(1))
		expect(wire.bodies[0].startUrl).toBe("/dashboard")
	})

	it("toasts the refusal and unlocks the form for another attempt", async () => {
		serveLogin(() =>
			HttpResponse.json(
				{ success: false, errors: ["Your login attempt has failed."] },
				{ status: 500 },
			),
		)
		const user = userEvent.setup()
		// The toast fires from the app QueryClient's MutationCache, so this one
		// case mounts on the real client rather than the silent test client.
		await renderFileRoute(Route, {
			id: "/_authLayout/Login/",
			path: "/Login/",
			initialEntries: ["/Login"],
			queryClient: appQueryClient,
		})

		await user.type(emailField(), "ada@example.com")
		await user.type(passwordField(), "wrong")
		await user.click(submit())

		// Failure surfaces through the mutation-cache toast, titled by the hook.
		await waitFor(() => expect(vi.mocked(toast.error)).toHaveBeenCalled())
		expect(vi.mocked(toast.error).mock.calls[0][0]).toBe("Sign in failed")
		expect(submit()).toBeEnabled()
		expect(emailField()).toHaveValue("ada@example.com")
	})
})
