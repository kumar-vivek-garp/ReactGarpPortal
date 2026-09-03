import { fireEvent, screen } from "@testing-library/react"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import {
	Card,
	CardAction,
	CardContent,
	CardDescription,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { renderWithProviders } from "@/testing/render"

function renderInteractive(onActivate = vi.fn()) {
	renderWithProviders(
		<Card interactive onActivate={onActivate} data-testid="card" tabIndex={0}>
			Open programme
		</Card>,
	)
	return { card: screen.getByTestId("card"), onActivate }
}

describe("Card composition", () => {
	it("renders all its parts", () => {
		renderWithProviders(
			<Card>
				<CardHeader>
					<CardTitle>FRM</CardTitle>
					<CardDescription>Part I</CardDescription>
					<CardAction>Manage</CardAction>
				</CardHeader>
				<CardContent>Body</CardContent>
				<CardFooter>Footer</CardFooter>
			</Card>,
		)
		for (const text of ["FRM", "Part I", "Manage", "Body", "Footer"]) {
			expect(screen.getByText(text)).toBeInTheDocument()
		}
	})

	it("merges onto its child with asChild", () => {
		renderWithProviders(
			<Card asChild interactive>
				<a href="/programs/frm">Linked card</a>
			</Card>,
		)
		const link = screen.getByRole("link", { name: "Linked card" })
		expect(link).toHaveAttribute("data-slot", "card")
		expect(link).toHaveAttribute("data-interactive", "true")
	})
})

describe("interactive activation", () => {
	beforeEach(() => vi.useFakeTimers())
	afterEach(() => vi.useRealTimers())

	it("fires onActivate once after the settle delay, even for a double click", () => {
		const { card, onActivate } = renderInteractive()

		fireEvent.click(card)
		fireEvent.click(card)
		expect(onActivate).not.toHaveBeenCalled()

		vi.advanceTimersByTime(180)
		expect(onActivate).toHaveBeenCalledTimes(1)
	})

	it("activates from the keyboard with Space, swallowing page scroll", () => {
		const { card, onActivate } = renderInteractive()

		const spaceDefaultAllowed = fireEvent.keyDown(card, { key: " " })
		expect(spaceDefaultAllowed).toBe(false)
		fireEvent.keyUp(card, { key: " " })

		vi.advanceTimersByTime(180)
		expect(onActivate).toHaveBeenCalledTimes(1)
	})

	it("activates with Enter and ignores held-down key repeats", () => {
		const { card, onActivate } = renderInteractive()

		fireEvent.keyDown(card, { key: "Enter" })
		fireEvent.keyDown(card, { key: "Enter", repeat: true })
		fireEvent.keyUp(card, { key: "Enter" })

		vi.advanceTimersByTime(180)
		expect(onActivate).toHaveBeenCalledTimes(1)
	})

	it("never fires when unmounted before the settle delay", () => {
		const onActivate = vi.fn()
		const { unmount } = renderWithProviders(
			<Card interactive onActivate={onActivate} data-testid="card" />,
		)

		fireEvent.click(screen.getByTestId("card"))
		unmount()
		vi.advanceTimersByTime(400)
		expect(onActivate).not.toHaveBeenCalled()
	})
})

describe("interactive hover and press states", () => {
	it("tracks pointer hover, press, release, and leave", () => {
		const { card } = renderInteractive()

		fireEvent.pointerEnter(card)
		expect(card).toHaveAttribute("data-hovered", "true")

		fireEvent.pointerDown(card)
		fireEvent.pointerUp(card)
		fireEvent.pointerCancel(card)

		fireEvent.pointerLeave(card)
		expect(card).not.toHaveAttribute("data-hovered")
	})

	it("treats keyboard focus like hover", () => {
		const { card } = renderInteractive()

		fireEvent.focus(card)
		expect(card).toHaveAttribute("data-hovered", "true")

		fireEvent.blur(card)
		expect(card).not.toHaveAttribute("data-hovered")
	})

	it("a static card passes its handlers straight through", () => {
		const onClick = vi.fn()
		const onPointerEnter = vi.fn()
		renderWithProviders(
			<Card onClick={onClick} onPointerEnter={onPointerEnter} data-testid="flat">
				Static
			</Card>,
		)
		const card = screen.getByTestId("flat")

		fireEvent.pointerEnter(card)
		fireEvent.click(card)

		expect(onClick).toHaveBeenCalledTimes(1)
		expect(onPointerEnter).toHaveBeenCalledTimes(1)
		expect(card).not.toHaveAttribute("data-interactive")
		expect(card).not.toHaveAttribute("data-hovered")
	})
})
