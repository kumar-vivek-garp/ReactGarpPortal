import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { CpdActivityList } from "@/components/molecules/cpd-activity-list"
import { cpdClaim } from "@/testing/factories/cpd"
import { renderWithProviders } from "@/testing/render"

const claim = cpdClaim({
	claimId: "c1",
	title: "Climate Risk Webinar",
	activityTypeName: "Webinar",
	credits: 2,
	dateOfCompletion: "2026-02-01",
	areaOfStudy: "Credit Risk;Market Risk",
})

describe("CpdActivityList — the row as its own control", () => {
	/*
	 * An approved row's only action is "see the rest of it", so the row IS the
	 * control: the interactive Card carries the hover lift, the press squash
	 * and a focus ring, and a lone Details button beside a fully clickable card
	 * is a second target for one job.
	 */
	it("activates the whole row when Details is all it offers", async () => {
		const onView = vi.fn()
		const user = userEvent.setup()
		renderWithProviders(
			<CpdActivityList section="approved" claims={[claim]} onView={onView} />,
		)

		expect(
			screen.queryByRole("button", { name: "Details" }),
		).not.toBeInTheDocument()

		await user.click(
			screen.getByRole("button", { name: "View Climate Risk Webinar" }),
		)

		// The Card defers activation until its press spring settles.
		await waitFor(() => expect(onView).toHaveBeenCalledTimes(1))
		expect(onView.mock.calls[0][0]).toMatchObject({ claimId: "c1" })
	})

	it("leaves a pending row inert — Edit and Delete are two different actions", async () => {
		const onEdit = vi.fn()
		const onDelete = vi.fn()
		const user = userEvent.setup()
		renderWithProviders(
			<CpdActivityList
				section="pending"
				claims={[claim]}
				onEdit={onEdit}
				onDelete={onDelete}
			/>,
		)

		expect(
			screen.queryByRole("button", { name: /^View / }),
		).not.toBeInTheDocument()

		await user.click(
			screen.getByRole("button", { name: "Edit Climate Risk Webinar" }),
		)
		expect(onEdit).toHaveBeenCalledTimes(1)
		expect(onDelete).not.toHaveBeenCalled()
	})
})

describe("CpdActivityList — what a row says", () => {
	it("states the credits, the status and the facts under the title", () => {
		renderWithProviders(
			<CpdActivityList section="approved" claims={[claim]} onView={vi.fn()} />,
		)

		expect(screen.getByText("Climate Risk Webinar")).toBeInTheDocument()
		expect(screen.getByText("2 credits")).toBeInTheDocument()
		expect(screen.getByText("Approved")).toBeInTheDocument()
		expect(screen.getByText("Webinar")).toBeInTheDocument()
		expect(screen.getByText("Credit Risk, Market Risk")).toBeInTheDocument()
	})

	it("drops its own heading when a tab already names the section", () => {
		const { rerender } = renderWithProviders(
			<CpdActivityList section="pending" claims={[claim]} />,
		)
		expect(
			screen.getByRole("heading", { name: /Pending Activities/ }),
		).toBeInTheDocument()

		rerender(
			<CpdActivityList section="pending" claims={[claim]} showTitle={false} />,
		)
		expect(
			screen.queryByRole("heading", { name: /Pending Activities/ }),
		).not.toBeInTheDocument()
	})

	it("keeps the section's shape when it is empty", () => {
		renderWithProviders(<CpdActivityList section="approved" claims={[]} />)
		expect(screen.getByText("No Approved Credits")).toBeInTheDocument()
	})
})
