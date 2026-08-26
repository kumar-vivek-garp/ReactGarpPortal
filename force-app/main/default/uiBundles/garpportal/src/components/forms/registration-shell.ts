/**
 * The page shell every registration form is served in — shared so the exam
 * dispatcher and the affiliate form cannot drift apart.
 *
 * A registration form carries its own sticky header bar, which only works if
 * the form is the thing that scrolls rather than the document. So the shell
 * takes a fixed height (viewport minus the fixed toolbar, which is `h-16` /
 * `app:h-20` in both `_appLayout` and `_publicFormLayout`) and puts the
 * overflow on the inner column.
 *
 * `-my-6` cancels the `PageContainer`'s own `py-6`, then `py-6` puts it back
 * inside the fixed-height box — otherwise the container's padding is added to
 * a height already equal to the viewport and the page gains a scrollbar the
 * shell was built to remove.
 */
export const REGISTRATION_SHELL =
	"-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"

/**
 * The scrolling column, flush to the top — a form with its own sticky bar must
 * start at the top of its scroll parent or the bar has nothing to stick to.
 *
 * The horizontal padding is not cosmetic. `overflow-y-auto` also clips the X
 * axis, and the back link inside the bar nudges 5px left on hover; sitting
 * flush against this edge, that nudge would be cut off.
 */
export const REGISTRATION_SCROLL =
	"min-h-0 flex-1 overflow-y-auto overscroll-contain px-2 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"

/**
 * The checkout split: form on the left, order rail pinned on the right.
 *
 * Shared because it is written four times — the exam form, the affiliate form,
 * and a loading skeleton for each — and the four had already drifted. The exam
 * skeleton was laid out 70/30 against a 60/40 form, so the whole page shifted
 * sideways the moment the payload landed. A skeleton's only job is to not do
 * that.
 *
 * Ten columns rather than five so the 60/40 is expressible at all: `col-span-6`
 * and `col-span-4` of ten.
 */
export const REGISTRATION_GRID = "grid grid-cols-1 gap-6 lg:grid-cols-10"

export const REGISTRATION_MAIN_COLUMN = "flex flex-col gap-6 lg:col-span-6"

/**
 * `h-fit` + `sticky` is what pins the rail: it sizes to its content and stays
 * put while the form column scrolls past it.
 *
 * `top-22` is not a taste choice — it must equal the element's natural offset,
 * the sticky bar (4rem) plus the grid gap (1.5rem). A `sticky` element with a
 * `top` *larger* than its natural offset is pushed down immediately, at rest,
 * on first paint: at `top-28` the rail sat 24px below the column beside it.
 *
 * Coupled to the rail's own `max-h-[calc(100vh-13.5rem)]` — change this offset
 * and that cap has to follow, or the rail overhangs its slot and clips.
 */
export const REGISTRATION_RAIL_COLUMN =
	"lg:sticky lg:top-22 lg:col-span-4 lg:h-fit"

/**
 * The one bar carrying the title, the running total and the submit.
 *
 * Fully opaque: content scrolling under a translucent bar reads as a rendering
 * fault rather than as depth. No negative margin: bleeding it past the
 * container makes it wider than its scroll parent, which buys a few pixels of
 * horizontal scroll and clips the back arrow.
 */
export const REGISTRATION_STICKY_BAR =
	"sticky top-0 z-30 flex flex-wrap items-center justify-between gap-x-6 gap-y-3 bg-background py-3"

/**
 * The total block, and the submit beside it.
 *
 * `h-10` is the height of a `size="lg"` Button, and the total block is pinned
 * to it so neither the arrival of a price nor a longer figure moves the bar.
 * A skeleton that guesses `h-11` here makes the header jump by 4px on load.
 */
export const REGISTRATION_BAR_CONTROL_HEIGHT = "h-10"
