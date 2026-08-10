import type { QueryClient } from "@tanstack/react-query"

import { contactPreferencesQueryKeys } from "@/api/contact-preferences"

/** Refresh Contact Preferences after email stamp / SMS save. */
export async function invalidateContactPreferencesCaches(
	queryClient: QueryClient,
	contactId: string,
): Promise<void> {
	await queryClient.invalidateQueries({
		queryKey: contactPreferencesQueryKeys.detail(contactId.trim()),
	})
}
