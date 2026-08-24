import { queryOptions } from "@tanstack/react-query"

import { fetchMyEBooks } from "@/api/study-materials/ebooks"
import { fetchStudyMaterials } from "@/api/study-materials/study-materials"

export const studyMaterialsQueryKeys = {
	all: ["study-materials"] as const,
	list: ["study-materials", "list"] as const,
	archive: ["study-materials", "archive"] as const,
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

/** Purchased eBooks, grouped by edition year. */
export const myEBooksQueryOptions = queryOptions({
	queryKey: studyMaterialsQueryKeys.archive,
	queryFn: fetchMyEBooks,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load your purchased materials",
	},
})
