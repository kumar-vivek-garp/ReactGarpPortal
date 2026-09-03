import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import {
	Tabs,
	TabsContent,
	TabsList,
	TabsTrigger,
} from "@/components/atoms/tabs"
import { renderWithProviders } from "@/testing/render"

function renderTabs(variant?: "default" | "line") {
	return renderWithProviders(
		<Tabs defaultValue="overview">
			<TabsList variant={variant}>
				<TabsTrigger value="overview">Overview</TabsTrigger>
				<TabsTrigger value="results">Results</TabsTrigger>
			</TabsList>
			<TabsContent value="overview">Overview panel</TabsContent>
			<TabsContent value="results">Results panel</TabsContent>
		</Tabs>,
	)
}

describe("Tabs", () => {
	it("shows the default panel and switches on click", async () => {
		const user = userEvent.setup()
		renderTabs()

		expect(screen.getByRole("tab", { name: "Overview" })).toHaveAttribute(
			"aria-selected",
			"true",
		)
		expect(screen.getByRole("tabpanel")).toHaveTextContent("Overview panel")

		await user.click(screen.getByRole("tab", { name: "Results" }))
		expect(screen.getByRole("tabpanel")).toHaveTextContent("Results panel")
	})

	it("keeps the tablist role in the line variant", () => {
		renderTabs("line")
		expect(screen.getByRole("tablist")).toBeInTheDocument()
		expect(screen.getAllByRole("tab")).toHaveLength(2)
	})

	it("supports vertical orientation", () => {
		renderWithProviders(
			<Tabs defaultValue="one" orientation="vertical">
				<TabsList>
					<TabsTrigger value="one">One</TabsTrigger>
				</TabsList>
				<TabsContent value="one">First</TabsContent>
			</Tabs>,
		)
		expect(screen.getByRole("tablist")).toHaveAttribute(
			"aria-orientation",
			"vertical",
		)
	})
})
