/**
 * Nearest ancestor that actually scrolls, or null when the page itself does.
 *
 * Extracted from `use-spring-scroll-to` so the spotlight glide and the bento
 * drag auto-scroller resolve the same container — the My Account panel body is
 * an `overflow-y-auto` div rather than the document, and two different answers
 * to "what scrolls here" would have them fighting each other.
 */
export function scrollParent(node: HTMLElement): HTMLElement | null {
	let current = node.parentElement
	while (current) {
		const { overflowY } = window.getComputedStyle(current)
		const scrollable = overflowY === "auto" || overflowY === "scroll"
		if (scrollable && current.scrollHeight > current.clientHeight)
			return current
		current = current.parentElement
	}
	return null
}
