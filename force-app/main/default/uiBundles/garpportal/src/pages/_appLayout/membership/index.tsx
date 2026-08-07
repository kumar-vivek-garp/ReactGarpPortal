import { createFileRoute } from "@tanstack/react-router";

import { pageTitle } from "@/lib/document-title";

export const Route = createFileRoute("/_appLayout/membership/")({
	head: () => ({
		meta: [{ title: pageTitle("Membership") }],
	}),
	component: Membership,
});

function Membership() {
	return <div>Membership</div>;
}
