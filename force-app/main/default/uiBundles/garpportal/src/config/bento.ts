/**
 * Static contract for the reorderable bento grid. Deliberately knows nothing
 * about any particular page — a new page adopts the grid by adding a scope here
 * and passing its own item registry.
 */

/** One persisted layout per scope. Add a page here to give it a rememberable grid. */
export const BENTO_SCOPES = ["account-information"] as const

export type BentoScope = (typeof BENTO_SCOPES)[number]




/**
 * Two columns from Tailwind's `xl` up, one below. Measured on the real page: a
 * row grid wasted 395px of ragged whitespace and equalising the columns made it
 * worse, while masonry wastes none — but three columns squeezes cards to 379px,
 * which is too narrow for the two-column field grids inside them. Two columns at
 * ~581px is the width that stays readable.
 */
export const BENTO_COLUMN_QUERY = "(min-width: 80rem)"

/** localStorage key for remembered layouts. */
export const BENTO_STORAGE_KEY = "garp-portal:bento-layout"

/** Bump with any breaking change to the persisted shape. */
export const BENTO_STORAGE_VERSION = 2

/** How close to the scroll container's edge a drag must get to auto-scroll, px. */
export const BENTO_AUTOSCROLL_ZONE_PX = 72

/**
 * Peak auto-scroll speed, px per **second**.
 *
 * A rate, not a per-frame nudge: 14px/frame is 840px/s on a 60Hz display and
 * 1680px/s on a 120Hz one, so the same gesture scrolled twice as fast on newer
 * hardware.
 */
export const BENTO_AUTOSCROLL_MAX_PX_PER_SEC = 900

/**
 * Dead-band around a drop target's edge, px. Without it, dragging along a
 * boundary strobes: reorder -> FLIP -> the layout moves under the cursor ->
 * reorder back.
 */
export const BENTO_HYSTERESIS_PX = 10
