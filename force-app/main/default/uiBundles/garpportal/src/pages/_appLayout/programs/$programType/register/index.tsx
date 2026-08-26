import { createFileRoute } from "@tanstack/react-router"

import { ProgramRegistrationPanel } from "@/components/forms/program-registration/program-registration-panel"
import { registrationSearchSchema } from "@/config/registration"
import { pageTitle } from "@/lib/document-title"
import { resolveExamProgram } from "@/lib/registration-programs"

/**
 * Registration for one programme — `/programs/frm/register`.
 *
 * Reached from Register Now on the programmes listing. A child segment like
 * its siblings (`exam-setup`, `errata`, `results`, `work-experience`), so one
 * dynamic route serves every programme.
 *
 * A guest is not turned away at Login like those siblings: `_appLayout`'s guard
 * hands registration paths to their public twin instead. That decision lives in
 * the layout guard because a parent `beforeLoad` runs before any child's.
 *
 * It is also the address the payment provider returns to: the checkout success
 * URL is built from this location, so `stripe_return` arrives here as a fresh
 * page load with no React state to fall back on.
 */
export const Route = createFileRoute(
	"/_appLayout/programs/$programType/register/",
)({
	validateSearch: registrationSearchSchema,
	/*
	 * The programme's own short name, not the raw slug — `riskai` uppercased
	 * reads "RISKAI Registration". Unbuilt programmes keep the slug fallback.
	 */
	head: ({ params }) => ({
		meta: [
			{
				title: pageTitle(
					`${
						resolveExamProgram(params.programType)?.abbrevName ||
						params.programType.toUpperCase() ||
						"Program"
					} Registration`,
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
