import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { Route } from "@/pages/_appLayout/study-materials/index"
import { renderFileRoute } from "@/testing/file-route"
import {
	apexMaterial,
	comingSoon,
	garpLearning,
	outOfStock,
	ownedWithReg,
	purchasable,
	studyMaterialsPayload,
} from "@/testing/factories/study-materials"
import { studyMaterialsOrg } from "@/testing/msw/handlers/study-materials"
import { server } from "@/testing/msw/server"

function serve() {
	server.use(
		...studyMaterialsOrg({
			payload: studyMaterialsPayload({
				frmStudyMaterials: [
					purchasable(), // Part 2
					apexMaterial({ title: "FRM Practice Exams", productCode: "FRMPE", relatedPart: null }),
					garpLearning("pending"), // Part 1
					ownedWithReg(), // Part 1
				],
				scrStudyMaterials: [apexMaterial({ title: "SCR Handbook", productCode: "SCRH" })],
				raiStudyMaterials: [comingSoon()],
				frrStudyMaterials: [outOfStock()],
			}),
		}).handlers,
	)
}

const mount = (entry = "/study-materials") =>
	renderFileRoute(Route, {
		id: "/_appLayout/study-materials/",
		path: "/study-materials/",
		initialEntries: [entry],
	})

describe("StudyMaterialsPanel — grouping", () => {
	it("splits FRM by exam part — Part 1, Part 2, then the rest — and leaves other programmes flat", async () => {
		serve()
		await mount("/study-materials?tab=frm")

		await screen.findByRole("heading", { name: /Financial Risk Manager.*\(4\)/ })
		const parts = screen.getAllByRole("heading", { level: 3 })
		expect(parts.map((h) => h.textContent)).toEqual(["Part 1", "Part 2"])
		// The un-parted item follows the part groups without a heading of its own.
		expect(screen.getByText("FRM Practice Exams")).toBeInTheDocument()
	})

	it("keeps programmes in the legacy's order on the All tab", async () => {
		serve()
		await mount()

		await screen.findByRole("heading", { name: /Financial Risk Manager/ })
		const programmes = screen
			.getAllByRole("heading", { level: 2 })
			.map((h) => h.textContent ?? "")
		expect(programmes[0]).toContain("Financial Risk Manager")
		expect(programmes[1]).toContain("Sustainability & Climate Risk")
		expect(programmes[2]).toContain("Risk & AI")
		expect(programmes[3]).toContain("Financial Risk and Regulation")
		// SCR has no parts, so no level-3 heading under it.
		expect(screen.getAllByRole("heading", { level: 3 })).toHaveLength(2)
	})

	it("offers Report an error per programme, on the route each programme's errata lives at", async () => {
		serve()
		await mount()

		await screen.findByRole("heading", { name: /Financial Risk Manager/ })
		const links = screen.getAllByRole("link", { name: /Report an error/ })
		expect(links.map((l) => l.getAttribute("href"))).toEqual([
			"/programs/frm/errata",
			"/programs/scr/errata",
			"/programs/riskai/errata",
			"/programs/frr/errata",
		])
	})

	it("renders every card state on one page", async () => {
		serve()
		await mount()

		await screen.findByRole("heading", { name: /Financial Risk Manager/ })
		expect(screen.getByRole("link", { name: "Access GARP Learning" })).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Order awaiting payment/ })).toBeInTheDocument()
		expect(screen.getAllByRole("button", { name: /Read/ })).toHaveLength(2)
		expect(screen.getByRole("link", { name: /Purchase/ })).toHaveAttribute(
			"href",
			"/study-materials/purchase/FRM2H",
		)
		expect(screen.getByText(/^Available /)).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Notify me/ })).toBeInTheDocument()
		expect(screen.getAllByText("Out of stock").length).toBeGreaterThan(0)
	})
})
