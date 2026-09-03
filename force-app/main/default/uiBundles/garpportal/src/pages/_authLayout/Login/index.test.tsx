import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { Route } from "./index"

const mount = (entry: string) =>
	renderFileRoute(Route, {
		id: "/_authLayout/Login/",
		path: "/Login/",
		initialEntries: [entry],
		user: null,
	})

describe("/Login page", () => {
	it("renders the sign-in form", async () => {
		await mount("/Login")

		expect(screen.getAllByText("Sign In").length).toBeGreaterThan(0)
		expect(screen.getByLabelText("Email Address")).toBeInTheDocument()
		expect(screen.getByLabelText(/Password/)).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: /sign in/i }),
		).toBeInTheDocument()
	})

	it("accepts a startURL search param without crashing the schema", async () => {
		await mount("/Login?startURL=/dashboard")

		expect(screen.getByLabelText("Email Address")).toBeInTheDocument()
	})
})
