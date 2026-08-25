import { useCallback, useEffect } from "react"
import { to, useSpring } from "@react-spring/web"

import { SIDEBAR_TOGGLE_KEY } from "@/config/navigation/sidebar"
import { NAV_RAIL_SPRING } from "@/lib/nav-spring"
import { labelOffsetAt, labelOpacityAt, railWidthAt } from "@/lib/sidebar-rail"
import { useSidebarStore } from "@/store/sidebar-store"

/** True while the member is typing, so the shortcut cannot eat a literal "b". */
function isTypingTarget(target: EventTarget | null): boolean {
	if (!(target instanceof HTMLElement)) return false
	if (target.isContentEditable) return true
	const tag = target.tagName
	return tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT"
}

/**
 * Owns the sidebar's collapse state and the single spring that expresses it.
 *
 * One `t` value (0 expanded → 1 collapsed) drives the panel width, the label
 * opacity, and the label offset via `to()`. Deriving all three from the same
 * spring is what keeps the labels' disappearance locked to the edge's travel
 * no matter how the spring is interrupted mid-flight — a second spring, or a
 * CSS transition, would visibly desynchronise on a fast double-toggle.
 *
 * Reduced motion is handled globally by `useReducedMotion()` in
 * `pages/__root.tsx`, which makes every spring here jump straight to its goal.
 */
export function useSidebarCollapse() {
	const isCollapsed = useSidebarStore((state) => state.isCollapsed)
	const toggleCollapsed = useSidebarStore((state) => state.toggleCollapsed)

	const { t } = useSpring({
		t: isCollapsed ? 1 : 0,
		config: NAV_RAIL_SPRING,
	})

	useEffect(() => {
		const onKeyDown = (event: KeyboardEvent) => {
			if (!(event.metaKey || event.ctrlKey) || event.altKey) return
			if (event.key.toLowerCase() !== SIDEBAR_TOGGLE_KEY) return
			if (isTypingTarget(event.target)) return
			event.preventDefault()
			toggleCollapsed()
		}
		window.addEventListener("keydown", onKeyDown)
		return () => window.removeEventListener("keydown", onKeyDown)
	}, [toggleCollapsed])

	const toggle = useCallback(() => toggleCollapsed(), [toggleCollapsed])

	return {
		isCollapsed,
		toggle,
		/** Spread onto the `animated.aside`. */
		widthStyle: { width: to(t, railWidthAt) },
		/** Spread onto every `animated` label inside the rail. */
		labelStyle: {
			opacity: to(t, labelOpacityAt),
			x: to(t, labelOffsetAt),
		},
	}
}

/** Animated label styles handed to the rail's row molecules. */
export type SidebarLabelStyle = ReturnType<typeof useSidebarCollapse>["labelStyle"]
