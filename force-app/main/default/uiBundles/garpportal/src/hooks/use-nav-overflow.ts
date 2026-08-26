import { useCallback, useLayoutEffect, useMemo, useRef, useState } from "react"

/** Reserved registry key for the "More" trigger's measuring copy. */
export const NAV_OVERFLOW_KEY = "__more__"

type UseNavOverflowOptions<T> = {
	items: T[]
	getKey: (item: T) => string
	/**
	 * The row's flex `gap`, in px. Measuring copies are absolutely positioned
	 * individuals, so their offsetWidths can never include the live row's gaps —
	 * the caller must declare the same value it styles the row with, or items
	 * overflow the container before "More" collapses them.
	 */
	gapPx?: number
}

/**
 * Splits a nav row into what fits and what doesn't.
 *
 * Widths come from a hidden measuring row rather than the live one, so a
 * measurement never depends on what is currently rendered — otherwise hiding an
 * item frees space, which un-hides it, which fills the space again.
 *
 * The container is sized by its flex parent (`flex-1 min-w-0`), not by its
 * children, so changing the visible count cannot feed back into the available
 * width and oscillate.
 */
export function useNavOverflow<T>({ items, getKey, gapPx = 0 }: UseNavOverflowOptions<T>) {
	const containerRef = useRef<HTMLDivElement | null>(null)
	const measureRefs = useRef(new Map<string, HTMLElement>())
	const [visibleCount, setVisibleCount] = useState(items.length)

	const keys = useMemo(() => items.map(getKey), [items, getKey])
	const itemsKey = keys.join("|")

	const registerMeasureRef = useCallback((key: string, node: HTMLElement | null) => {
		if (node) measureRefs.current.set(key, node)
		else measureRefs.current.delete(key)
	}, [])

	const measure = useCallback(() => {
		const container = containerRef.current
		if (!container) return
		const available = container.clientWidth
		// Zero means the whole toolbar is display:none (below the `app:` breakpoint)
		// — measuring there would collapse everything into "More" for nothing.
		if (available === 0) return

		const list = itemsKey ? itemsKey.split("|") : []
		const widths = list.map((key) => measureRefs.current.get(key)?.offsetWidth ?? 0)
		if (widths.some((width) => width === 0)) return

		const total =
			widths.reduce((sum, width) => sum + width, 0) +
			gapPx * Math.max(0, widths.length - 1)
		if (total <= available) {
			setVisibleCount(list.length)
			return
		}

		// One extra gap reserved for the seam before "More" itself.
		const budget =
			available - (measureRefs.current.get(NAV_OVERFLOW_KEY)?.offsetWidth ?? 0) - gapPx
		let used = 0
		let count = 0
		for (const width of widths) {
			const needed = count === 0 ? width : gapPx + width
			if (used + needed > budget) break
			used += needed
			count += 1
		}
		setVisibleCount(count)
	}, [itemsKey, gapPx])

	useLayoutEffect(() => {
		measure()

		const container = containerRef.current
		if (!container || typeof ResizeObserver === "undefined") return

		const observer = new ResizeObserver(measure)
		observer.observe(container)
		// Label widths change when the webfont swaps in, which resizes the
		// measuring copies rather than the container.
		for (const node of measureRefs.current.values()) observer.observe(node)
		return () => observer.disconnect()
	}, [measure, itemsKey])

	const visibleItems = useMemo(() => items.slice(0, visibleCount), [items, visibleCount])
	const overflowItems = useMemo(() => items.slice(visibleCount), [items, visibleCount])

	return {
		containerRef,
		registerMeasureRef,
		visibleItems,
		overflowItems,
		hasOverflow: overflowItems.length > 0,
	}
}
