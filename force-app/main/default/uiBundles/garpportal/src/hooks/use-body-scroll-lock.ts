import { useLayoutEffect } from "react"

/**
 * Freezes page scroll behind a full-screen overlay.
 *
 * `position: fixed` is what actually stops iOS Safari from rubber-banding the
 * page under the overlay, but it also discards the scroll offset — so the offset
 * is captured on lock and restored on unlock. Without that, closing the mobile
 * menu drops the member back at the top of whatever page they were reading.
 */
export function useBodyScrollLock(locked: boolean) {
	useLayoutEffect(() => {
		if (!locked) return

		const { body } = document
		const scrollY = window.scrollY
		const previous = {
			overflow: body.style.overflow,
			position: body.style.position,
			top: body.style.top,
			width: body.style.width,
		}

		body.style.overflow = "hidden"
		body.style.position = "fixed"
		body.style.top = `-${scrollY}px`
		body.style.width = "100%"

		return () => {
			body.style.overflow = previous.overflow
			body.style.position = previous.position
			body.style.top = previous.top
			body.style.width = previous.width
			window.scrollTo(0, scrollY)
		}
	}, [locked])
}
