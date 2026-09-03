import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { renderFileRoute } from "@/testing/file-route"
import { directoryOrg } from "@/testing/msw/handlers/directory"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const mount = (entry = "/member-directory") =>
	renderFileRoute(Route, {
		id: "/_appLayout/member-directory/",
		path: "/member-directory/",
		initialEntries: [entry],
	})

/* Thin shell over MemberDirectoryPanel, which has its own three-file suite. */
describe("/member-directory page", () => {
	it("renders the directory heading and search box", async () => {
		server.use(...directoryOrg().handlers)
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "Member Directory" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("textbox", {
				name: "Search the member directory",
			}),
		).toBeInTheDocument()
	})

	it("seeds the search term from ?q=", async () => {
		server.use(...directoryOrg().handlers)
		await mount("/member-directory?q=ada")

		expect(await screen.findByDisplayValue("ada")).toBeInTheDocument()
	})
})
