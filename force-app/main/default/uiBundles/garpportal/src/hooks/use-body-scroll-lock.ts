import { useLayoutEffect } from "react"

import { getAppScroller } from "@/lib/app-scroll"

/**
 * Freezes the app behind a full-screen overlay.
 *
 * The document no longer scrolls — the shell frames the viewport and puts the
 * overflow on its main column (`lib/app-scroll.ts`) — so the old
 * `position: fixed` body trick has nothing to hold still, and setting it would
 * now knock the frame itself out of flow. Clipping the scroller is both the
 * smaller change and the one that actually stops iOS Safari rubber-banding the
 * page under the overlay.
 *
 * `overflow: hidden` preserves `scrollTop`, but it is captured and restored
 * anyway: a browser is entitled to clamp the offset while the box is
 * unscrollable, and closing the mobile menu must not drop the member back at
 * the top of whatever they were reading.
 */
export function useBodyScrollLock(locked: boolean) {
	useLayoutEffect(() => {
		if (!locked) return

		const scroller = getAppScroller()
		if (!scroller) return

		const previousOverflow = scroller.style.overflow
		const offset = scroller.scrollTop
		scroller.style.overflow = "hidden"

		return () => {
			scroller.style.overflow = previousOverflow
			scroller.scrollTop = offset
		}
	}, [locked])
}
