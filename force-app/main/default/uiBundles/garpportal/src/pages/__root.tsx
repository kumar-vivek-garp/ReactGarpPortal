import { createRootRoute, HeadContent, Outlet } from "@tanstack/react-router";
import { TanStackRouterDevtools } from "@tanstack/react-router-devtools";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";

export const Route = createRootRoute({
	head: () => ({
		meta: [{ title: "GARP" }],
		links: [{ rel: "icon", href: "/favicon.ico", type: "image/x-icon" }],
	}),
	component: () => (
		<>
			<HeadContent />
			<Outlet />
			<TanStackRouterDevtools />
			<ReactQueryDevtools initialIsOpen={false} />
		</>
	),
});
