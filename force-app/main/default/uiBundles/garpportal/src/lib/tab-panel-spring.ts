/**
 * Lightweight panel swap so card `useTrail` stagger can own the enter motion.
 * Exit finishes before enter (`exitBeforeEnter`) — no overlapping panel wipe.
 */
export const TAB_PANEL_SPRING = { mass: 0.8, tension: 420, friction: 30 }

export const TAB_PANEL_TRANSITION = {
	from: { opacity: 0 },
	enter: { opacity: 1 },
	leave: { opacity: 0 },
	config: TAB_PANEL_SPRING,
	exitBeforeEnter: true as const,
}
