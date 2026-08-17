import { createFileRoute } from "@tanstack/react-router"

import { MyAccountPending, PAGE_PENDING_MIN_MS, PAGE_PENDING_MS } from "@/components/molecules/page-pending"
import { MyAccountPanel } from "@/components/organisms/my-account-panel"
import { myAccountSearchSchema } from "@/config/my-account"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/my-account/")({
	validateSearch: myAccountSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle("My Account") }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: MyAccountPending,
	component: MyAccount,
})

function MyAccount() {
	const { tab } = Route.useSearch()
	return <MyAccountPanel tab={tab} />
}
