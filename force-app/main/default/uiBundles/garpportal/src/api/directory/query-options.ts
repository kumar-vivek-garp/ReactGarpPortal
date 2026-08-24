import { queryOptions } from "@tanstack/react-query"

import { fetchDirectory } from "@/api/directory/directory"

export const directoryQueryKeys = {
	all: ["directory"] as const,
	access: ["directory", "access"] as const,
	search: (params: unknown) => ["directory", "search", params] as const,
}

/** The viewer's directory entitlements. Stable for a session. */
export const directoryQueryOptions = queryOptions({
	queryKey: directoryQueryKeys.access,
	queryFn: fetchDirectory,
	staleTime: 5 * 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load the member directory",
	},
})
