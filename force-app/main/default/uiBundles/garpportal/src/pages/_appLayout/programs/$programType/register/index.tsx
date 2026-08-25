import { createFileRoute } from "@tanstack/react-router"

import { ProgramRegistrationPanel } from "@/components/forms/program-registration/program-registration-panel"
import { pageTitle } from "@/lib/document-title"

/**
 * Registration for one programme — `/programs/frm/register`.
 *
 * Reached from Register Now on the programmes listing. A child segment like
 * its siblings (`exam-setup`, `errata`, `results`, `work-experience`), so one
 * dynamic route serves every programme.
 */
export const Route = createFileRoute(
	"/_appLayout/programs/$programType/register/",
)({
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
	return <ProgramRegistrationPanel programType={programType} />
}
