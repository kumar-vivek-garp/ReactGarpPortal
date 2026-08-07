import { createFileRoute } from "@tanstack/react-router";

import { pageTitle } from "@/lib/document-title";

export const Route = createFileRoute("/_appLayout/my-account/")({
	head: () => ({
		meta: [{ title: pageTitle("My Account") }],
	}),
	component: MyAccount,
});

function MyAccount() {
	return <div>My Account</div>;
}
