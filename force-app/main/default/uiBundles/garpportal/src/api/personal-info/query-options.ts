import { queryOptions } from "@tanstack/react-query"

import { fetchCountryOptions } from "@/api/personal-info/countries"
import { loadPersonalInfoEditData } from "@/api/personal-info/load-edit-data"

export const personalInfoQueryKeys = {
	all: ["personal-info"] as const,
	countries: ["personal-info", "countries"] as const,
	edit: (contactId: string) => ["personal-info", "edit", contactId] as const,
}

export const countryOptionsQueryOptions = queryOptions({
	queryKey: personalInfoQueryKeys.countries,
	queryFn: fetchCountryOptions,
	staleTime: 5 * 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load countries",
	},
})

export function personalInfoEditQueryOptions(contactId: string) {
	return queryOptions({
		queryKey: personalInfoQueryKeys.edit(contactId),
		queryFn: () => loadPersonalInfoEditData(contactId),
		enabled: Boolean(contactId.trim()),
		staleTime: 30_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load personal information",
		},
	})
}
