import { createFileRoute, redirect } from "@tanstack/react-router"

import { AFFILIATE_REGISTRATION_ROUTE } from "@/lib/registration-paths"

/**
 * The address Affiliate sign-up used to live at, kept as a forward.
 *
 * `/affiliate` has been this form's public URL and is linked from outside the
 * app, so it redirects rather than 404s. It renders nothing and belongs to
 * neither layout group — `beforeLoad` always throws, so no chrome is ever
 * mounted and the visitor sees only the destination.
 */
export const Route = createFileRoute("/affiliate/")({
	beforeLoad: () => {
		throw redirect({ to: AFFILIATE_REGISTRATION_ROUTE })
	},
})
