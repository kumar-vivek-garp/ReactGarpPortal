import type { ParsedLocation } from "@tanstack/react-router"

/** Build a same-app path for post-login return (pathname + search string only). */
export function getReturnPath(location: Pick<ParsedLocation, "pathname" | "searchStr">): string {
	const search = location.searchStr?.startsWith("?")
		? location.searchStr
		: location.searchStr
			? `?${location.searchStr}`
			: ""
	return `${location.pathname}${search}`
}
