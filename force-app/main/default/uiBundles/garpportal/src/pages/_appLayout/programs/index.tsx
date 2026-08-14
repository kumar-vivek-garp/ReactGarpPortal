import { createFileRoute } from "@tanstack/react-router"
import { preload } from "react-dom"

import type { ProgramsView } from "@/api/programs"
import { programsQueryOptions } from "@/api/programs"
import { ProgramsPanel } from "@/components/organisms/programs-panel"
import { COMMON_PROGRAM_LOGO_URLS } from "@/config/program-logos"
import { programsSearchSchema } from "@/config/programs"
import { pageTitle } from "@/lib/document-title"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"

function preloadProgramLogos(view: ProgramsView | undefined) {
	for (const href of COMMON_PROGRAM_LOGO_URLS) {
		preload(href, { as: "image", fetchPriority: "high" })
	}
	if (!view) return
	const urls = [
		...view.enrolledPrograms,
		...view.completedPrograms,
		...view.otherPrograms,
	]
		.map(
			(program) =>
				resolvePortalAssetUrl(program.programInformation?.myProgramsLogoURL) ??
				program.programInformation?.myProgramsLogoURL,
		)
		.filter((url): url is string => Boolean(url))
		.slice(0, 3)
	for (const href of urls) {
		preload(href, { as: "image", fetchPriority: "high" })
	}
}

export const Route = createFileRoute("/_appLayout/programs/")({
	validateSearch: programsSearchSchema,
	loader: ({ context }) =>
		context.queryClient.ensureQueryData(programsQueryOptions),
	head: ({ loaderData }) => {
		preloadProgramLogos(loaderData)
		return {
			meta: [
				{ title: pageTitle("Programs") },
				{
					name: "description",
					content:
						"View your GARP programs in progress, completed certifications, and explore other offerings.",
				},
			],
			links: COMMON_PROGRAM_LOGO_URLS.map((href) => ({
				rel: "preload",
				as: "image",
				href,
			})),
		}
	},
	component: Programs,
})

function Programs() {
	const { tab } = Route.useSearch()
	const programs = Route.useLoaderData()
	preloadProgramLogos(programs)
	return <ProgramsPanel tab={tab} />
}
