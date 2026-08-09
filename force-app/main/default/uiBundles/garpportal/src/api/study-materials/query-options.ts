import { queryOptions } from "@tanstack/react-query"

import { fetchStudyMaterials } from "@/api/study-materials/study-materials"

export const studyMaterialsQueryKeys = {
	all: ["study-materials"] as const,
	list: ["study-materials", "list"] as const,
}

export const studyMaterialsQueryOptions = queryOptions({
	queryKey: studyMaterialsQueryKeys.list,
	queryFn: fetchStudyMaterials,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load study materials",
	},
})
