/**
 * The shape of a page inside `AppLayoutShell` — no height, no overflow.
 *
 * These replace the `-my-6 h-[calc(100vh-4rem)] … overflow-y-auto` wrapper that
 * fourteen panels and their nine skeletons each declared for themselves. That
 * wrapper existed to give a page a header which stays put while its cards move,
 * and it bought that with a second scroll container stacked inside the
 * document's — which left the footer outside every one of them and gave the
 * portal two scrollbars where it wanted one.
 *
 * The shell now owns the only scroller (`lib/app-scroll.ts`), so a page is
 * ordinary content again and the pinned header is just `position: sticky`.
 */

/**
 * A page's root. `gap-0` is for the Radix `Tabs` roots that use this — they
 * carry a default gap that would otherwise double the header's own spacing.
 */
export const PAGE_SHELL = "flex flex-col gap-0"

/*
 * The pinning itself.
 *
 * `sticky` is confined to its parent's box, and the parent here is the page —
 * not the scroller — so the header releases and scrolls away once the footer
 * comes up. That is the behaviour we want, and it costs nothing to get.
 *
 * The margins are what make it opaque rather than merely coloured:
 * `PageContainer` pads `py-6` / `px-shell-gutter`, so without pulling back over
 * that padding the content would show through a 24px band above the header and
 * a 16px strip down each side while it is pinned. `-mt-6 pt-6` trades the
 * container's top padding for the header's own, which keeps the resting layout
 * identical to the fixed-height shell it replaced.
 */
const PAGE_STICKY_HEADER_BASE =
	"sticky top-0 z-20 -mx-shell-gutter -mt-6 bg-linear-to-b from-surface-gradient-start to-background px-shell-gutter pt-6"

/**
 * A page header that pins while the page's content passes beneath it.
 *
 * The bottom padding is the gap the content used to carry as its own `mt-6`.
 * It has to live on the header: a margin on the content scrolls away with the
 * content, and the first card would then touch the pinned title.
 */
export const PAGE_STICKY_HEADER = `${PAGE_STICKY_HEADER_BASE} pb-6`

/**
 * Same, for the detail-page chrome (`ProgramsSubpageHeader` and friends), whose
 * content sat at `mt-4` rather than `mt-6`.
 */
export const PAGE_STICKY_SUBHEADER = `${PAGE_STICKY_HEADER_BASE} pb-4`
