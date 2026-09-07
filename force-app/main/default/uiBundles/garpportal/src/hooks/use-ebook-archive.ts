import { useMutation, useQuery } from "@tanstack/react-query"

import { fetchEBookAccess } from "@/api/study-materials/ebooks"
import { myEBooksQueryOptions } from "@/api/study-materials/query-options"
import type { MyEBooksView } from "@/api/study-materials/types"

/** The member's purchased eBooks, grouped by edition year. */
export function useMyEBooks(enabled = true) {
	return useQuery({ ...myEBooksQueryOptions, enabled })
}

function hasAnyEBook(view: MyEBooksView): boolean {
	return Object.keys(view.eBooks).length > 0
}

/**
 * Whether the member owns any eBook key at all — the gate on the "My Access
 * Links" entry point, as the legacy gates it.
 *
 * Silent on failure: this is a hint on the catalogue page, not the page
 * itself, and the archive route's own query toasts when it is the one that
 * matters. Resolves `false` until the answer is in.
 */
export function useHasEBookArchive(): boolean {
	const { data } = useQuery({
		...myEBooksQueryOptions,
		meta: { toastError: false },
		select: hasAnyEBook,
	})
	return data === true
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
