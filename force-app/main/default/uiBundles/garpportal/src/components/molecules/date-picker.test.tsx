import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import { DatePicker } from "@/components/molecules/date-picker"
import { renderWithProviders } from "@/testing/render"

/** A fixed "today" so the calendar's default month is deterministic. */
beforeEach(() => {
	vi.useFakeTimers({ shouldAdvanceTime: true })
	vi.setSystemTime(new Date(2026, 8, 7, 12))
})

afterEach(() => {
	vi.useRealTimers()
})

function Harness({ initial = "" }: { initial?: string }) {
	return (
		<DatePickerHarness initial={initial} />
	)
}

import { useState } from "react"

function DatePickerHarness({ initial }: { initial: string }) {
	const [value, setValue] = useState(initial)
	return (
		<>
			<DatePicker
				id="dob"
				value={value}
				onChange={setValue}
				placeholder="Pick a date"
				startMonth={new Date(2020, 0)}
				endMonth={new Date(2030, 11)}
			/>
			<output data-testid="value">{value}</output>
		</>
	)
}

describe("DatePicker", () => {
	it("shows the placeholder until a date is chosen", () => {
		renderWithProviders(<Harness />)
		expect(screen.getByRole("button", { name: /Pick a date/ })).toBeInTheDocument()
		expect(screen.getByTestId("value")).toHaveTextContent("")
	})

	// `new Date("2030-01-01")` is UTC midnight, which is 31 December west of
	// Greenwich. The picker must show the day the string names, everywhere.
	it("renders a seeded ISO date as the day it names, not the day before", () => {
		renderWithProviders(<Harness initial="2030-01-01" />)
		expect(
			screen.getByRole("button", { name: /January 1st, 2030/ }),
		).toBeInTheDocument()
	})

	it("opens the calendar and emits the chosen day as ISO", async () => {
		const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime })
		renderWithProviders(<Harness />)

		await user.click(screen.getByRole("button", { name: /Pick a date/ }))
		// Today's month is open; pick a day inside it.
		await user.click(await screen.findByRole("button", { name: /September 15th, 2026/ }))

		expect(screen.getByTestId("value")).toHaveTextContent("2026-09-15")
		expect(
			screen.getByRole("button", { name: /September 15th, 2026/ }),
		).toBeInTheDocument()
	})

	it("closes after a pick", async () => {
		const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime })
		renderWithProviders(<Harness />)

		await user.click(screen.getByRole("button", { name: /Pick a date/ }))
		await user.click(await screen.findByRole("button", { name: /September 15th, 2026/ }))

		expect(screen.queryByRole("grid")).not.toBeInTheDocument()
	})
})

describe("DatePicker — refused days", () => {
	it("disables everything after the matcher and will not walk past it", async () => {
		const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime })
		renderWithProviders(
			<DatePicker
				id="completed"
				value=""
				onChange={() => {}}
				placeholder="Pick a date"
				endMonth={new Date(2026, 8, 7)}
				disabledDates={{ after: new Date(2026, 8, 7) }}
			/>,
		)

		await user.click(screen.getByRole("button", { name: /Pick a date/ }))

		expect(
			screen.getByRole("button", { name: /September 7th, 2026/ }),
		).toBeEnabled()
		expect(
			screen.getByRole("button", { name: /September 8th, 2026/ }),
		).toBeDisabled()
		// rdp marks the nav button `aria-disabled` so it stays focusable.
		expect(screen.getByRole("button", { name: /next month/i })).toHaveAttribute(
			"aria-disabled",
			"true",
		)
	})
})
