import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { beforeEach, describe, expect, it } from "vitest"

import { Route } from "@/pages/_appLayout/study-materials/index"
import { useListViewStore } from "@/store/list-view-store"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

const STUDY_MATERIALS_PATH = "/services/apexrest/memberportal/studyMaterials"

/** Legacy Apex buckets — normalized client-side into programs/entitlements. */
function serveMaterials(
	info: Record<string, Array<Record<string, unknown>>> = {
		frmStudyMaterials: [
			{ title: "FRM Study Guide", productCode: "SM-FRM-1" },
			{ title: "FRM eBooks", productCode: "SM-FRM-2", isOwned: true },
		],
		scrStudyMaterials: [{ title: "SCR Handbook", productCode: "SM-SCR-1" }],
	},
) {
	server.use(
		http.get(STUDY_MATERIALS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					studyMaterialsInfo: info,
				}),
			),
		),
	)
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

describe("StudyMaterialsPanel — sections", () => {
	it("separates owned materials, with their archive link, from the catalogue", async () => {
		serveMaterials()
		await renderPanel()

		expect(
			await screen.findByRole("heading", { name: /My Materials.*\(1\)/ }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: /Catalogue.*\(3\)/ }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: /My Access Links/ }),
		).toHaveAttribute("href", "/study-materials/archive")
	})

	it("skips the owned section entirely when nothing is owned", async () => {
		serveMaterials({
			frmStudyMaterials: [{ title: "FRM Study Guide", productCode: "SM-1" }],
		})
		await renderPanel()

		expect(await screen.findByText("FRM Study Guide")).toBeInTheDocument()
		expect(
			screen.queryByRole("heading", { name: /My Materials/ }),
		).not.toBeInTheDocument()
		// A single program earns no filter pills either.
		expect(screen.queryByRole("tab")).not.toBeInTheDocument()
	})

	it("shows the overall empty line when the org publishes nothing", async () => {
		serveMaterials({})
		await renderPanel()

		expect(
			await screen.findByText(/No study materials published yet/),
		).toBeInTheDocument()
	})
})

describe("StudyMaterialsPanel — program tabs", () => {
	it("offers a pill per program and scopes both sections to the picked one", async () => {
		serveMaterials()
		await renderPanel("/study-materials?tab=scr")

		expect(await screen.findByText("SCR Handbook")).toBeInTheDocument()
		expect(screen.getByRole("tab", { name: /All/ })).toBeInTheDocument()
		expect(screen.queryByText("FRM Study Guide")).not.toBeInTheDocument()
		// FRM's owned entitlement does not leak into the SCR tab.
		expect(
			screen.queryByRole("heading", { name: /My Materials/ }),
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
		await screen.findByText("FRM Study Guide")

		await user.click(screen.getByRole("radio", { name: "List view" }))

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({ view: "list" })
		})
		expect(useListViewStore.getState().preferred["study-materials"]).toBe(
			"list",
		)
		expect(screen.getByText("FRM Study Guide")).toBeInTheDocument()
	})
})
