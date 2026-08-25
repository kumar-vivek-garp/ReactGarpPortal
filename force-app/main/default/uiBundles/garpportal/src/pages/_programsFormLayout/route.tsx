import { createFileRoute, Outlet } from "@tanstack/react-router"

import { AppLayoutShell } from "@/components/organisms/app-layout-shell"

/**
 * Portal chrome **without** the sign-in wall.
 *
 * Visually identical to `_appLayout` — same navbar, sidebar and footer — but
 * it carries no `beforeLoad`. Its children are the registration forms, which
 * guard themselves per-programme: a guest is sent to the public form rather
 * than to Login, and that decision needs `params.programType`, which a
 * pathless layout sitting above the `$programType` segment does not have.
 *
 * So the guard lives on the leaf and this route group exists purely to supply
 * the shell. Both groups are pathless, so nothing here changes a URL.
 */
export const Route = createFileRoute("/_programsFormLayout")({
	component: ProgramsFormLayout,
})

function ProgramsFormLayout() {
	return (
		<AppLayoutShell>
			<Outlet />
		</AppLayoutShell>
	)
}
