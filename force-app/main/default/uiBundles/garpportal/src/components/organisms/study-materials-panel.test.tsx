import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it } from "vitest"

import { Route } from "@/pages/_appLayout/study-materials/index"
import { useListViewStore } from "@/store/list-view-store"
import { renderFileRoute } from "@/testing/file-route"
import {
	apexMaterial,
	ownedWithReg,
	purchasable,
	studyMaterialsPayload,
} from "@/testing/factories/study-materials"
import { studyMaterialsOrg } from "@/testing/msw/handlers/study-materials"
import { server } from "@/testing/msw/server"

function serveMaterials(
	info = {
		frmStudyMaterials: [purchasable(), ownedWithReg({ relatedPart: null })],
		scrStudyMaterials: [apexMaterial({ title: "SCR Handbook", productCode: "SCRH" })],
	},
) {
	server.use(...studyMaterialsOrg({ payload: studyMaterialsPayload(info) }).handlers)
}

/**
 * Mounted through the real route: the panel's pending shell reads
 * `Route.useSearch()` from "/_appLayout/study-materials/", so it needs the
 * page's exact route id in the tree.
 */
async function renderPanel(entry = "/study-materials") {
	return renderFileRoute(Route, {
		id: "/_appLayout/study-materials/",
		path: "/study-materials/",
		initialEntries: [entry],
	})
}

beforeEach(() => {
	window.localStorage.clear()
	useListViewStore.setState({ preferred: {} })
})

describe("StudyMaterialsPanel — one card per material", () => {
	/*
	 * Ownership is a section again, not just a chip: a programme's materials
	 * split into what the member holds and what is still on sale, so "is there
	 * anything here I still need?" is answered by the headings rather than by
	 * reading every card.
	 */
	it("files every material once, under My Materials or Available to Purchase", async () => {
		serveMaterials()
		await renderPanel()

		expect(
			await screen.findByRole("heading", { name: /Financial Risk Manager.*\(2\)/ }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: /Sustainability & Climate Risk.*\(1\)/ }),
		).toBeInTheDocument()
		// Once, in exactly one of the two blocks — never duplicated across them.
		expect(screen.getAllByText("2026 FRM Exam Part I eBooks")).toHaveLength(1)
		expect(
			screen.getByRole("heading", { name: /My Materials/ }),
		).toBeInTheDocument()
		expect(
			screen.getAllByRole("heading", { name: /Available to Purchase/ }).length,
		).toBeGreaterThan(0)
	})

	it("earns no filter pills for a single programme", async () => {
		serveMaterials({ frmStudyMaterials: [purchasable()], scrStudyMaterials: [] })
		await renderPanel()

		expect(await screen.findByText("2026 FRM Exam Part II Books")).toBeInTheDocument()
		expect(screen.queryByRole("tab")).not.toBeInTheDocument()
	})
})

describe("StudyMaterialsPanel — program tabs", () => {
	it("offers a pill per programme and scopes the page to the picked one", async () => {
		serveMaterials()
		await renderPanel("/study-materials?tab=scr")

		expect(await screen.findByText("SCR Handbook")).toBeInTheDocument()
		expect(screen.getByRole("tab", { name: /All/ })).toBeInTheDocument()
		expect(screen.queryByText("2026 FRM Exam Part II Books")).not.toBeInTheDocument()
		expect(
			screen.queryByRole("heading", { name: /Financial Risk Manager/ }),
		).not.toBeInTheDocument()
	})

	it("bounces an unknown ?tab= back to the default", async () => {
		serveMaterials()
		const { router } = await renderPanel("/study-materials?tab=erp")

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({ tab: "all" })
		})
	})
})

describe("StudyMaterialsPanel — layout choice", () => {
	it("writes a layout switch to ?view= and remembers it", async () => {
		const user = userEvent.setup()
		serveMaterials()
		const { router } = await renderPanel()
		await screen.findByText("2026 FRM Exam Part II Books")

		await user.click(screen.getByRole("radio", { name: "List view" }))

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({ view: "list" })
		})
		expect(useListViewStore.getState().preferred["study-materials"]).toBe("list")
		expect(screen.getByText("2026 FRM Exam Part II Books")).toBeInTheDocument()
	})
})
