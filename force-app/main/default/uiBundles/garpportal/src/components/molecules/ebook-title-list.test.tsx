import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { delay, http, HttpResponse } from "msw"
import { afterEach, describe, expect, it, vi } from "vitest"

import { EBookTitleList } from "@/components/molecules/ebook-title-list"
import { memberPortalError } from "@/testing/factories/envelope"
import {
	EBOOK_ACCESS_PATH,
	studyMaterialsOrg,
} from "@/testing/msw/handlers/study-materials"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const titles = [
	{ id: "111", label: "Part I", vendorId: "111", provider: "Pearson" },
	{ id: "222", label: "Part II", vendorId: "222", provider: null },
]

afterEach(() => {
	vi.restoreAllMocks()
})

describe("EBookTitleList", () => {
	it("mints a reader link for the clicked title and opens it in a new tab", async () => {
		const openSpy = vi.spyOn(window, "open").mockImplementation(() => null)
		const org = studyMaterialsOrg({ accessUrl: "https://reader.example/part-1" })
		server.use(...org.handlers)
		const user = userEvent.setup()
		renderWithProviders(<EBookTitleList titles={titles} />)

		expect(screen.getByText("Pearson")).toBeInTheDocument()
		await user.click(screen.getAllByRole("button", { name: /Read/ })[0]!)

		await waitFor(() => {
			expect(openSpy).toHaveBeenCalledWith(
				"https://reader.example/part-1",
				"_blank",
				"noopener,noreferrer",
			)
		})
		expect(org.accessSpy.bodies).toEqual(["111"])
	})

	it("holds only the clicked title while its link is minted", async () => {
		server.use(
			http.get(EBOOK_ACCESS_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json({})
			}),
		)
		const user = userEvent.setup()
		renderWithProviders(<EBookTitleList titles={titles} />)

		const [first, second] = screen.getAllByRole("button", { name: /Read/ })
		await user.click(first!)

		await waitFor(() => expect(first).toBeDisabled())
		expect(second).toBeEnabled()
	})

	it("says so inline when the vendor will not mint a link, and keeps the button", async () => {
		server.use(
			http.get(EBOOK_ACCESS_PATH, () =>
				HttpResponse.json(memberPortalError(502, "Vendor unavailable"), { status: 502 }),
			),
		)
		const user = userEvent.setup()
		renderWithProviders(<EBookTitleList titles={titles} />)

		await user.click(screen.getAllByRole("button", { name: /Read/ })[0]!)

		expect(
			await screen.findByText("Link unavailable — try again shortly"),
		).toBeInTheDocument()
		expect(screen.getAllByRole("button", { name: /Read/ })[0]).toBeEnabled()
	})

	it("marks a title with no vendor item as unopenable rather than hiding it", () => {
		renderWithProviders(
			<EBookTitleList
				titles={[{ id: "x", label: "SCR Study Guide", vendorId: null, provider: null }]}
			/>,
		)
		expect(screen.getByText("SCR Study Guide")).toBeInTheDocument()
		expect(screen.getByText("Not available online")).toBeInTheDocument()
		expect(screen.queryByRole("button")).not.toBeInTheDocument()
	})

	it("takes its verb from the caller", () => {
		renderWithProviders(<EBookTitleList titles={titles} actionLabel="Access" />)
		expect(screen.getAllByRole("button", { name: /Access/ })).toHaveLength(2)
	})
})
