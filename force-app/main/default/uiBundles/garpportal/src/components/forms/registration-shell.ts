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
