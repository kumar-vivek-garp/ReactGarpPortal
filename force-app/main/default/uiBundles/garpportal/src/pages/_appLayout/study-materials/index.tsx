import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_appLayout/study-materials/")({
	component: StudyMaterials,
});

function StudyMaterials() {
	return <div>Study Materials</div>;
}
