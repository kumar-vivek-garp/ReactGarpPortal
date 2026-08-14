import { createRootRouteWithContext, HeadContent, Outlet } from "@tanstack/react-router"
import type { QueryClient } from "@tanstack/react-query"
import { lazy, Suspense } from "react"
import { preconnect, preload } from "react-dom"

import { Toaster } from "@/components/atoms/sonner"
import {
	CRITICAL_FONT_URLS,
	GARP_HUB_ORIGIN,
} from "@/config/program-logos"
import { GARP_LOGO_KNOCKOUT } from "@/config/navigation/garp-logos"

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
		meta: [
			{ title: "GARP" },
			{
				name: "description",
				content:
					"GARP Member Portal — manage your FRM, SCR, RAI, and membership programs, study materials, events, and account.",
			},
		],
		links: [
			{ rel: "icon", href: "/favicon.ico", type: "image/x-icon" },
			{ rel: "preconnect", href: GARP_HUB_ORIGIN, crossOrigin: "anonymous" },
			{ rel: "dns-prefetch", href: GARP_HUB_ORIGIN },
		],
	}),
	component: RootComponent,
})

function RootComponent() {
	preconnect(GARP_HUB_ORIGIN, { crossOrigin: "anonymous" })
	for (const href of CRITICAL_FONT_URLS) {
		preload(href, { as: "font", type: "font/ttf", crossOrigin: "anonymous" })
	}
	preload(GARP_LOGO_KNOCKOUT, { as: "image", fetchPriority: "high" })

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
