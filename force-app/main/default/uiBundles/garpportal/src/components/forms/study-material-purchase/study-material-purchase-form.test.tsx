import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { afterEach, describe, expect, it } from "vitest"

import { memberPortalError } from "@/testing/factories/envelope"
import {
	materialQuote,
	materialPurchaseResult,
} from "@/testing/factories/study-material-purchase"
import {
	MATERIAL_PURCHASE_PATH,
	materialPurchaseOrg,
	ORDER_CHECKOUT_PATH,
} from "@/testing/msw/handlers/study-materials"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

import { StudyMaterialPurchaseForm } from "./study-material-purchase-form"

const mount = (
	quote = materialQuote(),
	checkoutCancelled = false,
) =>
	renderWithRouterProviders(
		<StudyMaterialPurchaseForm
			productCode="SCRH"
			quote={quote}
			checkoutCancelled={checkoutCancelled}
		/>,
		{ path: "/study-materials/purchase/SCRH" },
	)

afterEach(() => {
	window.history.replaceState(null, "", "/")
})

describe("StudyMaterialPurchaseForm — the quote", () => {
	it("shows item, shipping and total for a printed book, plus the tax note", async () => {
		await mount()
		expect(screen.getByRole("heading", { level: 1, name: "Complete your purchase" })).toBeInTheDocument()
		expect(screen.getByRole("heading", { name: "2026 SCR Book" })).toBeInTheDocument()
		expect(screen.getByText(/posted to the address below/)).toBeInTheDocument()
		expect(screen.getByText("Shipping")).toBeInTheDocument()
		expect(screen.getByText("$15.00")).toBeInTheDocument()
		// The total reads twice: the sticky bar and the rail.
		expect(screen.getAllByText("$115.00")).toHaveLength(2)
		expect(screen.getByText(/Tax is calculated/)).toBeInTheDocument()
		// `isValid` settles after react-hook-form's mount-time validation pass.
		await waitFor(() =>
			expect(screen.getByRole("button", { name: "Continue to Payment" })).toBeEnabled(),
		)
	})

	it("asks no address for something that is not posted, and prices without shipping", async () => {
		await mount(
			materialQuote({ isShippable: false, shipping: null, total: 100, shipTo: null }),
		)
		expect(screen.queryByText("Shipping")).not.toBeInTheDocument()
		expect(screen.getByText(/Delivered online/)).toBeInTheDocument()
		expect(screen.queryByLabelText(/Street address/)).not.toBeInTheDocument()
		await waitFor(() =>
			expect(screen.getByRole("button", { name: "Continue to Payment" })).toBeEnabled(),
		)
	})

	it("says shipping is calculated at checkout when the charge is not known", async () => {
		await mount(materialQuote({ shipping: null, total: 100 }))
		expect(screen.getByText("Calculated at checkout")).toBeInTheDocument()
	})

	it("acknowledges a cancelled payment above the quote", async () => {
		await mount(materialQuote(), true)
		expect(screen.getByText("Payment cancelled")).toBeInTheDocument()
		expect(screen.getByText(/Nothing has been charged/)).toBeInTheDocument()
	})
})

describe("StudyMaterialPurchaseForm — paying", () => {
	it("posts the address from the form, then leaves for the hosted checkout", async () => {
		const org = materialPurchaseOrg()
		server.use(...org.handlers)
		const user = userEvent.setup()
		await mount()

		await user.clear(screen.getByLabelText(/City/))
		await user.type(screen.getByLabelText(/City/), "Hoboken")
		await user.click(screen.getByRole("button", { name: "Continue to Payment" }))

		await waitFor(() => expect(org.checkoutSpy.hits).toBe(1))
		expect(org.purchaseSpy.bodies[0]).toMatchObject({
			productCode: "SCRH",
			shipTo: { street: "111 Main Street", city: "Hoboken", country: "United States" },
		})
		expect(window.location.hash).toBe("#hosted-checkout")
		// The browser is leaving — the button must not re-arm.
		expect(screen.getByRole("button", { name: /Opening payment/ })).toBeDisabled()
	})

	it("re-arms Continue when the browser restores the page from its back-forward cache", async () => {
		const org = materialPurchaseOrg()
		server.use(...org.handlers)
		const user = userEvent.setup()
		await mount()

		await user.click(screen.getByRole("button", { name: "Continue to Payment" }))
		await waitFor(() => expect(org.checkoutSpy.hits).toBe(1))
		expect(screen.getByRole("button", { name: /Opening payment/ })).toBeDisabled()

		// Back from the provider: `pageshow` with `persisted`, the page's state intact.
		const restored = new Event("pageshow")
		Object.defineProperty(restored, "persisted", { value: true })
		window.dispatchEvent(restored)

		await waitFor(() =>
			expect(screen.getByRole("button", { name: "Continue to Payment" })).toBeEnabled(),
		)
		// …and a second Continue reuses the order rather than raising another.
		await user.click(screen.getByRole("button", { name: "Continue to Payment" }))
		await waitFor(() => expect(org.checkoutSpy.hits).toBe(2))
		expect(org.purchaseSpy.hits).toBe(1)
	})

	it("ignores a fresh load's pageshow — nothing to reset", async () => {
		server.use(...materialPurchaseOrg().handlers)
		await mount()
		const fresh = new Event("pageshow")
		Object.defineProperty(fresh, "persisted", { value: false })
		window.dispatchEvent(fresh)
		await waitFor(() =>
			expect(screen.getByRole("button", { name: "Continue to Payment" })).toBeEnabled(),
		)
	})

	it("renders the purchase refusal inline and lets the member try again by hand", async () => {
		server.use(...materialPurchaseOrg().handlers)
		server.use(
			http.post(MATERIAL_PURCHASE_PATH, () =>
				HttpResponse.json(memberPortalError(429, "Too many orders. Please wait."), {
					status: 429,
				}),
			),
		)
		const user = userEvent.setup()
		await mount()

		await user.click(screen.getByRole("button", { name: "Continue to Payment" }))

		expect(await screen.findByRole("alert")).toHaveTextContent("Too many orders. Please wait.")
		expect(screen.getByRole("button", { name: "Continue to Payment" })).toBeEnabled()
	})

	it("points at the saved order instead of Pay when checkout will not open", async () => {
		server.use(
			...materialPurchaseOrg({
				purchaseRespond: () => materialPurchaseResult({ orderNumber: "INV-0009" }),
			}).handlers,
		)
		server.use(
			http.post(ORDER_CHECKOUT_PATH, () =>
				HttpResponse.json(memberPortalError(501, "Open Order not found"), { status: 501 }),
			),
		)
		const user = userEvent.setup()
		await mount()

		await user.click(screen.getByRole("button", { name: "Continue to Payment" }))

		expect(await screen.findByRole("link", { name: "View order" })).toHaveAttribute(
			"href",
			"/my-account/orders/INV-0009",
		)
		expect(screen.queryByRole("button", { name: /Continue to Payment/ })).not.toBeInTheDocument()
		expect(screen.getByRole("alert")).toHaveTextContent(/Order History/)
	})
})
