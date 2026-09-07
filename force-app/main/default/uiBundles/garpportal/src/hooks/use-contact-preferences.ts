import { useQuery } from "@tanstack/react-query"

import { accountQueryOptions } from "@/api/account/query-options"
import { toContactPreferences } from "@/api/contact-preferences"

/** Contact Preferences tab hydrate (SMS + display email/mobile), off the shared account query. */
export function useContactPreferences(enabled = true) {
	return useQuery({
		...accountQueryOptions,
		select: toContactPreferences,
		enabled,
	})
}
