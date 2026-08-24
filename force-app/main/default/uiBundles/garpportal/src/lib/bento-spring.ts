/**
 * Motion tokens for the reorderable bento grid, in one place so the lift, the
 * neighbour glide and the drop all read as one system — same convention as
 * `nav-spring.ts` and `tab-panel-spring.ts`.
 *
 * Reduced motion is handled globally by `useReducedMotion()` in `pages/__root.tsx`,
 * so none of these branch on it.
 */

/**
 * Pick-up. Stiff and well damped: the card should be *up* by the time the eye
 * gets there, because the lift is feedback on an action, not an animation.
 */
export const BENTO_LIFT = { mass: 0.7, tension: 420, friction: 30 } as const

/**
 * Neighbours FLIP-gliding to a new slot. Ratio ~0.75 — eases and settles rather
 * than sliding linearly and stopping dead, but stiff enough that most of the
 * travel is behind it before the next reorder can retarget it.
 */
export const BENTO_SETTLE = { mass: 0.9, tension: 340, friction: 30 } as const

/**
 * Release. Deliberately underdamped (ratio ~0.55) so the card overshoots its
 * slot a touch and rocks back — the one place in this interaction where the
 * physics should be visible as physics.
 */
export const BENTO_DROP = { mass: 1, tension: 320, friction: 22 } as const

/** Landing-slot outline. Softer than the card so it reads as a hint, not an object. */
export const BENTO_GHOST = { mass: 0.8, tension: 300, friction: 32 } as const

/** First paint. Matches `StaggerReveal` so a bento and a plain list feel alike. */
export const BENTO_REVEAL = { mass: 0.8, tension: 340, friction: 26 } as const

/** Per-slot delay on the first-paint cascade. */
export const BENTO_REVEAL_STAGGER_MS = 45

/** Reveal travel, px. */
export const BENTO_REVEAL_Y = 14

/**
 * Neighbour glides are delayed in proportion to how far they travel, so a
 * reorder reads as a wave rolling through the grid rather than everything
 * snapping at once. Capped so nothing ever feels laggy.
 */
export const BENTO_NEIGHBOUR_DELAY_PER_PX = 0.08
export const BENTO_NEIGHBOUR_DELAY_MAX_MS = 60

/** Lift geometry. */
export const BENTO_LIFT_SCALE = 1.025
/** Degrees at peak velocity. Small — a card is a heavy object, not a playing card. */
export const BENTO_TILT_MAX_DEG = 2.4
export const BENTO_TILT_PER_VELOCITY = 1.1

/** Opacity dip that masks the width snap when a card changes span. */
export const BENTO_RESIZE_DIP = 0.85
