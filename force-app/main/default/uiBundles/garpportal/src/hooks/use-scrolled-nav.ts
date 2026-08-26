import { useSyncExternalStore } from "react"

/*
 * Past this the fixed bars gain their shadow lift. www.garp.org flips its
 * `scrolled` class at ~45px (the height of its utility strip); we have no
 * strip above the bar, so the lift lands as soon as content would start
 * passing underneath.
 */
const SCROLLED_NAV_THRESHOLD_PX = 16

function subscribe(callback: () => void) {
	window.addEventListener("scroll", callback, { passive: true })
	return () => window.removeEventListener("scroll", callback)
}

/*
 * Boolean snapshot, not the scroll offset: `useSyncExternalStore` re-renders
 * only when the snapshot changes, so subscribers pay for the two crossings of
 * the threshold rather than for every scrolled pixel.
 */
const getSnapshot = () => window.scrollY > SCROLLED_NAV_THRESHOLD_PX

/**
 * Whether the window has scrolled past the top-of-page band — the signal the
 * fixed toolbars use to lift with a shadow once content passes beneath them,
 * mirroring www.garp.org's scrolled-nav change. The document is the scroll
 * container in both layouts; forms that scroll internally simply never trip
 * it, which is right — nothing ever passes under the bar there.
 */
function useScrolledNav() {
	return useSyncExternalStore(subscribe, getSnapshot, () => false)
}

export { useScrolledNav }
