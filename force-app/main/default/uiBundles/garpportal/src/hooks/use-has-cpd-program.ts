import { useQuery } from "@tanstack/react-query"

import { programsQueryOptions } from "@/api/programs"

/**
 * Whether to show CPD in the navigation.
 *
 * Reads `hasCPDProgram` off `GET programs` — the same flag the legacy side nav
 * gated on. `programs` is already loaded by `/dashboard` and `/programs`, the
 * two common landings, and `staleTime` keeps this to at most one extra request
 * per minute elsewhere. `select` narrows to a boolean so the nav re-renders
 * only when the answer flips, not on every payload identity change.
 */
export function useHasCpdProgram(): boolean {
	const { data } = useQuery({
		...programsQueryOptions,
		select: (view) => view.hasCPDProgram === true,
	})
	return data === true
}
