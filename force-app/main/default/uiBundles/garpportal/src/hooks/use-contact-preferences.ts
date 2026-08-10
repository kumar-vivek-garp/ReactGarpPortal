import { useQuery } from "@tanstack/react-query"

import { contactPreferencesQueryOptions } from "@/api/contact-preferences"

/** Contact Preferences tab hydrate (SMS + display email/mobile). */
export function useContactPreferences(contactId: string, enabled = true) {
	return useQuery({
		...contactPreferencesQueryOptions(contactId),
		enabled: enabled && Boolean(contactId.trim()),
	})
}
