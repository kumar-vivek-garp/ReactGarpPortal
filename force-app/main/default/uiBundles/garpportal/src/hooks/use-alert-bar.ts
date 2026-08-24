import { useMemo, useState } from "react"
import { useQuery } from "@tanstack/react-query"

import { alertBarQueryOptions } from "@/api/alert-bar"
import { toAlertBarModel } from "@/lib/alert-bar-presentation"

/**
 * The portal-wide exam alert, plus its collapsed/expanded state.
 *
 * Collapse is keyed on the alert itself rather than held as a bare boolean.
 * These are deadlines, so a member who has collapsed "you have not booked a
 * seat" must still be shown the *next* alert when that one is resolved and a
 * different one takes its place — keying on the status makes that automatic
 * instead of something an effect has to notice.
 *
 * The state is deliberately in-memory. It lasts as long as the layout is
 * mounted, so it survives navigation between pages but not a reload, and a
 * deadline therefore reasserts itself on the member's next visit. That is the
 * point: this collapses, it does not dismiss.
 */
export function useAlertBar() {
	const { data } = useQuery(alertBarQueryOptions)
	const [collapsedFor, setCollapsedFor] = useState<string | null>(null)

	const model = useMemo(() => toAlertBarModel(data), [data])
	const key = data?.alertStatus?.trim() ?? null

	return {
		model,
		isCollapsed: key !== null && collapsedFor === key,
		collapse: () => setCollapsedFor(key),
		expand: () => setCollapsedFor(null),
	}
}
