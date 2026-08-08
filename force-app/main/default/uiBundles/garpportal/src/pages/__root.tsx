import { createRootRouteWithContext, HeadContent, Outlet } from "@tanstack/react-router"
import type { QueryClient } from "@tanstack/react-query"
import { lazy, Suspense } from "react"

import { Toaster } from "@/components/atoms/sonner"

export type RouterContext = {
	queryClient: QueryClient
}

const RouterDevtools = import.meta.env.DEV
	? lazy(() =>
			import("@tanstack/react-router-devtools").then((m) => ({
				default: m.TanStackRouterDevtools,
			})),
		)
	: null

const QueryDevtools = import.meta.env.DEV
	? lazy(() =>
			import("@tanstack/react-query-devtools").then((m) => ({
				default: m.ReactQueryDevtools,
			})),
		)
	: null

export const Route = createRootRouteWithContext<RouterContext>()({
	head: () => ({
		meta: [{ title: "GARP" }],
		links: [{ rel: "icon", href: "/favicon.ico", type: "image/x-icon" }],
	}),
	component: RootComponent,
})

function RootComponent() {
	return (
		<>
			<HeadContent />
			<Outlet />
			<Toaster position="top-center" richColors closeButton />
			{RouterDevtools && QueryDevtools ? (
				<Suspense fallback={null}>
					<RouterDevtools />
					<QueryDevtools initialIsOpen={false} />
				</Suspense>
			) : null}
		</>
	)
}
