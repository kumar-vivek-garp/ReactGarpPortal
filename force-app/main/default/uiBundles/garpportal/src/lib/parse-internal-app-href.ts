/**
 * Splits an in-app href such as `/membership?tab=directory` into a pathname
 * and search-param object for TanStack Router `Link`.
 */
export function parseInternalAppHref(url: string): {
	pathname: string
	search: Record<string, string>
} {
	const trimmed = url.trim()
	const queryIndex = trimmed.indexOf("?")
	if (queryIndex === -1) {
		return { pathname: trimmed, search: {} }
	}

	const pathname = trimmed.slice(0, queryIndex) || "/"
	const search = Object.fromEntries(
		new URLSearchParams(trimmed.slice(queryIndex + 1)),
	)
	return { pathname, search }
}
