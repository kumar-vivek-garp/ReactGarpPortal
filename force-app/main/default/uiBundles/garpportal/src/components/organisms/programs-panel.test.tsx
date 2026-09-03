import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { beforeEach, describe, expect, it } from "vitest"

import type { ProgramsView as ProgramsPayload } from "@/api/programs/types"
import { ProgramsPanel } from "@/components/organisms/programs-panel"
import type { ProgramsTab, ProgramsView } from "@/config/programs"
import { useListViewStore } from "@/store/list-view-store"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const PROGRAMS_PATH = "/services/apexrest/memberportal/programs"
const EXAM_RESULTS_PATH = "/services/apexrest/memberportal/examResults"

const enrolledFrm = () => ({
	programType: "frm",
	adminPartIName: null,
	adminPartIIName: null,
	programInformation: null,
})

function servePrograms(overrides: Partial<ProgramsPayload> = {}) {
	server.use(
		http.get(PROGRAMS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					enrolledPrograms: [],
					completedPrograms: [],
					otherPrograms: [],
					hasCPDProgram: false,
					hasExamResults: false,
					microCourseConfig: null,
					...overrides,
				}),
			),
		),
	)
}

async function renderPanel(tab?: ProgramsTab, view?: ProgramsView) {
	return renderWithRouterProviders(<ProgramsPanel tab={tab} view={view} />, {
		path: "/programs",
	})
}

beforeEach(() => {
	window.localStorage.clear()
	useListViewStore.setState({ preferred: {} })
})

describe("ProgramsPanel — resolution and counts", () => {
	it("lands an enrolled member on In Progress when the URL names no tab", async () => {
		servePrograms({
			enrolledPrograms: [enrolledFrm()],
			completedPrograms: [{ programType: "scr", programInformation: null }],
		})
		await renderPanel()

		expect(
			await screen.findByRole("tab", { name: /In Progress.*\(1\)/, selected: true }),
		).toBeInTheDocument()
		// Bucket view: no All-view section headings once the enter settles.
		await waitFor(() => {
			expect(
				screen.queryByRole("heading", { name: /In Progress/ }),
			).not.toBeInTheDocument()
		})
		expect(
			screen.getByRole("tab", { name: /^All.*\(2\)/ }),
		).toBeInTheDocument()
		expect(screen.getByRole("tab", { name: /Completed.*\(1\)/ })).toBeInTheDocument()
	})

	it("shows a bucket's own empty state when it is empty", async () => {
		servePrograms({ enrolledPrograms: [enrolledFrm()] })
		await renderPanel("completed")

		expect(
			await screen.findByText("No completed programs"),
		).toBeInTheDocument()
	})

	it("shows the error line when the listing fails", async () => {
		server.use(
			http.get(PROGRAMS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await renderPanel()

		expect(
			await screen.findByText(/couldn't load your programs/),
		).toBeInTheDocument()
	})
})

describe("ProgramsPanel — navigation writes", () => {
	it("a tab click writes ?tab=", async () => {
		const user = userEvent.setup()
		servePrograms({ enrolledPrograms: [enrolledFrm()] })
		const { router } = await renderPanel()
		// Counted pills only exist on the live panel, never the pending shell.
		await screen.findByRole("tab", { name: /In Progress.*\(1\)/ })

		await user.click(screen.getByRole("tab", { name: /^All/ }))

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({ tab: "all" })
		})
	})

	it("a layout switch writes ?view= and is remembered for next time", async () => {
		const user = userEvent.setup()
		servePrograms({ enrolledPrograms: [enrolledFrm()] })
		const { router } = await renderPanel()
		await screen.findByRole("tab", { name: /In Progress.*\(1\)/ })

		// The in-progress bucket defaults to list, so grid is the real switch.
		await user.click(screen.getByRole("radio", { name: "Grid view" }))

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({ view: "grid" })
		})
		expect(useListViewStore.getState().preferred.programs).toBe("grid")
	})
})

describe("ProgramsPanel — the Results chip", () => {
	it("fetches results only when the payload says some exist, then chips the program", async () => {
		let resultsHits = 0
		servePrograms({
			enrolledPrograms: [enrolledFrm()],
			hasExamResults: true,
		})
		server.use(
			http.get(EXAM_RESULTS_PATH, () => {
				resultsHits += 1
				return HttpResponse.json(
					memberPortalEnvelope([
						{ id: "res-1", programType: "FRM", examType: "FRM" },
					]),
				)
			}),
		)
		await renderPanel()

		expect(
			await screen.findByRole("link", { name: "View exam results for frm" }),
		).toBeInTheDocument()
		expect(resultsHits).toBeGreaterThan(0)
	})

	it("never asks for results when the payload says there are none", async () => {
		// No examResults handler: a request would fail the strict MSW policy.
		servePrograms({ enrolledPrograms: [enrolledFrm()] })
		await renderPanel()

		await screen.findByRole("tab", { name: /In Progress.*\(1\)/ })
		expect(
			screen.queryByRole("link", { name: "View exam results for frm" }),
		).not.toBeInTheDocument()
	})
})
