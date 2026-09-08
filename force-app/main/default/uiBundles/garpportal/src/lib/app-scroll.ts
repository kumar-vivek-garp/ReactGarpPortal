/**
 * The one element that scrolls.
 *
 * Both shells (`AppLayoutShell`, `PublicShell`) frame the viewport and put the
 * overflow on their main column, so the document itself never scrolls: the
 * toolbar and the sidebar are outside that column and stay put by construction
 * rather than by each page pinning itself to `h-[calc(100vh-4rem)]` and opening
 * a scroller of its own. Twenty-four panels and skeletons used to carry that
 * arithmetic, and the footer — which lives below the page in the same column —
 * was stranded outside every one of them.
 *
 * Addressed by DOM id rather than by a ref in context because the things that
 * need it are mostly *outside* it in the React tree: the fixed toolbar's
 * shadow-lift, the footer's back-to-top, the mobile menu's scroll lock. The id
 * is also what the router's `scrollToTopSelectors` takes, so one constant feeds
 * both.
 *
 * Exactly one shell is mounted at a time, so the id stays unique.
 */
export const APP_SCROLL_ID = "app-scroll"

/** The live scroller, or `null` before the shell has mounted. */
export function getAppScroller(): HTMLElement | null {
	return document.getElementById(APP_SCROLL_ID)
}

/** CSS selector form — for `createRouter`'s `scrollToTopSelectors`. */
export const APP_SCROLL_SELECTOR = `#${APP_SCROLL_ID}`
