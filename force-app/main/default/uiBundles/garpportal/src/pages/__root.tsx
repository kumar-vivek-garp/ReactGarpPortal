import { createRootRouteWithContext, HeadContent, Outlet } from "@tanstack/react-router"
import type { QueryClient } from "@tanstack/react-query"
import { useReducedMotion } from "@react-spring/web"
import { lazy, Suspense } from "react"
import { preconnect, preload } from "react-dom"

import { Toaster } from "@/components/atoms/sonner"
import { TooltipProvider } from "@/components/atoms/tooltip"
import { NotFoundPage } from "@/components/organisms/not-found-page"
import { COMMON_PROGRAM_LOGO_URLS, GARP_HUB_ORIGIN } from "@/config/program-logos"
import klinicBook from "@/assets/fonts/KlinicSlabBook.woff2?url"
import klinicBold from "@/assets/fonts/KlinicSlabBold.woff2?url"
import nunitoBold from "@/assets/fonts/NunitoSans-Bold.woff2?url"
import nunitoRegular from "@/assets/fonts/NunitoSans-Regular.woff2?url"

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

/** Above-the-fold faces — preload so fonts are not chained behind CSS parse. */
const CRITICAL_FONT_PRELOADS = [
	{ href: nunitoRegular, type: "font/woff2" },
	{ href: nunitoBold, type: "font/woff2" },
	{ href: klinicBook, type: "font/woff2" },
	{ href: klinicBold, type: "font/woff2" },
] as const

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
			// Remaining HubSpot: optional China QR images in the footer dialog.
			{ rel: "preconnect", href: GARP_HUB_ORIGIN, crossOrigin: "anonymous" },
			{ rel: "dns-prefetch", href: GARP_HUB_ORIGIN },
			...CRITICAL_FONT_PRELOADS.map(({ href, type }) => ({
				rel: "preload" as const,
				href,
				as: "font" as const,
				type,
				crossOrigin: "anonymous" as const,
			})),
		],
	}),
	component: RootComponent,
	// Unknown URLs land here (notFoundMode: "root" in app.tsx). Session-aware:
	// portal chrome for members, public chrome for guests — and it dismisses
	// the boot splash, which no layout would otherwise do on a missed URL.
	notFoundComponent: NotFoundPage,
})

function RootComponent() {
	/**
	 * Sets react-spring's `Globals.skipAnimation` when the OS prefers reduced
	 * motion — every spring in the app then jumps straight to its goal value.
	 * Called once here so individual components never re-implement the check.
	 */
	useReducedMotion()

	preconnect(GARP_HUB_ORIGIN, { crossOrigin: "anonymous" })
	for (const { href, type } of CRITICAL_FONT_PRELOADS) {
		preload(href, {
			as: "font",
			type,
			crossOrigin: "anonymous",
			fetchPriority: "high",
		})
	}
	for (const href of COMMON_PROGRAM_LOGO_URLS) {
		preload(href, { as: "image" })
	}

	return (
		<>
			<HeadContent />
			{/* Mounted once at the root so any collapsed-rail row (or future
			    icon-only control) can label itself without each surface
			    standing up its own provider — and so the hover delay is one
			    decision, made in `atoms/tooltip`, rather than per call site. */}
			<TooltipProvider>
				<Outlet />
			</TooltipProvider>
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
