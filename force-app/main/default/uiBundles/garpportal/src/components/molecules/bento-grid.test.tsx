import { beforeEach, describe, expect, it } from "vitest"
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"

import { BentoGrid } from "@/components/molecules/bento-grid"
import { BENTO_STORAGE_KEY } from "@/config/bento"
import type { BentoRenderItem } from "@/hooks/use-bento-layout"
import { useBentoLayoutStore } from "@/store/bento-layout-store"

/**
 * jsdom reports 0 for every offset, so the FLIP itself cannot be asserted here
 * — that is what a real browser is for. What *is* fully exercised is the wiring
 * these tests exist to protect: which card renders in which slot, that the grip
 * drives it, and that the result survives a remount via localStorage.
 */

const SCOPE = "account-information"

function items(): BentoRenderItem[] {
	return [
		{
			id: "personal",
			label: "Personal Information",
			render: ({ handleProps }) => (
				<article data-testid="card">
					<h3>Personal Information</h3>
					{handleProps ? (
						<button {...handleProps}>Reorder Personal Information</button>
					) : null}
				</article>
			),
		},
		{
			id: "membership",
			label: "Membership",
			render: ({ handleProps }) => (
				<article data-testid="card">
					<h3>Membership</h3>
					{handleProps ? (
						<button {...handleProps}>Reorder Membership</button>
					) : null}
				</article>
			),
		},
		{
			id: "career",
			label: "Career Information",
			// Pinned: grows no grip.
			sortable: false,
			render: ({ handleProps }) => (
				<article data-testid="card">
					<h3>Career Information</h3>
					{handleProps ? (
						<button {...handleProps}>Reorder Career</button>
					) : null}
				</article>
			),
		},
	]
}

function renderedOrder(): string[] {
	return screen
		.getAllByTestId("card")
		.map((node) => node.querySelector("h3")?.textContent ?? "")
}

/** jsdom has no `matchMedia`, so the engine renders its single-column layout. */
function storedOrder(): string[] | undefined {
	return useBentoLayoutStore.getState().layouts[SCOPE]?.columns?.["1"]?.[0]
}

function setStored(order: string[]) {
	useBentoLayoutStore.getState().setColumns(SCOPE, 1, [order])
}

describe("BentoGrid", () => {
	beforeEach(() => {
		window.localStorage.clear()
		useBentoLayoutStore.setState({ layouts: {} })
	})

	it("renders the code-defined order on a first visit", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		expect(renderedOrder()).toEqual([
			"Personal Information",
			"Membership",
			"Career Information",
		])
	})

	it("renders a remembered order instead of the default", () => {
		setStored(["membership", "career", "personal"])

		render(<BentoGrid scope={SCOPE} items={items()} />)
		expect(renderedOrder()).toEqual([
			"Membership",
			"Career Information",
			"Personal Information",
		])
	})

	it("reconciles a stale remembered order without losing a card", () => {
		setStored(["membership", "deleted-card", "personal"])

		render(<BentoGrid scope={SCOPE} items={items()} />)
		// `career` was never stored, and belongs after `membership` by default.
		expect(renderedOrder()).toEqual([
			"Membership",
			"Career Information",
			"Personal Information",
		])
	})

	it("gives every sortable card a grip and pinned cards none", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		expect(
			screen.getByRole("button", { name: "Reorder Personal Information" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Reorder Membership" }),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Reorder Career" }),
		).not.toBeInTheDocument()
	})

	it("reorders by keyboard and persists the result", async () => {
		const user = userEvent.setup()
		render(<BentoGrid scope={SCOPE} items={items()} />)

		const grip = screen.getByRole("button", {
			name: "Reorder Personal Information",
		})
		grip.focus()
		await user.keyboard("{ }")
		await user.keyboard("{ArrowDown}")
		await user.keyboard("{ }")

		expect(renderedOrder()).toEqual([
			"Membership",
			"Personal Information",
			"Career Information",
		])
		expect(storedOrder()).toEqual(["membership", "personal", "career"])
	})

	it("restores the original order when a keyboard move is cancelled", async () => {
		const user = userEvent.setup()
		render(<BentoGrid scope={SCOPE} items={items()} />)

		const grip = screen.getByRole("button", {
			name: "Reorder Personal Information",
		})
		grip.focus()
		await user.keyboard("{ }")
		await user.keyboard("{ArrowDown}")
		expect(renderedOrder()[0]).toBe("Membership")

		await user.keyboard("{Escape}")
		expect(renderedOrder()).toEqual([
			"Personal Information",
			"Membership",
			"Career Information",
		])
		expect(storedOrder()).toBeUndefined()
	})

	it("announces a pickup and a drop", async () => {
		const user = userEvent.setup()
		render(<BentoGrid scope={SCOPE} items={items()} />)

		const grip = screen.getByRole("button", {
			name: "Reorder Personal Information",
		})
		grip.focus()
		await user.keyboard("{ }")
		expect(screen.getByRole("status")).toHaveTextContent(
			"Picked up Personal Information. Position 1 of 3.",
		)

		await user.keyboard("{ArrowDown}")
		expect(screen.getByRole("status")).toHaveTextContent(
			"Moved Personal Information. Position 2 of 3.",
		)
	})


	it("survives a remount by reading localStorage", async () => {
		const user = userEvent.setup()
		const first = render(<BentoGrid scope={SCOPE} items={items()} />)

		const grip = screen.getByRole("button", {
			name: "Reorder Personal Information",
		})
		grip.focus()
		await user.keyboard("{ }{ArrowDown}{ }")
		first.unmount()

		expect(window.localStorage.getItem(BENTO_STORAGE_KEY)).toContain(
			"membership",
		)

		render(<BentoGrid scope={SCOPE} items={items()} />)
		expect(renderedOrder()).toEqual([
			"Membership",
			"Personal Information",
			"Career Information",
		])
	})
})
