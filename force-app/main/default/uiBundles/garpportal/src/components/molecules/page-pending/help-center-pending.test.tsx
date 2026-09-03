import { createFileRoute } from "@tanstack/react-router"
import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { helpCenterSearchSchema } from "@/config/help-center"
import { renderFileRoute } from "@/testing/file-route"

import { HelpCenterPending, HelpCenterPendingShell } from "./help-center-pending"

const ROUTE_ID = "/_appLayout/help-center/"

function mountPending(entry: string) {
	const route = createFileRoute(ROUTE_ID)({
		validateSearch: helpCenterSearchSchema,
		component: HelpCenterPending,
	})
	return renderFileRoute(route, {
		id: ROUTE_ID,
		path: "/help-center/",
		initialEntries: [entry],
	})
}

describe("HelpCenterPending — route wrapper", () => {
	it("reads the destination tab so the right body skeleton shows", async () => {
		await mountPending("/help-center/?tab=requests")

		const region = screen.getByLabelText("Loading help center")
		expect(region).toHaveAttribute("aria-busy")
		expect(screen.getByLabelText("Loading your requests")).toBeInTheDocument()
	})
})

describe("HelpCenterPendingShell", () => {
	it("mirrors the Get Help form card on the default tab", () => {
		render(<HelpCenterPendingShell tab="get-help" />)

		expect(screen.getByLabelText("Loading help center")).toBeInTheDocument()
		expect(
			screen.queryByLabelText("Loading your requests"),
		).not.toBeInTheDocument()
	})
})
