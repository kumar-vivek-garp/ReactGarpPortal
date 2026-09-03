import { createFileRoute } from "@tanstack/react-router"
import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { membershipSearchSchema } from "@/config/membership"
import { renderFileRoute } from "@/testing/file-route"

import { MembershipPending } from "./membership-pending"

const ROUTE_ID = "/_appLayout/membership/"

function mountPending(entry: string) {
	const route = createFileRoute(ROUTE_ID)({
		validateSearch: membershipSearchSchema,
		component: MembershipPending,
	})
	return renderFileRoute(route, {
		id: ROUTE_ID,
		path: "/membership/",
		initialEntries: [entry],
	})
}

describe("MembershipPending — route wrapper", () => {
	it("reads the destination tab so the right skeleton shows first", async () => {
		await mountPending("/membership/?tab=directory")

		expect(
			screen.getByRole("heading", { level: 1, name: "Membership Benefits" }),
		).toBeInTheDocument()
		expect(screen.getByLabelText("Loading member directory")).toHaveAttribute(
			"aria-busy",
		)
	})

	it("falls back to the benefits skeleton on the default tab", async () => {
		await mountPending("/membership/")

		expect(
			screen.getByLabelText("Loading membership benefits"),
		).toHaveAttribute("aria-busy")
	})
})
