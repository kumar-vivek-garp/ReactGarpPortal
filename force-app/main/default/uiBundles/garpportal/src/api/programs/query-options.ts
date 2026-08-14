import { queryOptions } from "@tanstack/react-query"

import { fetchProgramDetail } from "@/api/programs/program-detail"
import { fetchPrograms } from "@/api/programs/programs"

export const programsQueryKeys = {
	all: ["programs"] as const,
	view: ["programs", "view"] as const,
	detail: (programType: string) =>
		["programs", "detail", programType.trim().toLowerCase()] as const,
}

export const programsQueryOptions = queryOptions({
	queryKey: programsQueryKeys.view,
	queryFn: fetchPrograms,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load programs",
	},
})

export function programDetailQueryOptions(programType: string) {
	const slug = programType.trim()
	return queryOptions({
		queryKey: programsQueryKeys.detail(slug),
		queryFn: () => fetchProgramDetail(slug),
		enabled: Boolean(slug),
		staleTime: 60_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load program details",
		},
	})
}
