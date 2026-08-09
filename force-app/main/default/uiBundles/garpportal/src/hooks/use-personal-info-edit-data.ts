import { useQuery } from "@tanstack/react-query"

import { personalInfoEditQueryOptions } from "@/api/personal-info/query-options"

/** Contact + Account hydrate for the Personal Information edit dialog. */
export function usePersonalInfoEditData(contactId: string, enabled = true) {
	return useQuery({
		...personalInfoEditQueryOptions(contactId),
		enabled: enabled && Boolean(contactId.trim()),
	})
}
