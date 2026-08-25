/**
 * Motion curve for the collapsible app sidebar.
 *
 * One spring drives the whole collapse: a single progress value `t` where 0 is
 * fully expanded and 1 is fully collapsed. Everything the rail animates is
 * derived from it here, so the label fade is *physically coupled* to the
 * travelling edge rather than being a second, independently timed animation
 * that could drift out of step with it.
 *
 * Pure and side-effect free so the curve is unit-testable without mounting the
 * sidebar — the same split `program-listing-presentation` and `bento-masonry`
 * use.
 */

/** Expanded rail width. Mirrors `--spacing-shell-rail` in `styles/theme.css`. */
export const RAIL_WIDTH_PX = 294

/**
 * Collapsed rail width. Mirrors `--spacing-shell-rail-collapsed`.
 *
 * = shell-inset (24) + puck (44) + row px-3 (12) + container p-3 (12). At this
 * width the icon puck's left edge is unchanged, so nothing slides sideways.
 */
export const RAIL_COLLAPSED_WIDTH_PX = 92

/**
 * How much faster the labels fade than the edge travels.
 *
 * > 1 so text has fully vanished before the closing edge reaches it — a label
 * caught mid-clip reads as a rendering fault, not as motion.
 */
const LABEL_FADE_LEAD = 1.9

/** How far labels drift left as they go, in px. Small: a pull, not a slide. */
const LABEL_TRAVEL_PX = 8

function clamp01(value: number): number {
	if (Number.isNaN(value)) return 0
	if (value < 0) return 0
	if (value > 1) return 1
	return value
}

/** Rail width in px at progress `t`. */
export function railWidthAt(t: number): number {
	const progress = clamp01(t)
	return (
		RAIL_WIDTH_PX - progress * (RAIL_WIDTH_PX - RAIL_COLLAPSED_WIDTH_PX)
	)
}

/** Label opacity at progress `t`. Reaches 0 before the edge arrives. */
export function labelOpacityAt(t: number): number {
	return clamp01(1 - clamp01(t) * LABEL_FADE_LEAD)
}

/** Label x-offset in px at progress `t`. Negative — labels lead the edge in. */
export function labelOffsetAt(t: number): number {
	return -LABEL_TRAVEL_PX * clamp01(t)
}
