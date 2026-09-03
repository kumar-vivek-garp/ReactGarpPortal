import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { afterEach, describe, expect, it, vi } from "vitest"

import { EBookArchivePanel } from "@/components/organisms/ebook-archive-panel"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const MY_EBOOKS_PATH = "/services/apexrest/memberportal/myEBooks"
const EBOOK_ACCESS_PATH = "/services/apexrest/memberportal/eBookAccess"

function myEBooksView() {
	return {
		statusMessage: null,
		statusCode: 200,
		eBooks: {
			"2026": [
				{
					title: "FRM Exam Part I",
					provider: "Mobius",
					eBookItems: [{ title: "Part I", vendorId: 4211 }],
				},
			],
		},
	}
}

afterEach(() => {
	vi.restoreAllMocks()
})

describe("EBookArchivePanel — opening a purchased title", () => {
	it("mints a reader link on Access and opens it in a new tab", async () => {
		const openSpy = vi
			.spyOn(window, "open")
			.mockImplementation(() => null)
		server.use(
			http.get(MY_EBOOKS_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(myEBooksView())),
			),
			http.get(EBOOK_ACCESS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						accessURL: "https://reader.example/frm-part-1",
					}),
				),
			),
		)
		const user = userEvent.setup()
		await renderWithRouterProviders(<EBookArchivePanel />)

		expect(
			await screen.findByRole("heading", { name: "2026" }),
		).toBeInTheDocument()
		await user.click(screen.getByRole("button", { name: /Access/ }))

		await waitFor(() => {
			expect(openSpy).toHaveBeenCalledWith(
				"https://reader.example/frm-part-1",
				"_blank",
				"noopener,noreferrer",
			)
		})
	})

	it("marks a title with no vendor item as unopenable rather than hiding it", async () => {
		server.use(
			http.get(MY_EBOOKS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						eBooks: {
							"2025": [
								{ title: "SCR Study Guide", provider: null, eBookItems: [] },
							],
						},
					}),
				),
			),
		)
		await renderWithRouterProviders(<EBookArchivePanel />)

		expect(await screen.findByText("SCR Study Guide")).toBeInTheDocument()
		expect(screen.getByText("Not available online")).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /Access/ }),
		).not.toBeInTheDocument()
	})
})
