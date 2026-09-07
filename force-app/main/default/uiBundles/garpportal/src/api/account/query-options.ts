import { queryOptions } from "@tanstack/react-query"

import { fetchAccount } from "@/api/account/account"
import { fetchAccountOptions } from "@/api/account/options"

export const accountQueryKeys = {
	all: ["account"] as const,
	detail: ["account", "detail"] as const,
	options: ["account", "options"] as const,
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
