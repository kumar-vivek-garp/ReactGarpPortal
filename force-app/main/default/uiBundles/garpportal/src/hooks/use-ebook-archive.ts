import { useMutation, useQuery } from "@tanstack/react-query"

import { fetchEBookAccess } from "@/api/study-materials/ebooks"
import { myEBooksQueryOptions } from "@/api/study-materials/query-options"

/** The member's purchased eBooks, grouped by edition year. */
export function useMyEBooks(enabled = true) {
	return useQuery({ ...myEBooksQueryOptions, enabled })
}

/**
 * Mints a reader link for one book and opens it.
 *
 * A mutation rather than a query because the link is minted by a vendor
 * call-out and is short-lived — caching one would hand the member a URL that
 * has expired by the time they click it.
 */
export function useOpenEBook() {
	return useMutation({
		mutationFn: (vendorId: string) => fetchEBookAccess(vendorId),
		meta: { errorTitle: "Unable to open this book" },
		onSuccess: (url) => {
			window.open(url, "_blank", "noopener,noreferrer")
		},
	})
}
