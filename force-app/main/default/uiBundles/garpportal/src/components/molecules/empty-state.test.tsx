import { screen } from "@testing-library/react"
import { Inbox } from "lucide-react"
import { describe, expect, it } from "vitest"

import { EmptyState } from "@/components/molecules/empty-state"
import { renderWithProviders } from "@/testing/render"

describe("the shared empty block", () => {
	it("shows title alone when no message or action is given", () => {
		renderWithProviders(<EmptyState icon={Inbox} title="Nothing here yet" />)
		expect(screen.getByText("Nothing here yet")).toBeInTheDocument()
		expect(screen.queryByRole("button")).not.toBeInTheDocument()
	})

	it("adds the supporting line and the way forward when given", () => {
		renderWithProviders(
			<EmptyState
				icon={Inbox}
				title="Nothing here yet"
				message="Your requests will appear here."
				action={<button type="button">Raise a request</button>}
			/>,
		)
		expect(
			screen.getByText("Your requests will appear here."),
		).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Raise a request" }),
		).toBeInTheDocument()
	})
})
