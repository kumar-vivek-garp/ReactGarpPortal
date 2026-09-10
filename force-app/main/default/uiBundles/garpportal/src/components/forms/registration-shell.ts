import { PAGE_SHELL } from "@/components/molecules/page-shell"

/**
 * The page shell every registration form is served in — shared so the exam
 * dispatcher and the affiliate form cannot drift apart.
 *
 * It used to take a fixed height (viewport minus the toolbar) and put the
 * overflow on an inner column, because a form with a sticky bar only works if
 * something other than the document is scrolling. The shell now provides that
 * for every page (`lib/app-scroll.ts`), so this is the same `PAGE_SHELL` the
 * rest of the portal uses and the bar sticks to the shell's scroller.
 *
 * Kept as its own name rather than collapsed into the import: six panels and
 * two skeletons read it, and the alias documents that a registration form is
 * shaped exactly like every other page — which was the thing in doubt.
 */
export const REGISTRATION_SHELL = PAGE_SHELL

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
 * `top-28` is not a taste choice — it must equal the element's natural offset,
 * measured from the top of whatever scrolls. That is now the shell's column
 * rather than a scroller this form owned, so the offset gained the container's
 * own top padding: 1.5rem `PageContainer` padding + 4rem of bar + 1.5rem grid
 * gap = 7rem. (It read `top-22` when the scroller started *below* that
 * padding; the bar itself has not moved.) A `sticky` element with a `top`
 * *larger* than its natural offset is pushed down immediately, at rest, on
 * first paint — which is what `top-28` did under the old geometry and what
 * `top-22` would do under this one.
 *
 * Coupled to the rail's own `max-h-[calc(100vh-13.5rem)]`, which still holds:
 * the scroller is `100vh` less the 5rem toolbar, the rail starts 7rem into it,
 * and the last 1.5rem is the container's bottom padding.
 */
export const REGISTRATION_RAIL_COLUMN =
	"lg:sticky lg:top-28 lg:col-span-4 lg:h-fit"

/**
 * The one bar carrying the title, the running total and the submit.
 *
 * Fully opaque: content scrolling under a translucent bar reads as a rendering
 * fault rather than as depth.
 *
 * The bleed is what makes "opaque" true. `PageContainer` pads `py-6` /
 * `px-shell-gutter` and the bar is now pinned against the *shell's* scroller,
 * so without pulling back over that padding the form would be visible through
 * a 24px band above the bar and a 16px strip down each side while it is
 * pinned. The old warning here — that a negative margin makes the bar wider
 * than its scroll parent, buying horizontal scroll and clipping the back arrow
 * — was true of the inner scroller this form used to own, whose `overflow-y`
 * clipped the X axis too. `-mx-shell-gutter` exactly cancels the container's
 * gutter rather than exceeding it, and nothing clips, so the arrow's 5px hover
 * nudge has room again.
 *
 * `pt-9 pb-3` rather than `py-3`: the 24px the container used to hold above
 * the bar is now the bar's own, which keeps the resting layout pixel-identical
 * to the fixed-height shell this replaced and keeps the bar exactly 5.5rem
 * tall. `REGISTRATION_RAIL_COLUMN` is derived from that height — change either
 * number and the rail's `top` has to follow.
 */
export const REGISTRATION_STICKY_BAR =
	"sticky top-0 z-30 -mx-shell-gutter -mt-6 flex flex-wrap items-center justify-between gap-x-6 gap-y-3 bg-background px-shell-gutter pt-9 pb-3"

/**
 * The total block, and the submit beside it.
 *
 * `h-10` is the height of a `size="lg"` Button, and the total block is pinned
 * to it so neither the arrival of a price nor a longer figure moves the bar.
 * A skeleton that guesses `h-11` here makes the header jump by 4px on load.
 */
export const REGISTRATION_BAR_CONTROL_HEIGHT = "h-10"

/*
 * The bar's two inner groups. On a phone the bar cannot be one line — the
 * title alone nearly fills the width — so it becomes exactly two rows: the
 * title group takes the first (back link + title), and the control group takes
 * the second full-width (total on the left, the submit growing to fill the
 * rest). From `sm` up both collapse back into the single strip. Shared by
 * every form *and its skeleton* so the two cannot wrap differently.
 */
