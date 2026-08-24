import { createFileRoute, redirect } from "@tanstack/react-router"

import { DEFAULT_MEMBERSHIP_TAB } from "@/config/membership"

/**
 * A second legacy path onto the membership page, kept as a redirect.
 *
 * MyGarp served `/member-resources` and `/membership` from the same component,
 * so existing links point at both. Redirecting keeps them resolving without a
 * duplicate page to maintain.
 */
export const Route = createFileRoute("/_appLayout/member-resources/")({
	beforeLoad: () => {
		throw redirect({
			to: "/membership",
			search: { tab: DEFAULT_MEMBERSHIP_TAB },
			replace: true,
		})
	},
})
