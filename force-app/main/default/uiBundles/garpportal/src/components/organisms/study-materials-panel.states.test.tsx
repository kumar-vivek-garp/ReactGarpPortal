import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { Route } from "@/pages/_appLayout/study-materials/index"
import { renderFileRoute } from "@/testing/file-route"
import {
	memberPortalError,
	memberPortalRefusal,
} from "@/testing/factories/envelope"
import {
	deniedStudyMaterials,
	myEBooksWithKey,
	purchasable,
	studyMaterialsPayload,
} from "@/testing/factories/study-materials"
import {
	MY_EBOOKS_PATH,
	STUDY_MATERIALS_PATH,
	studyMaterialsOrg,
} from "@/testing/msw/handlers/study-materials"
import { server } from "@/testing/msw/server"

const mount = () =>
	renderFileRoute(Route, {
		id: "/_appLayout/study-materials/",
		path: "/study-materials/",
		initialEntries: ["/study-materials"],
	})

describe("StudyMaterialsPanel — access denied", () => {
	it("renders the members-only state with the server's own message, and no tabs", async () => {
		server.use(...studyMaterialsOrg().handlers)
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(
					memberPortalRefusal(403, "Portal Access Denied", deniedStudyMaterials(403)),
					{ status: 403 },
				),
			),
		)
		await mount()

		expect(await screen.findByText("Study materials are for members")).toBeInTheDocument()
		expect(screen.getByText("Portal Access Denied")).toBeInTheDocument()
		expect(screen.queryByRole("tab")).not.toBeInTheDocument()
		expect(screen.queryByText(/couldn't load/)).not.toBeInTheDocument()
	})

	it("falls back to its own copy when the refusal carries no message", async () => {
		server.use(...studyMaterialsOrg().handlers)
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(
					memberPortalRefusal(403, "Portal Access Denied", {
						...deniedStudyMaterials(403),
						statusMessage: null,
					}),
					{ status: 403 },
				),
			),
		)
		await mount()

		expect(await screen.findByText("Study materials are for members")).toBeInTheDocument()
		expect(screen.getByText(/couldn't confirm your membership/)).toBeInTheDocument()
	})
})

describe("StudyMaterialsPanel — nothing published", () => {
	it("shows the empty state when no bucket has anything in it", async () => {
		server.use(
			...studyMaterialsOrg({ payload: studyMaterialsPayload({}) }).handlers,
		)
		await mount()

		expect(
			await screen.findByText("No study materials for your programs yet"),
		).toBeInTheDocument()
	})
})

describe("StudyMaterialsPanel — the archive entry point", () => {
	it("is offered only to a member who holds an eBook key", async () => {
		server.use(
			...studyMaterialsOrg({
				payload: studyMaterialsPayload({ frmStudyMaterials: [purchasable()] }),
				eBooks: myEBooksWithKey(),
			}).handlers,
		)
		await mount()

		expect(
			await screen.findByRole("link", { name: /My Access Links/ }),
		).toHaveAttribute("href", "/study-materials/archive")
	})

	it("stays hidden with no keys, and when the archive cannot be read", async () => {
		server.use(
			...studyMaterialsOrg({
				payload: studyMaterialsPayload({ frmStudyMaterials: [purchasable()] }),
			}).handlers,
		)
		const { unmount } = await mount()
		await screen.findByText("2026 FRM Exam Part II Books")
		expect(screen.queryByRole("link", { name: /My Access Links/ })).not.toBeInTheDocument()
		unmount()

		server.use(
			http.get(MY_EBOOKS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "archive down"), { status: 500 }),
			),
		)
		await mount()
		await screen.findByText("2026 FRM Exam Part II Books")
		expect(screen.queryByRole("link", { name: /My Access Links/ })).not.toBeInTheDocument()
		// The catalogue itself is untouched by the archive failing.
		expect(screen.queryByText(/couldn't load/)).not.toBeInTheDocument()
	})
})
