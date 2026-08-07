import { createFileRoute } from "@tanstack/react-router";

import { pageTitle } from "@/lib/document-title";

export const Route = createFileRoute("/_appLayout/study-materials/")({
	head: () => ({
		meta: [{ title: pageTitle("Study Materials") }],
	}),
	component: StudyMaterials,
});

function StudyMaterials() {
	return <div>Study Materials</div>;
}
