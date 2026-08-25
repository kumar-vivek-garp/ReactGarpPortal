import { createFileRoute } from "@tanstack/react-router"

import { redirectGuestToPublicForm } from "@/auth/registration-guard"
import { ProgramRegistrationPanel } from "@/components/forms/program-registration/program-registration-panel"
import { registrationSearchSchema } from "@/config/registration"
import { pageTitle } from "@/lib/document-title"

/**
 * Registration for one programme — `/programs/frm/register`.
 *
 * Reached from Register Now on the programmes listing. One dynamic route
 * serves every programme. The URL is unchanged by the move to
 * `_programsFormLayout` — both layout groups are pathless — but its former
 * siblings (`exam-setup`, `errata`, `results`) stay under `_appLayout`,
 * because they genuinely are member-only.
 *
 * It is also the address the payment provider returns to: the checkout success
 * URL is built from this location, so `stripe_return` arrives here as a fresh
 * page load with no React state to fall back on.
 */
export const Route = createFileRoute(
	"/_programsFormLayout/programs/$programType/register/",
)({
	validateSearch: registrationSearchSchema,
	/*
	 * No session? The same form is served publicly — send them there
	 * instead of to a sign-in wall. This is why the route sits under
	 * `_programsFormLayout` rather than `_appLayout`, whose own guard
	 * would have redirected to Login before this ever ran.
	 */
	beforeLoad: redirectGuestToPublicForm,
	head: ({ params }) => ({
		meta: [
			{
				title: pageTitle(
					`${params.programType.toUpperCase() || "Program"} Registration`,
				),
			},
		],
	}),
	component: ProgramRegistrationPage,
})

function ProgramRegistrationPage() {
	const { programType } = Route.useParams()
	const search = Route.useSearch()

	return (
		<ProgramRegistrationPanel
			programType={programType}
			regCode={search.regCode ?? search.teamCode}
			paymentReturn={
				search.stripe_return === "1" ? { orderNumber: search.on } : null
			}
		/>
	)
}
