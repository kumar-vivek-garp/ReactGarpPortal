import { StrictMode, type ReactElement } from "react"
import type { QueryClient } from "@tanstack/react-query"
import { QueryClientProvider } from "@tanstack/react-query"
import {
	RouterProvider,
	createMemoryHistory,
	createRootRoute,
	createRoute,
	createRouter,
} from "@tanstack/react-router"
import { render } from "@testing-library/react"

import type { CurrentUser } from "@/api/auth/current-user"
import { createTestQueryClient } from "@/testing/query-client"

type RouterRenderOptions = {
	/** Route path the UI mounts at (default "/"); params use `$name` segments. */
	path?: string
	/** History entries — must match `path`; default `[path]`. */
	initialEntries?: string[]
	/** Session seeded into the query cache; `null` = guest, omit = not fetched. */
	user?: CurrentUser | null
	queryClient?: QueryClient
	strict?: boolean
}

/**
 * Mounts a component inside a minimal synthetic router — real `Link`,
 * `useLocation`, `useRouterState` and navigation — WITHOUT the app's
 * `routeTree.gen.ts`, which would drag every page into every test.
 *
 * Navigations away from `path` land on a null-rendering catch-all, so
 * assert destinations via `router.state.location`, not rendered output.
 *
 * Async because the router resolves its matches asynchronously — the harness
 * pre-loads them so the first render already shows the UI: `await` it.
 */
export async function renderWithRouterProviders(
	ui: ReactElement,
	options: RouterRenderOptions = {},
) {
	const {
		path = "/",
		initialEntries = [path],
		user,
		queryClient,
		strict = true,
	} = options
	const client = queryClient ?? createTestQueryClient(user)

	const rootRoute = createRootRoute({ notFoundComponent: () => null })
	const uiRoute = createRoute({
		getParentRoute: () => rootRoute,
		path,
		component: () => ui,
		validateSearch: (search: Record<string, unknown>) => search,
	})
	const catchAll = createRoute({
		getParentRoute: () => rootRoute,
		path: "$",
		component: () => null,
	})
	const router = createRouter({
		routeTree: rootRoute.addChildren([uiRoute, catchAll]),
		history: createMemoryHistory({ initialEntries }),
		context: { queryClient: client } as never,
	})
	await router.load()

	const tree = (
		<QueryClientProvider client={client}>
			<RouterProvider router={router as never} />
		</QueryClientProvider>
	)

	return {
		router,
		queryClient: client,
		...render(strict ? <StrictMode>{tree}</StrictMode> : tree),
	}
}
