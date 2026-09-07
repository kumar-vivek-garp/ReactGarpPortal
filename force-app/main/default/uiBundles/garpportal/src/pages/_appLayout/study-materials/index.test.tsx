import { screen, waitFor } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { toast } from "sonner"
import { describe, expect, it, vi } from "vitest"

import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { renderFileRoute } from "@/testing/file-route"
import {
	purchasable,
	studyMaterialsPayload,
} from "@/testing/factories/study-materials"
import {
	STUDY_MATERIALS_PATH,
	studyMaterialsOrg,
} from "@/testing/msw/handlers/study-materials"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

// The success return toasts through `notifySuccess`; no Toaster is mounted
// here, so the call itself is the observable.
vi.mock("sonner", () => ({
	toast: { success: vi.fn(), error: vi.fn(), warning: vi.fn() },
}))

const happy = studyMaterialsPayload({ frmStudyMaterials: [purchasable()] })

const mount = (entry = "/study-materials") =>
	renderFileRoute(Route, {
		id: "/_appLayout/study-materials/",
		path: "/study-materials/",
		initialEntries: [entry],
	})

describe("/study-materials page", () => {
	it("renders the heading and the catalogue once data arrives", async () => {
		server.use(...studyMaterialsOrg({ payload: happy }).handlers)
		await mount()

		expect(
			screen.getByRole("heading", {
				level: 1,
				name: "Study Materials for Risk Professionals",
			}),
		).toBeInTheDocument()
		expect(await screen.findByText("2026 FRM Exam Part II Books")).toBeInTheDocument()
	})

	it("keeps the heading up over the skeleton while loading", async () => {
		server.use(...studyMaterialsOrg({ payload: happy }).handlers)
		server.use(
			http.get(STUDY_MATERIALS_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope(happy))
			}),
		)
		await mount()

		expect(
			screen.getByRole("heading", {
				level: 1,
				name: "Study Materials for Risk Professionals",
			}),
		).toBeInTheDocument()
		expect(screen.getByLabelText("Loading study materials")).toBeInTheDocument()
	})

	it("shows the error state when the catalogue fails", async () => {
		server.use(...studyMaterialsOrg({ payload: happy }).handlers)
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await mount()

		expect(
			await screen.findByText(
				"We couldn't load your study materials. Please try again later.",
			),
		).toBeInTheDocument()
	})
})

describe("/study-materials page — the purchase return", () => {
	it("thanks the member once, refreshes, and drops the flag from the address", async () => {
		vi.mocked(toast.success).mockClear()
		server.use(...studyMaterialsOrg({ payload: happy }).handlers)
		// Purely numeric on purpose — the router JSON-parses search values.
		const { router } = await mount("/study-materials?purchased=1")

		await waitFor(() => {
			expect(vi.mocked(toast.success)).toHaveBeenCalledWith(
				"Purchase complete",
				expect.objectContaining({ description: expect.any(String) }),
			)
		})
		// StrictMode double-runs the effect; the ref guard makes it one toast.
		expect(vi.mocked(toast.success)).toHaveBeenCalledTimes(1)
		await waitFor(() => {
			expect(router.state.location.search).not.toHaveProperty("purchased")
		})
		expect(await screen.findByText("2026 FRM Exam Part II Books")).toBeInTheDocument()
	})
})
