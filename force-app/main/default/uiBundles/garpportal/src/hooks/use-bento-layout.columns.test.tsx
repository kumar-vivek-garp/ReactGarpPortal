import { render, renderHook, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it } from "vitest"

import { BentoGrid } from "@/components/molecules/bento-grid"
import { useBentoColumns, type BentoRenderItem } from "@/hooks/use-bento-layout"
import { useBentoLayoutStore } from "@/store/bento-layout-store"
import { stubMatchMedia } from "@/testing/match-media"

/**
 * The column breakpoint and what survives crossing it: layout derivation per
 * column count, and the store keeping one arrangement per count so a phone
 * rearrangement cannot destroy the desktop one.
 */

const SCOPE = "account-information"

const media = stubMatchMedia()

function items(): BentoRenderItem[] {
	const one = (id: string, label: string): BentoRenderItem => ({
		id,
		label,
		render: ({ handleProps }) => (
			<article data-testid="card">
				<h3>{label}</h3>
				{handleProps ? <button {...handleProps}>Reorder {label}</button> : null}
			</article>
		),
	})
	return [one("a", "Alpha"), one("b", "Bravo"), one("c", "Charlie")]
}

/** Card labels per rendered column, in document order. */
function columnOrder(): string[][] {
	const wrapper = screen.getAllByTestId("card")[0].parentElement as HTMLElement
	const container = wrapper.parentElement?.parentElement as HTMLElement
	return Array.from(container.children)
		.filter((node): node is HTMLElement => node.tagName === "DIV")
		.map((column) =>
			Array.from(column.querySelectorAll("h3")).map(
				(heading) => heading.textContent ?? "",
			),
		)
}

function storedColumns() {
	return useBentoLayoutStore.getState().layouts[SCOPE]?.columns
}

beforeEach(() => {
	window.localStorage.clear()
	useBentoLayoutStore.setState({ layouts: {} })
})

describe("BentoGrid across the column breakpoint", () => {
	it("deals round-robin across two columns on a first visit", () => {
		media.matches = true
		render(<BentoGrid scope={SCOPE} items={items()} />)

		expect(columnOrder()).toEqual([["Alpha", "Charlie"], ["Bravo"]])
	})

	it("honours a stored two-column arrangement", () => {
		useBentoLayoutStore.getState().setColumns(SCOPE, 2, [["c", "a"], ["b"]])
		media.matches = true
		render(<BentoGrid scope={SCOPE} items={items()} />)

		expect(columnOrder()).toEqual([["Charlie", "Alpha"], ["Bravo"]])
	})

	it("re-derives on a breakpoint change and keeps each count's layout", () => {
		useBentoLayoutStore.getState().setColumns(SCOPE, 2, [["c", "a"], ["b"]])
		useBentoLayoutStore.getState().setColumns(SCOPE, 1, [["b", "a", "c"]])
		media.matches = true
		render(<BentoGrid scope={SCOPE} items={items()} />)
		expect(columnOrder()).toEqual([["Charlie", "Alpha"], ["Bravo"]])

		media.set(false)
		expect(columnOrder()).toEqual([["Bravo", "Alpha", "Charlie"]])

		media.set(true)
		expect(columnOrder()).toEqual([["Charlie", "Alpha"], ["Bravo"]])

		expect(storedColumns()).toEqual({
			"1": [["b", "a", "c"]],
			"2": [["c", "a"], ["b"]],
		})
	})

	it("persists a reorder only under the active column count", async () => {
		const user = userEvent.setup()
		media.matches = true
		render(<BentoGrid scope={SCOPE} items={items()} />)

		// Two columns: walk Alpha down its own column and drop it.
		screen.getByRole("button", { name: "Reorder Alpha" }).focus()
		await user.keyboard("{ }{ArrowDown}{ }")
		expect(columnOrder()).toEqual([["Charlie", "Alpha"], ["Bravo"]])
		expect(storedColumns()?.["2"]).toEqual([["c", "a"], ["b"]])
		expect(storedColumns()?.["1"]).toBeUndefined()

		// One column: the two-column commit must not leak into a fresh deal.
		media.set(false)
		expect(columnOrder()).toEqual([["Alpha", "Bravo", "Charlie"]])

		screen.getByRole("button", { name: "Reorder Alpha" }).focus()
		await user.keyboard("{ }{ArrowDown}{ }")
		expect(columnOrder()).toEqual([["Bravo", "Alpha", "Charlie"]])
		expect(storedColumns()?.["1"]).toEqual([["b", "a", "c"]])
		expect(storedColumns()?.["2"]).toEqual([["c", "a"], ["b"]])

		// Back to two columns: the earlier commit is still the layout.
		media.set(true)
		expect(columnOrder()).toEqual([["Charlie", "Alpha"], ["Bravo"]])
	})
})

describe("useBentoColumns across the column breakpoint", () => {
	it("tracks the breakpoint and each count's stored arrangement", () => {
		useBentoLayoutStore.getState().setColumns(SCOPE, 2, [["c"], ["a", "b"]])
		media.matches = true

		const { result } = renderHook(() =>
			useBentoColumns(SCOPE, ["a", "b", "c"]),
		)
		expect(result.current).toEqual([["c"], ["a", "b"]])

		media.set(false)
		expect(result.current).toEqual([["a", "b", "c"]])
	})
})
