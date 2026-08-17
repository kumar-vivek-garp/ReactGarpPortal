import { createFileRoute } from "@tanstack/react-router"

import { HelpCenterPending, PAGE_PENDING_MIN_MS, PAGE_PENDING_MS } from "@/components/molecules/page-pending"
import { HelpCenterPanel } from "@/components/organisms/help-center-panel"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/help-center/")({
	head: () => ({
		meta: [{ title: pageTitle("Help Center") }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: HelpCenterPending,
	component: HelpCenter,
})

function HelpCenter() {
	return <HelpCenterPanel />
}
