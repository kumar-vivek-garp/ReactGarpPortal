import { createFileRoute } from "@tanstack/react-router"

import { HelpCenterPanel } from "@/components/organisms/help-center-panel"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/help-center/")({
	head: () => ({
		meta: [{ title: pageTitle("Help Center") }],
	}),
	component: HelpCenter,
})

function HelpCenter() {
	return <HelpCenterPanel />
}
