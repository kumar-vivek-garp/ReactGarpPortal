import { createFileRoute } from "@tanstack/react-router"

import { MyAccountPanel } from "@/components/organisms/my-account-panel"
import { myAccountSearchSchema } from "@/config/my-account"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/my-account/")({
	validateSearch: myAccountSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle("My Account") }],
	}),
	component: MyAccount,
})

function MyAccount() {
	const { tab } = Route.useSearch()
	return <MyAccountPanel tab={tab} />
}
