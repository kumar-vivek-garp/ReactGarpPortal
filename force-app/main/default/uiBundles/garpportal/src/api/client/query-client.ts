import { MutationCache, QueryCache, QueryClient } from "@tanstack/react-query"

import { notifyError, notifySuccess } from "@/api/client/notify"

/**
 * Shared QueryClient — React QueryProvider, router `beforeLoad`, and global toasts.
 *
 * Policy:
 * - Mutations: toast errors unless `meta.silent`; toast success only if `meta.successMessage`
 * - Queries: silent unless `meta.toastError` (auth probes stay quiet)
 */
export const queryClient = new QueryClient({
	queryCache: new QueryCache({
		onError: (error, query) => {
			const meta = query.meta
			if (meta?.silent || !meta?.toastError) return
			notifyError(error, meta.errorTitle)
		},
	}),
	mutationCache: new MutationCache({
		onError: (error, _variables, _context, mutation) => {
			const meta = mutation.meta
			if (meta?.silent) return
			notifyError(error, meta?.errorTitle)
		},
		onSuccess: (_data, _variables, _context, mutation) => {
			const message = mutation.meta?.successMessage
			if (message) notifySuccess(message)
		},
	}),
	defaultOptions: {
		queries: {
			retry: 1,
		},
	},
})