export const REGISTRATION_BAR_TITLE_GROUP =
	"flex w-full min-w-0 items-center gap-4 sm:w-auto sm:flex-1"

export const REGISTRATION_BAR_CONTROL_GROUP =
	"flex w-full items-center gap-4 sm:w-auto"

/** Left-aligned under the title on mobile, right-aligned beside the submit on sm+. */
export const REGISTRATION_BAR_TOTAL_BLOCK =
	"flex shrink-0 flex-col items-start justify-center text-left sm:items-end sm:text-right"

/*
 * The guest layout (2027 Reg Redesign). With the title in the banner, the bar
 * has nothing left to carry but the total and the submit — and the designs do
 * not put those in a bar at all. They are the FIRST item inside the order rail,
 * directly above the upsell and summary cards.
 *
 * So the guest form drops the sticky bar entirely and the rail column becomes a
 * stack: controls, then `RegistrationRail`. The rail column is already `sticky`
 * at `lg`, which is what keeps the total and submit on screen there — the job
 * the bar used to do.
 */
export const REGISTRATION_RAIL_STACK = "flex flex-col gap-6"

/*
 * `order-last` below `lg`: the rail stacks UNDER the form on a phone, so first
 * in the column would put the submit between the form and the order summary —
 * asking for payment before showing what is being paid for. Last puts it after
 * the summary, which is the order a checkout normally runs in. `lg:order-first`
 * restores the designed position once the column is beside the form.
 */
export const REGISTRATION_RAIL_CONTROLS =
	"order-last flex w-full items-center justify-between gap-4 lg:order-first"

/** In the rail the total leads the row, so it stays left-aligned throughout. */
export const REGISTRATION_BAR_TOTAL_LEADING = "sm:items-start sm:text-left"

/**
 * The guest rail column: same 40% and the same pin, but `top-6` rather than
 * `top-28`.
 *
 * `REGISTRATION_RAIL_COLUMN`'s 7rem is the sticky bar's height plus the grid
 * gap — the space the bar occupies above it. With no bar, that offset would
 * pin the rail 5.5rem below where the content starts and leave an obvious gap
 * above it once the page scrolls. 1.5rem is `PageContainer`'s own `py-6`.
 */
export const REGISTRATION_RAIL_COLUMN_GUEST =
	"lg:sticky lg:top-6 lg:col-span-4 lg:h-fit"

/** The submit fills the mobile row; sm+ returns it to its natural width. */
export const REGISTRATION_BAR_SUBMIT = "flex-1 sm:flex-none"

/**
 * Full title on desktop, one size down on a phone so less of it truncates.
 *
 * `font-sans` ExtraBold, not the heading font: this is the same programme name
 * the guest banner shows, and the 2027 designs set it in Nunito Sans ExtraBold.
 * `base.css` gives every h1 Klinic Slab at the base layer, so the family has to
 * be stated here to override it — the banner does the same, and the bar was
 * simply never brought along, leaving one string rendered in two typefaces
 * depending on which route you were on.
 *
 * The SIZE deliberately does not follow the banner's 30/40px: this bar is
 * 5.5rem tall and shares its row with the total and the submit. Family and
 * weight are what make the two read as the same thing.
 *
 * Shared with the Exam Setup and affiliate bars, which is the point — they name
 * the same programmes.
 */
export const REGISTRATION_BAR_TITLE =
	"truncate font-sans text-xl font-extrabold sm:text-2xl"

/**
 * The event forms' main column — single, centred, no rail.
 *
 * Events carry at most one fixed fee, so there is no order summary to pin
 * beside the form; reusing `REGISTRATION_GRID` with a full-width column would
 * keep a 10-column grid alive for nothing. Shared by the form, its skeleton
 * and every eligibility/outcome screen so nothing shifts when data lands.
 */
export const REGISTRATION_SINGLE_COLUMN =
	"mx-auto flex w-full max-w-3xl flex-col gap-6"
