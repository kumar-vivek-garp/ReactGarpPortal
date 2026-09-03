import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { Route } from "./route"

describe("_publicFormLayout", () => {
	it("wraps its outlet in the public shell's chrome", async () => {
		await renderFileRoute(Route, {
			id: "/_publicFormLayout",
			path: "/",
			initialEntries: ["/"],
			user: null,
		})

		expect(screen.getByRole("banner")).toBeInTheDocument()
		expect(screen.getByRole("main")).toBeInTheDocument()
		expect(screen.getByRole("contentinfo")).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: /Sign In/ }),
		).toBeInTheDocument()
	})
})
