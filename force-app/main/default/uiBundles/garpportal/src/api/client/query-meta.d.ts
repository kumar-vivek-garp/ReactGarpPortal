import "@tanstack/react-query"

declare module "@tanstack/react-query" {
	interface Register {
		mutationMeta: {
			/** Skip MutationCache error toast (e.g. login form shows inline errors). */
			silent?: boolean
			/** Toast this message on mutation success. */
			successMessage?: string
			/** Override error toast title. */
			errorTitle?: string
		}
		queryMeta: {
			/** Force-skip even if toastError is set. */
			silent?: boolean
			/** Opt-in: toast query failures (queries are silent by default). */
			toastError?: boolean
			/** Override error toast title. */
			errorTitle?: string
		}
	}
}

export {}
