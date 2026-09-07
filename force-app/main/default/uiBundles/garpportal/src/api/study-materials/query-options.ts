import { queryOptions } from "@tanstack/react-query"

import { fetchMyEBooks } from "@/api/study-materials/ebooks"
import { fetchMaterialQuote } from "@/api/study-materials/material-purchase"
import { fetchStudyMaterials } from "@/api/study-materials/study-materials"

export const studyMaterialsQueryKeys = {
	all: ["study-materials"] as const,
	list: ["study-materials", "list"] as const,
	archive: ["study-materials", "archive"] as const,
	quote: (productCode: string) =>
		["study-materials", "quote", productCode.trim()] as const,
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

/**
 * The price and shipping facts for one material. Silent: the purchase panel
 * IS the error surface, with its own retry.
 */
export function materialQuoteQueryOptions(productCode: string) {
	const code = productCode.trim()
	return queryOptions({
		queryKey: studyMaterialsQueryKeys.quote(code),
		queryFn: () => fetchMaterialQuote(code),
		enabled: Boolean(code),
		staleTime: 30_000,
		retry: false,
	})
}
