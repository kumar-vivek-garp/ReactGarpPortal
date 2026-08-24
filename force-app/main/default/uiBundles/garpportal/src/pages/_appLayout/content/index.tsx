import { createFileRoute } from "@tanstack/react-router"

import { GatedContentPanel } from "@/components/organisms/gated-content-panel"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/content/")({
	head: () => ({ meta: [{ title: pageTitle("GARP Content") }] }),
	component: GatedContent,
})

function GatedContent() {
	return <GatedContentPanel />
}
