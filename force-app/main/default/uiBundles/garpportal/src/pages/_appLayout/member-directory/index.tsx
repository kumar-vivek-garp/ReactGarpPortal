import { createFileRoute } from "@tanstack/react-router"

import { PAGE_PENDING_MIN_MS, PAGE_PENDING_MS } from "@/components/molecules/page-pending"
import { MemberDirectoryPanel } from "@/components/organisms/member-directory-panel"
import { directorySearchSchema } from "@/config/directory"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/member-directory/")({
	validateSearch: directorySearchSchema,
	head: () => ({
		meta: [{ title: pageTitle("Member Directory") }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	component: MemberDirectory,
})

function MemberDirectory() {
	const { q } = Route.useSearch()
	/*
	 * Keyed on the term so arriving from the dashboard box with a new `?q=`
	 * remounts the panel with fresh state. Syncing the prop into state with an
	 * effect instead would cascade a render on every navigation.
	 */
	return <MemberDirectoryPanel key={q ?? ""} initialTerm={q ?? ""} />
}
