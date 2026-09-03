import type { KeyboardEvent as ReactKeyboardEvent } from "react"
import { act, renderHook } from "@testing-library/react"
import { beforeEach, describe, expect, it } from "vitest"

import {
	BENTO_INSTRUCTIONS_ID,
	useBentoColumns,
	useBentoLayout,
	type BentoItemMeta,
} from "@/hooks/use-bento-layout"
import { useBentoLayoutStore } from "@/store/bento-layout-store"

/**
 * The hook's render surface, without a DOM grid around it: what it derives,
 * what it hands each card, and how it reacts to the store and the registry.
 * Gesture, keyboard and geometry behaviour live in the sibling aspect files.
 */

const SCOPE = "account-information"

function items(): BentoItemMeta[] {
	return [
		{ id: "a", label: "Alpha" },
		{ id: "b", label: "Bravo" },
		{ id: "c", label: "Charlie", sortable: false },
	]
}

beforeEach(() => {
	window.localStorage.clear()
	useBentoLayoutStore.setState({ layouts: {} })
})

describe("useBentoLayout", () => {
	it("derives the code order into one column on a first visit", () => {
		const { result } = renderHook(() =>
			useBentoLayout({ scope: SCOPE, items: items() }),
		)

		expect(result.current.columns).toEqual([["a", "b", "c"]])
		expect(result.current.columnCount).toBe(1)
		expect(result.current.liftedId).toBeNull()
		expect(result.current.settlingId).toBeNull()
		expect(result.current.announcement).toBe("")
	})

	it("derives a stored arrangement, and re-derives when the store changes", () => {
		useBentoLayoutStore.getState().setColumns(SCOPE, 1, [["b", "c", "a"]])

		const { result } = renderHook(() =>
			useBentoLayout({ scope: SCOPE, items: items() }),
		)
		expect(result.current.columns).toEqual([["b", "c", "a"]])

		act(() => {
			useBentoLayoutStore.getState().setColumns(SCOPE, 1, [["c", "a", "b"]])
		})
		expect(result.current.columns).toEqual([["c", "a", "b"]])
	})

	it("keys springs by card identity", () => {
		const { result } = renderHook(() =>
			useBentoLayout({ scope: SCOPE, items: items() }),
		)

		const spring = result.current.springFor("b")
		expect(spring).toBeDefined()
		expect(spring?.x.get()).toBe(0)
		expect(spring?.scale.get()).toBe(1)
		expect(spring?.opacity.get()).toBe(1)
		expect(result.current.springFor("not-a-card")).toBeUndefined()
	})

	it("hands a sortable card its full handle contract", () => {
		const { result } = renderHook(() =>
			useBentoLayout({ scope: SCOPE, items: items() }),
		)

		const props = result.current.getHandleProps("a")
		expect(props).not.toBeNull()
		expect(props?.["aria-label"]).toBe("Reorder Alpha")
		expect(props?.["aria-roledescription"]).toBe("sortable card")
		expect(props?.["aria-describedby"]).toBe(BENTO_INSTRUCTIONS_ID)
		expect(props?.type).toBe("button")
		expect(props?.["data-lifted"]).toBe(false)
		expect(typeof props?.ref).toBe("function")
		expect(typeof props?.onKeyDown).toBe("function")
		expect(typeof props?.onBlur).toBe("function")
	})

	it("grows no handle for a pinned card, nor for an unknown id", () => {
		const { result } = renderHook(() =>
			useBentoLayout({ scope: SCOPE, items: items() }),
		)

		expect(result.current.getHandleProps("c")).toBeNull()
		expect(result.current.getHandleProps("not-a-card")).toBeNull()
	})

	it("re-derives when the item registry changes", () => {
		const { result, rerender } = renderHook(
			(props: { items: BentoItemMeta[] }) =>
				useBentoLayout({ scope: SCOPE, items: props.items }),
			{ initialProps: { items: items() } },
		)
		expect(result.current.columns).toEqual([["a", "b", "c"]])

		rerender({ items: [...items(), { id: "d", label: "Delta" }] })
		expect(result.current.columns).toEqual([["a", "b", "c", "d"]])

		rerender({
			items: [
				{ id: "a", label: "Alpha" },
				{ id: "c", label: "Charlie" },
			],
		})
		expect(result.current.columns).toEqual([["a", "c"]])
	})

	it("reorders by keyboard even where nothing can be measured", () => {
		// The refusal to lift is pointer-only by design: a keyboard lift must
		// work in exactly the environments that cannot measure — a hidden tab,
		// or a test with no DOM at all.
		const { result } = renderHook(() =>
			useBentoLayout({ scope: SCOPE, items: items() }),
		)
		const press = (key: string) => {
			act(() => {
				result.current.getHandleProps("a")?.onKeyDown({
					key,
					repeat: false,
					preventDefault: () => {},
				} as unknown as ReactKeyboardEvent<HTMLElement>)
			})
		}

		press(" ")
		expect(result.current.liftedId).toBe("a")
		expect(result.current.announcement).toBe(
			"Picked up Alpha. Position 1 of 3.",
		)

		press("ArrowDown")
		expect(result.current.columns).toEqual([["b", "a", "c"]])

		press(" ")
		expect(result.current.liftedId).toBeNull()
		expect(
			useBentoLayoutStore.getState().layouts[SCOPE]?.columns?.["1"],
		).toEqual([["b", "a", "c"]])
	})

	it("falls back to one column where matchMedia is unavailable", () => {
		const original = window.matchMedia
		window.matchMedia = undefined as unknown as typeof window.matchMedia
		try {
			const { result } = renderHook(() =>
				useBentoLayout({ scope: SCOPE, items: items() }),
			)
			expect(result.current.columnCount).toBe(1)
			expect(result.current.columns).toEqual([["a", "b", "c"]])
		} finally {
			window.matchMedia = original
		}
	})
})

describe("useBentoColumns", () => {
	it("deals the defaults when nothing is stored", () => {
		const { result } = renderHook(() =>
			useBentoColumns(SCOPE, ["a", "b", "c"]),
		)
		expect(result.current).toEqual([["a", "b", "c"]])
	})

	it("lays the skeleton's bones out the way the member arranged them", () => {
		useBentoLayoutStore.getState().setColumns(SCOPE, 1, [["c", "a", "b"]])

		const { result } = renderHook(() =>
			useBentoColumns(SCOPE, ["a", "b", "c"]),
		)
		expect(result.current).toEqual([["c", "a", "b"]])
	})
})
