/**
 * Whether `pathname` is on or under `to`.
 *
 * Shared by the sidebar rows and the sliding indicator that highlights them, so
 * the row that looks active and the row the indicator lands on can never
 * disagree. Matches on segment boundaries — `/programs` must not light up for
 * `/programs-archive`.
 */
export function isRouteActive(pathname: string, to: string): boolean {
	return pathname === to || pathname.startsWith(`${to}/`)
}

/** First matching route in `routes`, or null when none match. */
export function activeRouteKey<T extends string>(
	pathname: string,
	routes: ReadonlyArray<T>,
): T | null {
	return routes.find((route) => isRouteActive(pathname, route)) ?? null
}
