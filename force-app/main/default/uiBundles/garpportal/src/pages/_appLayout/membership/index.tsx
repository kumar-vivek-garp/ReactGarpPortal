import { createFileRoute } from "@tanstack/react-router"

import { MembershipPending, PAGE_PENDING_MIN_MS, PAGE_PENDING_MS } from "@/components/molecules/page-pending"
import { MembershipPanel } from "@/components/organisms/membership-panel"
import { membershipSearchSchema } from "@/config/membership"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/membership/")({
	validateSearch: membershipSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle("Membership") }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: MembershipPending,
	component: Membership,
})

function Membership() {
	const { tab, view } = Route.useSearch()
	return <MembershipPanel tab={tab} view={view} />
}
