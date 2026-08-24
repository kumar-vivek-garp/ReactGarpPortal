import { createFileRoute } from "@tanstack/react-router"

import {
	PAGE_PENDING_MIN_MS,
	PAGE_PENDING_MS,
	StudyMaterialsPending,
} from "@/components/molecules/page-pending"
import { EBookArchivePanel } from "@/components/organisms/ebook-archive-panel"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/study-materials/archive/")({
	head: () => ({
		meta: [{ title: pageTitle("Purchased Study Materials") }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: StudyMaterialsPending,
	component: EBookArchive,
})

function EBookArchive() {
	return <EBookArchivePanel />
}
