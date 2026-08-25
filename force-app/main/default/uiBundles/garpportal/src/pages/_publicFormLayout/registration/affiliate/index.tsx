import { createFileRoute } from "@tanstack/react-router"

import { redirectMemberToDashboard } from "@/auth/registration-guard"
import { AffiliateRegistrationPanel } from "@/components/forms/affiliate/affiliate-registration-panel"
import { AFFILIATE_REGISTRATION_TITLE } from "@/config/registration"
import { pageTitle } from "@/lib/document-title"

/**
 * Free Affiliate membership sign-up — `/registration/affiliate`.
 *
 * A **static** sibling of `/registration/$programType`, which is what makes
 * the address safe to use: TanStack Router sorts routes by specificity, so a
 * static segment always matches ahead of a dynamic one and this never falls
 * through to the exam dispatcher. It must not — that dispatcher prices a cart
 * and its guard bounces a member to `/programs/affiliate/register`, a page
 * that does not exist.
 *
 * It sits under `_publicFormLayout` with the exam forms rather than under
 * `_authLayout`'s narrow splash card, because it is a registration form and
 * not a login box: same chrome, same shell height, same 60/40 layout.
 *
 * There is no member twin. Affiliate sign-up creates a GARP account, and
 * anyone with a session already has one — so the guard sends them to their
 * dashboard, which is the same answer `_authLayout` gave when the form lived
 * at `/affiliate`.
 */
export const Route = createFileRoute("/_publicFormLayout/registration/affiliate/")({
	beforeLoad: redirectMemberToDashboard,
	head: () => ({
		meta: [{ title: pageTitle(AFFILIATE_REGISTRATION_TITLE) }],
	}),
	component: AffiliateRegistrationPage,
})

function AffiliateRegistrationPage() {
	return <AffiliateRegistrationPanel />
}
