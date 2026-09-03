import { createFileRoute } from "@tanstack/react-router"
import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { ProgramDetailPending } from "./program-detail-pending"

const ROUTE_ID = "/_appLayout/programs/$programType/"

describe("ProgramDetailPending — route wrapper", () => {
	it("renders the program-detail shell with its loading landmark", async () => {
		const route = createFileRoute(ROUTE_ID)({
			component: ProgramDetailPending,
		})
		await renderFileRoute(route, {
			id: ROUTE_ID,
			path: "/programs/$programType/",
			initialEntries: ["/programs/frm"],
		})

		expect(screen.getByLabelText("Loading program details")).toHaveAttribute(
			"aria-busy",
		)
	})
})
