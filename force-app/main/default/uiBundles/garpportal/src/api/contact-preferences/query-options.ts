import { queryOptions } from "@tanstack/react-query"

import { loadContactPreferences } from "@/api/contact-preferences/load-preferences"

export const contactPreferencesQueryKeys = {
	all: ["contact-preferences"] as const,
	detail: (contactId: string) =>
		["contact-preferences", "detail", contactId] as const,
}

export function contactPreferencesQueryOptions(contactId: string) {
	return queryOptions({
		queryKey: contactPreferencesQueryKeys.detail(contactId),
		queryFn: () => loadContactPreferences(contactId),
		enabled: Boolean(contactId.trim()),
		staleTime: 30_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load contact preferences",
		},
	})
}
