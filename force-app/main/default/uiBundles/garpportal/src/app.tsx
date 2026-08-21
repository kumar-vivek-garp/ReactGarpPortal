import { createRouter, RouterProvider } from "@tanstack/react-router"
import { QueryClientProvider } from "@tanstack/react-query"
import { StrictMode } from "react"
import { createRoot } from "react-dom/client"

import { queryClient } from "@/api/client"
import { installLocalDevContactFetchPatch } from "@/auth/local-dev-contacts"
import {
	bootstrapThemeFromStore,
	subscribeSystemColorScheme,
} from "@/store/theme-store"
import { routeTree } from "./routeTree.gen"
import "./styles/global.css"

// Normalize basepath: strip trailing slash so it matches URLs like /lwr/application/ai/c-app
const rawBasePath = (globalThis as { SFDC_ENV?: { basePath?: string } }).SFDC_ENV?.basePath
const basepath = typeof rawBasePath === "string" ? rawBasePath.replace(/\/+$/, "") : undefined

const router = createRouter({
	routeTree,
	basepath,
	context: { queryClient },
	// Do NOT set defaultPendingComponent — lazy child routes (Programs, etc.) would
	// replace the whole UI with the boot shell on every sidebar click.
	// Cold-load shells live only on `_appLayout` / `_authLayout`.
})

declare module "@tanstack/react-router" {
	interface Register {
		router: typeof router
	}
}

bootstrapThemeFromStore()
subscribeSystemColorScheme()
installLocalDevContactFetchPatch()

createRoot(document.getElementById("root")!).render(
	<StrictMode>
		<QueryClientProvider client={queryClient}>
			<RouterProvider router={router} />
		</QueryClientProvider>
	</StrictMode>,
)
