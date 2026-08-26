import { createFileRoute } from "@tanstack/react-router"

import { casesQueryOptions } from "@/api/help-center"
import { HelpCenterPending, PAGE_PENDING_MIN_MS, PAGE_PENDING_MS } from "@/components/molecules/page-pending"
import { HelpCenterPanel } from "@/components/organisms/help-center-panel"
import { helpCenterSearchSchema } from "@/config/help-center"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/help-center/")({
	validateSearch: helpCenterSearchSchema,
	// Prefetch only — the default tab (Get Help) needs no data, so awaiting
	// here would delay first paint for nothing. Cases feed the pill count and
	// the My Requests tab.
	loader: ({ context }) => {
		void context.queryClient.prefetchQuery(casesQueryOptions)
	},
	head: () => ({
		meta: [{ title: pageTitle("Help Center") }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: HelpCenterPending,
	component: HelpCenter,
})

function HelpCenter() {
	const { tab } = Route.useSearch()
	return <HelpCenterPanel tab={tab} />
}
