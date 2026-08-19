import { queryOptions } from "@tanstack/react-query"

import { fetchAccount } from "@/api/account/account"
import { fetchAccountContact } from "@/api/account/account-contact"
import { fetchAccountOptions } from "@/api/account/options"

export const accountQueryKeys = {
	all: ["account"] as const,
	detail: ["account", "detail"] as const,
	options: ["account", "options"] as const,
	/** Prefix for all GraphQL `AccountContact` queries. */
	contacts: ["account", "contact"] as const,
	contact: (contactId: string) => ["account", "contact", contactId] as const,
}

export const accountQueryOptions = queryOptions({
	queryKey: accountQueryKeys.detail,
	queryFn: fetchAccount,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load account",
	},
})

export function accountOptionsQueryOptions(enabled: boolean) {
	return queryOptions({
		queryKey: accountQueryKeys.options,
		queryFn: fetchAccountOptions,
		enabled,
		staleTime: 60_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load form options",
		},
	})
}

/** GraphQL Contact essentials. Completeness stays on REST detail. */
export function accountContactQueryOptions(contactId: string) {
	return queryOptions({
		queryKey: accountQueryKeys.contact(contactId),
		queryFn: () => fetchAccountContact(contactId),
		enabled: Boolean(contactId.trim()),
		staleTime: 60_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load account contact",
		},
	})
}
