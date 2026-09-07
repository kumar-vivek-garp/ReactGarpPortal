import { createFileRoute } from "@tanstack/react-router"

import { redirectMemberToPortalForm } from "@/auth/registration-guard"
import { ProgramRegistrationPanel } from "@/components/forms/program-registration/program-registration-panel"
import {
	registrationDocumentTitle,
	registrationSearchSchema,
} from "@/config/registration"
import { pageTitle } from "@/lib/document-title"
import { registrationLegProps } from "@/lib/registration-paths"
import { resolveExamProgram } from "@/lib/registration-programs"

/**
 * Public registration for one programme — `/registration/frm`.
 *
 * The same form the portal serves at `/programs/$programType/register`, for
 * someone who does not have an account yet — which is the usual state of a
 * candidate registering for an exam. Nothing is prefilled, and the form asks
 * for the name and email a member's contact record would otherwise supply.
 *
 * `/registration/<type>` is the legacy address, kept because it is already in
 * circulation in GARP's marketing email.
 *
 * It is also an address the payment provider returns to: the checkout success
 * URL is built from wherever the form was served, so `stripe_return` can land
 * here as a fresh page load with no React state behind it.
 */
export const Route = createFileRoute("/_publicFormLayout/registration/$programType/")({
	validateSearch: registrationSearchSchema,
	/* A signed-in member gets the in-portal form, which prefills for them. */
	beforeLoad: redirectMemberToPortalForm,
	/*
	 * The programme's own short name, not the raw slug — `riskai` uppercased
	 * reads "RISKAI Registration". Unbuilt programmes keep the slug fallback.
	 */
	head: ({ params }) => {
		const program = resolveExamProgram(params.programType)
		return {
			meta: [
				{
					title: pageTitle(
						program
							? registrationDocumentTitle(program)
							: `${params.programType.toUpperCase() || "Program"} Registration`,
					),
				},
			],
		}
	},
	component: PublicRegistrationPage,
})

function PublicRegistrationPage() {
	const { programType } = Route.useParams()
	const search = Route.useSearch()

	return (
		<ProgramRegistrationPanel
			programType={programType}
			regCode={search.regCode ?? search.teamCode}
			trackCta={search.track_cta}
			{...registrationLegProps(search)}
		/>
	)
}
