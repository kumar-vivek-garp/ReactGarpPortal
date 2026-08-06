import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_appLayout/membership/")({
	component: Membership,
});

function Membership() {
	return <div>Membership</div>;
}
