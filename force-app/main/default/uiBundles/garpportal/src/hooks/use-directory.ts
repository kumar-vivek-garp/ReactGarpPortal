import { keepPreviousData, useMutation, useQuery } from "@tanstack/react-query"

import {
	directoryQueryKeys,
	directoryQueryOptions,
	searchDirectory,
	sendDirectoryMessage,
	type DirectoryMessageInput,
	type DirectorySearchParams,
} from "@/api/directory"

/** What the viewer may do in the directory. */
export function useDirectory(enabled = true) {
	return useQuery({ ...directoryQueryOptions, enabled })
}

/**
 * One page of directory results.
 *
 * `keepPreviousData` holds the current page on screen while the next one
 * loads, so paging does not blank the list and bounce the scroll position.
 */
export function useDirectorySearch(
	params: DirectorySearchParams,
	enabled = true,
) {
	return useQuery({
		queryKey: directoryQueryKeys.search(params),
		queryFn: () => searchDirectory(params),
		enabled,
		placeholderData: keepPreviousData,
		staleTime: 30_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "The directory search could not be run",
		},
	})
}

/** Send a message or a connection invite to another member. */
export function useSendDirectoryMessage() {
	return useMutation({
		mutationFn: (input: DirectoryMessageInput) => sendDirectoryMessage(input),
		meta: {
			successMessage: "Message sent",
			errorTitle: "Unable to send your message",
		},
	})
}
