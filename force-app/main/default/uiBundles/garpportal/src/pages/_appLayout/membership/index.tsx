import { createFileRoute } from "@tanstack/react-router"

import { MembershipPanel } from "@/components/organisms/membership-panel"
import { membershipSearchSchema } from "@/config/membership"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/membership/")({
	validateSearch: membershipSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle("Membership") }],
	}),
	component: Membership,
})

function Membership() {
	const { tab } = Route.useSearch()
	return <MembershipPanel tab={tab} />
}
