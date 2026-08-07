import { useLocation } from "@tanstack/react-router"
import { useEffect } from "react"

import { useNavigationStore } from "@/store/navigation-store"

/**
 * The mobile nav panel has no way to know a `Link` inside it was clicked without
 * threading an onClick through every nav item — closing it on route change instead
 * keeps the panel's own children data-driven and dumb.
 */
export function useCloseMobileNavOnNavigate() {
	const { pathname } = useLocation()
	const closeMobileNav = useNavigationStore((state) => state.closeMobileNav)

	useEffect(() => {
		closeMobileNav()
	}, [pathname, closeMobileNav])
}
