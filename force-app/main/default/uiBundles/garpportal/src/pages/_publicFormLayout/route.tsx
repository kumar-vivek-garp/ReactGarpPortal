import { createFileRoute, Outlet } from "@tanstack/react-router"

import { PublicShell } from "@/components/organisms/public-shell"

/**
 * Chrome for forms served to someone with no session.
 *
 * Deliberately not `_authLayout`: that one is a vertically-centred splash for a
 * single narrow card, and its guard throws a signed-in user to `/dashboard` —
 * which would fight the per-form guards and, worse, silently drop the
 * `stripe_return` params on a payment return. This one carries no guard at all;
 * each form guards itself, because the redirect target depends on
 * `params.programType` and a pathless layout above that segment cannot see it.
 *
 * The chrome itself lives in `PublicShell` (organisms) so the guest 404 can
 * wear it too — its toolbar-geometry constraint is documented there.
 *
 * Built to carry the other programme forms as they are written, not just FRM.
 */
export const Route = createFileRoute("/_publicFormLayout")({
	component: PublicFormLayout,
})

function PublicFormLayout() {
	return (
		<PublicShell>
			<Outlet />
		</PublicShell>
	)
}
