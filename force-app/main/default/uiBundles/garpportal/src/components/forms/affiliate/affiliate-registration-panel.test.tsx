import { screen } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AffiliateRegistrationPanel } from "@/components/forms/affiliate/affiliate-registration-panel"
import { affiliateLoad } from "@/testing/factories/affiliate"
import { memberPortalError } from "@/testing/factories/envelope"
import { examregGet, EXAMREG_PATH } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

/*
 * Deliberately NO `skipSpringAnimations()` here: with `skipAnimation` on,
 * rendering the panel (whose `useSubpageTransition` spring gets fresh props
 * every render) livelocks the worker. The real springs settle in well under
 * a `findBy*` wait.
 */

function renderPanel() {
	return renderWithRouterProviders(<AffiliateRegistrationPanel />, {
		path: "/registration/affiliate",
	})
}

describe("AffiliateRegistrationPanel", () => {
	it("shows the skeleton while the load is pending", async () => {
		server.use(
			http.get(`${EXAMREG_PATH}/info`, async () => {
				await delay("infinite")
				return new HttpResponse()
			}),
		)

		await renderPanel()

		expect(
			screen.getByText("Loading Affiliate membership registration…"),
		).toBeInTheDocument()
		expect(screen.queryByRole("heading")).not.toBeInTheDocument()
		expect(screen.queryByRole("button")).not.toBeInTheDocument()
	})

	it("shows the load failure with the server's own sentence", async () => {
		server.use(
			http.get(`${EXAMREG_PATH}/info`, () =>
				HttpResponse.json(
					memberPortalError(403, "Guest access is not configured."),
					{ status: 403 },
				),
			),
		)

		await renderPanel()

		const alert = await screen.findByRole("alert")
		expect(alert).toHaveTextContent("Unable to open registration")
		expect(alert).toHaveTextContent("Guest access is not configured.")
	})

	it("shows an eligibility refusal as a message, wording from the payload", async () => {
		const info = examregGet("info", () =>
			affiliateLoad({
				eligibility: {
					isEligible: false,
					message: "This program is not currently available.",
				},
			}),
		)
		server.use(info.handler)

		await renderPanel()

		const alert = await screen.findByRole("alert")
		expect(alert).toHaveTextContent("Registration unavailable")
		expect(alert).toHaveTextContent("This program is not currently available.")
		expect(
			screen.queryByRole("button", { name: "Register" }),
		).not.toBeInTheDocument()
	})

	it("falls back to its own sentence when the refusal carries none", async () => {
		const info = examregGet("info", () =>
			affiliateLoad({ eligibility: { isEligible: false, message: null } }),
		)
		server.use(info.handler)

		await renderPanel()

		expect(await screen.findByRole("alert")).toHaveTextContent(
			"Affiliate registration is not available right now.",
		)
	})

	it("renders the form once an eligible load arrives", async () => {
		const info = examregGet("info", () => affiliateLoad())
		server.use(info.handler)

		await renderPanel()

		// The page's only heading is the form's h1 — marketing email lands here.
		expect(
			await screen.findByRole("heading", {
				level: 1,
				name: "Affiliate Membership Registration",
			}),
		).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Register" }),
		).toBeInTheDocument()
		expect(info.spy.hits).toBe(1)
	})
})
