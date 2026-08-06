import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_appLayout/programs/")({
	component: Programs,
});

function Programs() {
	return <div>Programs</div>;
}
