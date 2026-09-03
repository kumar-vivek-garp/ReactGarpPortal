import { StrictMode } from "react"
import type { QueryClient } from "@tanstack/react-query"
import { QueryClientProvider } from "@tanstack/react-query"
import {
	RouterProvider,
	createMemoryHistory,
	createRootRouteWithContext,
	createRouter,
	type AnyRoute,
} from "@tanstack/react-router"
import { render } from "@testing-library/react"

import type { CurrentUser } from "@/api/auth/current-user"
import { createTestQueryClient } from "@/testing/query-client"

/**
 * The slice of a `createFileRoute` route the harness re-wires — the same
 * `update({ id, path, getParentRoute })` call `routeTree.gen.ts` makes when
 * it assembles the real tree.
 */
type UpdatableFileRoute = {
	update: (options: {
		id: string
		path: string
		getParentRoute: () => AnyRoute
	}) => AnyRoute
}

type FileRouteRenderOptions = {
	/**
	 * The exact string the page passed to `createFileRoute` — preserved as the
	 * route id so `Route.useSearch()`/`useParams()` and any strict
	 * `useSearch({ from: "…" })` inside organisms still find their match.
	 */
	id: string
	/**
	 * URL path pattern — the id minus its pathless `_layout` segments, with
	 * `$param` placeholders kept (e.g. `/programs/$programType/errata/`).
	 */
	path: string
	/** Concrete history entries; default `[path]` (no params in the path). */
	initialEntries?: string[]
	/** Session seeded into the query cache; `null` = guest, omit = not fetched. */
	user?: CurrentUser | null
	queryClient?: QueryClient
	strict?: boolean
}

/**
 * Mounts a page's real `Route` export in a one-route router at its real URL.
 *
 * Everything on the route runs for real — `validateSearch`, `beforeLoad`
 * guards, the loader, `head`, and the component with its `Route.*` hooks —
 * while the layout shells (navbar, sidebar, alert bar) stay out of the tree.
 * Serve the page's queries via MSW `server.use(...)` or a seeded query
 * client BEFORE calling this: the loader runs inside `router.load()`.
 *
 * Async because the router resolves matches before first paint — `await` it.
 * A loader that awaits (`ensureQueryData`) hangs the await if its request
 * never settles, so test pending UI only on routes that prefetch without
 * awaiting.
 */
export async function renderFileRoute(
	fileRoute: unknown,
	options: FileRouteRenderOptions,
) {
	const {
		id,
		path,
		initialEntries = [path],
		user,
		queryClient,
		strict = true,
	} = options
	const client = queryClient ?? createTestQueryClient(user)

	const rootRoute = createRootRouteWithContext<{ queryClient: QueryClient }>()(
		{
			notFoundComponent: () => <p>harness: not found</p>,
		},
	)
	const route = (fileRoute as UpdatableFileRoute).update({
		id,
		path,
		getParentRoute: () => rootRoute,
	})
	const router = createRouter({
		routeTree: rootRoute.addChildren([route]),
		history: createMemoryHistory({ initialEntries }),
		context: { queryClient: client },
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
