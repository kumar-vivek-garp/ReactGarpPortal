import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { renderFileRoute } from "@/testing/file-route"
import { materialQuote } from "@/testing/factories/study-material-purchase"
import { MATERIAL_QUOTE_PATH } from "@/testing/msw/handlers/study-materials"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

function serveQuote() {
	const asked: string[] = []
	server.use(
		http.get(MATERIAL_QUOTE_PATH, ({ request }) => {
			asked.push(new URL(request.url).searchParams.get("productCode") ?? "")
			return HttpResponse.json(memberPortalEnvelope(materialQuote()))
		}),
	)
	return asked
}

const mount = (entry: string) =>
	renderFileRoute(Route, {
		id: "/_appLayout/study-materials/purchase/$productCode/",
		path: "/study-materials/purchase/$productCode/",
		initialEntries: [entry],
	})

describe("/study-materials/purchase/$productCode page", () => {
	it("prices the product named in the path", async () => {
		const asked = serveQuote()
		await mount("/study-materials/purchase/SCRH")

		expect(await screen.findByRole("button", { name: "Continue to Payment" })).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { level: 1, name: "Complete your purchase" }),
		).toBeInTheDocument()
		expect(asked).toEqual(["SCRH"])
		expect(screen.queryByText("Payment cancelled")).not.toBeInTheDocument()
	})

	it("recognises the provider's cancel leg, even as the router hands it over", async () => {
		serveQuote()
		// `1` reaches the schema as a NUMBER; the schema coerces it back.
		await mount("/study-materials/purchase/SCRH?checkout_cancelled=1")

		expect(await screen.findByText("Payment cancelled")).toBeInTheDocument()
	})
})
