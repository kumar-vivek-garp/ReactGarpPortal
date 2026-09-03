import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const MY_EBOOKS_PATH = "/services/apexrest/memberportal/myEBooks"

function serveEBooks(eBooks: Record<string, unknown>) {
	server.use(
		http.get(MY_EBOOKS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					eBooks,
				}),
			),
		),
	)
}

const mount = () =>
	renderFileRoute(Route, {
		id: "/_appLayout/study-materials/archive/",
		path: "/study-materials/archive/",
		initialEntries: ["/study-materials/archive"],
	})

describe("/study-materials/archive page", () => {
	it("renders purchased titles grouped by edition year", async () => {
		serveEBooks({
			"2024": [
				{
					title: "FRM",
					provider: "Mobius",
					eBookItems: [{ title: "Part I", vendorId: 123 }],
				},
			],
		})
		await mount()

		expect(
			screen.getByRole("heading", {
				level: 1,
				name: "Purchased Study Materials",
			}),
		).toBeInTheDocument()
		expect(
			await screen.findByRole("heading", { name: "2024" }),
		).toBeInTheDocument()
	})

	it("shows the empty state when nothing was purchased", async () => {
		serveEBooks({})
		await mount()

		expect(
			await screen.findByText("No purchased materials yet"),
		).toBeInTheDocument()
	})

	it("shows the error state when the archive fails", async () => {
		server.use(
			http.get(MY_EBOOKS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await mount()

		expect(
			await screen.findByText(
				"We couldn't load your purchased materials. Please try again later.",
			),
		).toBeInTheDocument()
	})
})
