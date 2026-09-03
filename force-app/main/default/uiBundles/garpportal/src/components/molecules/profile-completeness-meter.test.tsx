import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import {
	ProfileCompletenessMeter,
	ProfileCompletenessMeterSkeleton,
} from "./profile-completeness-meter"

describe("ProfileCompletenessMeter", () => {
	it("exposes the rounded percentage on the progressbar", () => {
		render(<ProfileCompletenessMeter percent={72.4} />)

		const bar = screen.getByRole("progressbar", {
			name: "Profile completeness",
		})
		expect(bar).toHaveAttribute("aria-valuenow", "72")
		expect(screen.getByText("72%")).toBeInTheDocument()
	})

	it("clamps out-of-range values into 0–100", () => {
		render(<ProfileCompletenessMeter percent={140} />)

		expect(
			screen.getByRole("progressbar", { name: "Profile completeness" }),
		).toHaveAttribute("aria-valuenow", "100")
	})

	it("names the first three missing fields and counts the rest", () => {
		render(
			<ProfileCompletenessMeter
				percent={40}
				missing={["Photo", "Company", "Title", "Country", "Phone"]}
			/>,
		)

		expect(
			screen.getByText("Still needed: Photo, Company, Title and 2 more"),
		).toBeInTheDocument()
	})

	it("omits the missing line entirely when nothing is missing", () => {
		render(<ProfileCompletenessMeter percent={100} missing={[]} />)

		expect(screen.queryByText(/Still needed/)).not.toBeInTheDocument()
	})
})

describe("ProfileCompletenessMeterSkeleton", () => {
	it("is hidden from assistive tech while it stands in", () => {
		const { container } = render(<ProfileCompletenessMeterSkeleton />)

		expect(container.firstElementChild).toHaveAttribute("aria-hidden")
		expect(screen.queryByRole("progressbar")).not.toBeInTheDocument()
	})
})
