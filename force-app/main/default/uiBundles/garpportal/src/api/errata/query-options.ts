import { queryOptions } from "@tanstack/react-query"

import { fetchErrataForm } from "@/api/errata/errata-form"

export const errataQueryKeys = {
	all: ["errata"] as const,
	form: (programType: string) =>
		["errata", "form", programType.trim().toUpperCase()] as const,
}

/**
 * The cascade's options for one programme.
 *
 * Long stale time: these are org picklist values, which change on a metadata
 * deploy rather than on anything a member does.
 */
export function errataFormQueryOptions(programType: string) {
	return queryOptions({
		queryKey: errataQueryKeys.form(programType),
		queryFn: () => fetchErrataForm(programType),
		enabled: Boolean(programType.trim()),
		staleTime: 5 * 60_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load the errata form",
		},
	})
}
