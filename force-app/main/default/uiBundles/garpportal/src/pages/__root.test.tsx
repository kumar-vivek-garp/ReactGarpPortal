import { QueryClientProvider } from "@tanstack/react-query"
import {
	RouterProvider,
	createMemoryHistory,
	createRoute,
	createRouter,
} from "@tanstack/react-router"
import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { createTestQueryClient } from "@/testing/query-client"

import { Route } from "./__root"

/**
 * The root route is mounted directly rather than through the file-route
 * harness — it IS the root, so it gets a child instead of a parent.
 */
async function mountRoot(entry: string) {
	const client = createTestQueryClient(null)
	const child = createRoute({
		getParentRoute: () => Route,
		path: "/",
		component: () => <p>root child content</p>,
	})
	const router = createRouter({
		routeTree: Route.addChildren([child]),
		history: createMemoryHistory({ initialEntries: [entry] }),
		context: { queryClient: client },
	})
	await router.load()
	return render(
		<QueryClientProvider client={client}>
			<RouterProvider router={router as never} />
		</QueryClientProvider>,
	)
}

describe("__root", () => {
	it("renders the matched child through its outlet", async () => {
		await mountRoot("/")

		expect(screen.getByText("root child content")).toBeInTheDocument()
	})

	it("hands unknown URLs to the session-aware 404 page", async () => {
		await mountRoot("/no-such-page")

		expect(
			await screen.findByRole("heading", { name: "Page not found" }),
		).toBeInTheDocument()
	})
})
