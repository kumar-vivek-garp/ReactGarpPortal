import { createFileRoute } from "@tanstack/react-router"

import { ProgramRegistrationPanel } from "@/components/forms/program-registration/program-registration-panel"
import {
	registrationDocumentTitle,
	registrationSearchSchema,
} from "@/config/registration"
import { pageTitle } from "@/lib/document-title"
import { registrationLegProps } from "@/lib/registration-paths"
import { resolveExamProgram } from "@/lib/registration-programs"

/**
 * Individual membership registration for a signed-in member —
 * `/membership/register`.
 *
 * The member twin of `/registration/membership`. It sits beside the
 * Membership Benefits page rather than under `/programs` because a membership
 * is not a programme: this is where Upgrade and Renew Now on My Account, the
 * benefits page and the gated-content upsell all point, and Back returns to
 * benefits. Same form, same dispatcher, fixed slug.
 *
 * A guest is not turned away at Login: `_appLayout`'s guard hands this path to
 * its public twin (`publicRegistrationFallback`), carrying the query string —
 * a `track_cta` or `regCode` lost on the bounce would silently misattribute or
 * reprice the order.
 *
 * It is also the address the payment provider returns to: the checkout
 * success URL is built from this location, so `stripe_return` arrives here as
 * a fresh page load with no React state to fall back on.
 */
export const Route = createFileRoute("/_appLayout/membership/register/")({
	validateSearch: registrationSearchSchema,
	head: () => ({
		meta: [
			{
				title: pageTitle(
					registrationDocumentTitle(resolveExamProgram("membership")!),
				),
			},
		],
	}),
	component: MembershipRegistrationPage,
})

function MembershipRegistrationPage() {
	const search = Route.useSearch()

	return (
		<ProgramRegistrationPanel
			programType="membership"
			regCode={search.regCode ?? search.teamCode}
			trackCta={search.track_cta}
			{...registrationLegProps(search)}
		/>
	)
}
