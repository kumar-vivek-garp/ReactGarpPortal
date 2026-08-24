import { queryOptions } from "@tanstack/react-query"

import { fetchAlertBar } from "@/api/alert-bar/alert-bar"

export const alertBarQueryKeys = {
	all: ["alert-bar"] as const,
	view: ["alert-bar", "view"] as const,
}

/**
 * The portal-wide exam alert.
 *
 * Mounted once in the app layout, so a long `staleTime` means this is fetched
 * about once per session rather than once per navigation — which is why we do
 * not route it through Apex's `POST /batch` the way GarpAppv1 does. Batching
 * would trade a per-transaction governor budget shared across twelve actions
 * for a saving React Query already gives us.
 *
 * `toastError: false` is not an oversight. This renders on every page; a
 * failing alert service must never toast over the page the member actually
 * asked for. It fails by not rendering.
 */
export const alertBarQueryOptions = queryOptions({
	queryKey: alertBarQueryKeys.view,
	queryFn: fetchAlertBar,
	staleTime: 5 * 60_000,
	retry: false,
	meta: {
		toastError: false,
		errorTitle: "Unable to load your alerts",
	},
})
