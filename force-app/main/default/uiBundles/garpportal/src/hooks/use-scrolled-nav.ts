import { useSyncExternalStore } from "react"

import { getAppScroller } from "@/lib/app-scroll"

/*
 * Past this the fixed bars gain their shadow lift. www.garp.org flips its
 * `scrolled` class at ~45px (the height of its utility strip); we have no
 * strip above the bar, so the lift lands as soon as content would start
 * passing underneath.
 */
const SCROLLED_NAV_THRESHOLD_PX = 16

/*
 * The shell's main column is the scroller, not the document, so the listener
 * goes on the element. It exists by the time this runs: `useSyncExternalStore`
 * subscribes in an effect, and effects fire after the whole tree — scroller
 * included — is in the DOM.
 *
 * `window` is kept as the fallback target purely so the hook is inert rather
 * than broken in a test that renders the toolbar without a shell around it.
 */
function subscribe(callback: () => void) {
	const target: EventTarget = getAppScroller() ?? window
	target.addEventListener("scroll", callback, { passive: true })
	return () => target.removeEventListener("scroll", callback)
}

/*
 * Boolean snapshot, not the scroll offset: `useSyncExternalStore` re-renders
 * only when the snapshot changes, so subscribers pay for the two crossings of
 * the threshold rather than for every scrolled pixel.
 */
const getSnapshot = () =>
	(getAppScroller()?.scrollTop ?? 0) > SCROLLED_NAV_THRESHOLD_PX

/**
 * Whether the app has scrolled past the top-of-page band — the signal the
 * fixed toolbars use to lift with a shadow once content passes beneath them,
 * mirroring www.garp.org's scrolled-nav change.
 */
function useScrolledNav() {
	return useSyncExternalStore(subscribe, getSnapshot, () => false)
}

export { useScrolledNav }
