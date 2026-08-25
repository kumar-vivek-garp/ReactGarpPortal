/**
 * Motion vocabulary for the app chrome (top nav, mega-menu, mobile panel).
 *
 * Deliberately near-critically damped: the nav is the one surface a member sees
 * on every page, so it should settle rather than wobble. Overshoot is reserved
 * for content-level feedback (`use-spring-press`, `use-spring-nudge`).
 *
 * Reduced motion is handled globally by `useReducedMotion()` in `pages/__root.tsx`.
 */

/** Panel / sheet open + close. Crisp arrival, no visible bounce. */
export const NAV_PANEL_SPRING = { mass: 0.7, tension: 400, friction: 32 } as const

/**
 * Menu → menu travel: the open mega-menu glides and resizes to the next trigger
 * rather than unmounting and reappearing. Stiffer than the open spring so the
 * move reads as one continuous object, not a second animation.
 */
export const NAV_MORPH_SPRING = { mass: 0.6, tension: 460, friction: 36 } as const

/** Content cross-fade inside the panel, and the column trail on first open. */
export const NAV_CONTENT_SPRING = { mass: 0.6, tension: 420, friction: 30 } as const

/**
 * Sidebar rail collapse / expand.
 *
 * Damping ratio ~1.03 — deliberately the one spring in this file with *no*
 * overshoot at all. The value it drives is a layout width, so the content
 * column reflows off it every frame; even the small bounce `NAV_PANEL_SPRING`
 * allows would read as the whole page rebounding rather than a panel settling.
 */
export const NAV_RAIL_SPRING = { mass: 0.8, tension: 340, friction: 34 } as const
