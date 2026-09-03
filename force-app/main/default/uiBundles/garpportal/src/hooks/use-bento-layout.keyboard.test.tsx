import { fireEvent, render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it } from "vitest"

import { BentoGrid } from "@/components/molecules/bento-grid"
import type { BentoRenderItem } from "@/hooks/use-bento-layout"
import { useBentoLayoutStore } from "@/store/bento-layout-store"
import { stubBentoGeometry } from "@/testing/bento-geometry"
import { stubMatchMedia } from "@/testing/match-media"
import { skipSpringAnimations } from "@/testing/springs"

/**
 * The keyboard reorder state machine on the two-column masonry: every arrow,
 * every boundary, both activation keys, and the commit-on-blur guarantee.
 * `bento-grid.test.tsx` owns the single-column basics; this file owns the
 * column axis, which only exists above the breakpoint.
 */

const SCOPE = "account-information"

const media = stubMatchMedia()
stubBentoGeometry()
// Safe here: BentoGrid memoises its one interpolation per card (see the
// warning in testing/springs.ts); the drag suite runs the same combination.
skipSpringAnimations()

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

function status() {
	return screen.getByRole("status").textContent
}

function storedColumns() {
	return useBentoLayoutStore.getState().layouts[SCOPE]?.columns
}

beforeEach(() => {
	window.localStorage.clear()
	useBentoLayoutStore.setState({ layouts: {} })
	media.matches = true
})

