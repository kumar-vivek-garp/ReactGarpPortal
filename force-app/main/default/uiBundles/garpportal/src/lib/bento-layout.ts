/**
 * A grid item's layout box, in container coordinates.
 *
 * Measured from `offsetLeft`/`offsetTop`, never `getBoundingClientRect()`:
 * offsets report *layout* position, so they are immune both to the spring
 * transform every card permanently carries and to the `overflow-y-auto` panel
 * scrolling between two reads. Same call, for the same reasons, as
 * `use-sliding-indicator`. The cost is integer rounding — under a pixel, and
 * invisible on a card-length glide.
 */
export type BentoRect = {
	left: number
	top: number
	width: number
	height: number
}
