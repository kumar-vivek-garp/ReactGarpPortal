import { createFileRoute } from "@tanstack/react-router"

import { AffiliateRegistrationForm } from "@/components/forms/affiliate/affiliate-registration-form"
import { AuthShell } from "@/components/organisms/auth-shell"
import { pageTitle } from "@/lib/document-title"

/**
 * Free Affiliate membership sign-up — this app's "Create Account".
 *
 * Sits under `_authLayout`, which redirects anyone who already has a session
 * to their dashboard: an existing member reaches their account by signing in,
 * not by registering a second one.
 *
 * The form is laid out in two columns and caps its own height, scrolling
 * internally rather than pushing the logo and footer off screen.
 */
export const Route = createFileRoute("/_authLayout/affiliate/")({
	head: () => ({
		meta: [{ title: pageTitle("Affiliate Membership") }],
	}),
	component: AffiliateRegistration,
})

function AffiliateRegistration() {
	return (
		<AuthShell>
			<AffiliateRegistrationForm />
		</AuthShell>
	)
}
