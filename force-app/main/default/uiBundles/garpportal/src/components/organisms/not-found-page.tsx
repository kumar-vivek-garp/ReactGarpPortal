import { useEffect } from "react"
import { useRouterState } from "@tanstack/react-router"

import { BootSplashScreen } from "@/components/molecules/route-pending-fallback"
import { AppLayoutShell } from "@/components/organisms/app-layout-shell"
import { NotFoundPanel } from "@/components/organisms/not-found-panel"
import { PublicShell } from "@/components/organisms/public-shell"
import { useCurrentUser } from "@/hooks/use-current-user"
import { pageTitle } from "@/lib/document-title"

/**
 * The root route's `notFoundComponent` — session-aware, because an unknown URL
 * matches no layout and therefore no guard has resolved who is looking.
 *
 * A member gets the full portal chrome with the 404 in the content area; a
 * guest gets the public toolbar with Sign In. While the session resolves on a
 * cold load, `BootSplashScreen` renders — pixel-identical to the HTML
 * `#boot-splash` still covering it — and the splash is dismissed by whichever
 * shell then mounts, so it fades directly into the correct chrome. This is
 * also what un-sticks the boot splash on unknown URLs: without a mounted
 * layout, nothing else would ever dismiss it.
 *
 * A failed session probe renders the guest branch: `fetchCurrentUser` resolves
 * `null` rather than throwing for guests, and a transport error leaves `data`
 * undefined, which lands in the same branch without a toast.
 */
function NotFoundPage() {
	const { data: user, isPending } = useCurrentUser()
	const pathname = useRouterState({ select: (state) => state.location.pathname })

	// Not a route, so there is no `head()` — set the title imperatively;
	// HeadContent reasserts the next route's title on navigation away.
	useEffect(() => {
		document.title = pageTitle("Page Not Found")
	}, [])

	if (isPending) {
		return <BootSplashScreen />
	}

	return user ? (
		<AppLayoutShell>
			<NotFoundPanel variant="member" attemptedPath={pathname} />
		</AppLayoutShell>
	) : (
		<PublicShell>
			<NotFoundPanel variant="guest" attemptedPath={pathname} />
		</PublicShell>
	)
}

export { NotFoundPage }
