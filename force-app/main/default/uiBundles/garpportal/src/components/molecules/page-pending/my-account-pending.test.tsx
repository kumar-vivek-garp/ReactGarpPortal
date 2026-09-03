import { createFileRoute } from "@tanstack/react-router"
import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { myAccountSearchSchema } from "@/config/my-account"
import { renderFileRoute } from "@/testing/file-route"

import { MyAccountPending, MyAccountPendingShell } from "./my-account-pending"

const ROUTE_ID = "/_appLayout/my-account/"

/** The wrapper mounted at its real route id, so `routeApi.useSearch` resolves. */
function mountPending(entry: string) {
	const route = createFileRoute(ROUTE_ID)({
		validateSearch: myAccountSearchSchema,
		component: MyAccountPending,
	})
	return renderFileRoute(route, {
		id: ROUTE_ID,
		path: "/my-account/",
		initialEntries: [entry],
	})
}

describe("MyAccountPending — route wrapper", () => {
	it("reads the destination tab so the right skeleton shows first", async () => {
		await mountPending("/my-account/?tab=order-history")

		expect(
			screen.getByRole("heading", { level: 1, name: "My Account" }),
		).toBeInTheDocument()
		expect(screen.getByLabelText("Loading orders")).toHaveAttribute("aria-busy")
	})
})

describe("MyAccountPendingShell — one skeleton per tab", () => {
	it("stands in for Account Information by default", () => {
		render(<MyAccountPendingShell />)

		expect(screen.getByLabelText("Loading account")).toBeInTheDocument()
	})

	it("stands in for Contact Preferences on that tab", () => {
		render(<MyAccountPendingShell tab="contact-preferences" />)

		expect(
			screen.getByLabelText("Loading contact preferences"),
		).toBeInTheDocument()
	})

	it("stands in for Order History on that tab", () => {
		render(<MyAccountPendingShell tab="order-history" />)

		expect(screen.getByLabelText("Loading orders")).toBeInTheDocument()
	})
})