describe("keyboard reorder across two columns", () => {
	it("walks every direction, clamping at every boundary", async () => {
		const user = userEvent.setup()
		useBentoLayoutStore
			.getState()
			.setColumns(SCOPE, 2, [["a", "b", "c"], []])
		render(<BentoGrid scope={SCOPE} items={items()} />)
		expect(columnOrder()).toEqual([["Alpha", "Bravo", "Charlie"], []])

		screen.getByRole("button", { name: "Reorder Charlie" }).focus()
		await user.keyboard("{ }")
		expect(status()).toBe("Picked up Charlie. Column 1 of 2, position 3 of 3.")

		// Right, into the empty column: the index clamps from 2 down to 0.
		await user.keyboard("{ArrowRight}")
		expect(columnOrder()).toEqual([["Alpha", "Bravo"], ["Charlie"]])
		expect(status()).toBe("Moved Charlie. Column 2 of 2, position 1 of 1.")

		// Right again at the last column: nothing moves, nothing re-announces.
		await user.keyboard("{ArrowRight}")
		expect(columnOrder()).toEqual([["Alpha", "Bravo"], ["Charlie"]])
		expect(status()).toBe("Moved Charlie. Column 2 of 2, position 1 of 1.")

		// Down in a column of one: already at the bottom.
		await user.keyboard("{ArrowDown}")
		expect(columnOrder()).toEqual([["Alpha", "Bravo"], ["Charlie"]])

		// Left, back into the full column, keeping the clamped index.
		await user.keyboard("{ArrowLeft}")
		expect(columnOrder()).toEqual([["Charlie", "Alpha", "Bravo"], []])
		expect(status()).toBe("Moved Charlie. Column 1 of 2, position 1 of 3.")

		// Left again at the first column, up at the top: both clamp.
		await user.keyboard("{ArrowLeft}{ArrowUp}")
		expect(columnOrder()).toEqual([["Charlie", "Alpha", "Bravo"], []])

		// Walk down the column to the bottom, then once more past it.
		await user.keyboard("{ArrowDown}{ArrowDown}{ArrowDown}")
		expect(columnOrder()).toEqual([["Alpha", "Bravo", "Charlie"], []])

		await user.keyboard("{ }")
		expect(status()).toBe("Dropped Charlie. Column 1 of 2, position 3 of 3.")
		expect(storedColumns()?.["2"]).toEqual([["a", "b", "c"], []])
	})

	it("lifts and drops with Enter, surviving the column crossing", async () => {
		const user = userEvent.setup()
		render(<BentoGrid scope={SCOPE} items={items()} />)
		expect(columnOrder()).toEqual([["Alpha", "Charlie"], ["Bravo"]])

		const grip = screen.getByRole("button", { name: "Reorder Charlie" })
		grip.focus()
		await user.keyboard("{Enter}{ArrowRight}")
		expect(columnOrder()).toEqual([["Alpha"], ["Bravo", "Charlie"]])
		// Crossing a column relocates the DOM node; the lift must keep focus...
		expect(document.activeElement).toBe(
			screen.getByRole("button", { name: "Reorder Charlie" }),
		)
		// ...so that the next arrow still steers the same card.
		await user.keyboard("{ArrowUp}")
		expect(columnOrder()).toEqual([["Alpha"], ["Charlie", "Bravo"]])

		await user.keyboard("{Enter}")
		expect(storedColumns()?.["2"]).toEqual([["a"], ["c", "b"]])
	})

	it("lifts on the legacy 'Spacebar' key and cancels on Escape", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		const grip = screen.getByRole("button", { name: "Reorder Bravo" })

		fireEvent.keyDown(grip, { key: "Spacebar" })
		expect(status()).toBe("Picked up Bravo. Column 2 of 2, position 1 of 1.")

		fireEvent.keyDown(grip, { key: "ArrowLeft" })
		expect(columnOrder()).toEqual([["Bravo", "Alpha", "Charlie"], []])

		// Crossing a column recreated the handle node; Escape must go to the
		// live one (the lift refocused it — see the Enter test).
		fireEvent.keyDown(screen.getByRole("button", { name: "Reorder Bravo" }), {
			key: "Escape",
		})
		// Pinned, not endorsed: the cancel announcement counts positions in the
		// abandoned preview (`columnsRef` still holds it when `announce` runs in
		// `finishDrag`), so Bravo's restored column reads as holding 0 cards.
		// The slot itself is right; only the totals lag one render behind.
		expect(status()).toBe(
			"Cancelled, returned Bravo. Column 2 of 2, position 1 of 0.",
		)
		expect(columnOrder()).toEqual([["Alpha", "Charlie"], ["Bravo"]])
		expect(storedColumns()).toBeUndefined()
	})

	it("ignores a held-down key repeat", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		const grip = screen.getByRole("button", { name: "Reorder Alpha" })

		fireEvent.keyDown(grip, { key: " ", repeat: true })
		expect(status()).toBe("")
		expect(grip.dataset.lifted).toBe("false")
	})

	it("ignores arrows before a lift and unmapped keys during one", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		const grip = screen.getByRole("button", { name: "Reorder Alpha" })

		fireEvent.keyDown(grip, { key: "ArrowDown" })
		expect(status()).toBe("")
		expect(columnOrder()).toEqual([["Alpha", "Charlie"], ["Bravo"]])

		fireEvent.keyDown(grip, { key: " " })
		fireEvent.keyDown(grip, { key: "x" })
		expect(grip.dataset.lifted).toBe("true")
		expect(columnOrder()).toEqual([["Alpha", "Charlie"], ["Bravo"]])

		fireEvent.keyDown(grip, { key: "Escape" })
	})

	it("commits the pending move when focus leaves the handle", async () => {
		const user = userEvent.setup()
		render(<BentoGrid scope={SCOPE} items={items()} />)

		const grip = screen.getByRole("button", { name: "Reorder Alpha" })
		grip.focus()
		await user.keyboard("{ }{ArrowDown}")
		expect(columnOrder()).toEqual([["Charlie", "Alpha"], ["Bravo"]])

		fireEvent.blur(grip)
		expect(status()).toBe("Dropped Alpha. Column 1 of 2, position 2 of 2.")
		expect(columnOrder()).toEqual([["Charlie", "Alpha"], ["Bravo"]])
		expect(storedColumns()?.["2"]).toEqual([["c", "a"], ["b"]])
	})
})
