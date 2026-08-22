import { createFileRoute } from "@tanstack/react-router"

import { cpdProgramQueryOptions } from "@/api/cpd"
import {
	CpdPending,
	PAGE_PENDING_MIN_MS,
	PAGE_PENDING_MS,
} from "@/components/molecules/page-pending"
import { CpdPanel } from "@/components/organisms/cpd-panel"
import { CPD_PAGE_TITLE, cpdSearchSchema } from "@/config/cpd"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/cpd/")({
	validateSearch: cpdSearchSchema,
	// Prefetch rather than ensure: `cpdProgram` reads every claim on the
	// account, and awaiting it here would hold the heading off screen. The
	// panel owns its own skeleton.
	loader: ({ context }) => {
		void context.queryClient.prefetchQuery(cpdProgramQueryOptions)
	},
	head: () => ({
		meta: [{ title: pageTitle(CPD_PAGE_TITLE) }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: CpdPending,
	component: Cpd,
})

function Cpd() {
	const { cycle } = Route.useSearch()
	return <CpdPanel cycle={cycle} />
}
