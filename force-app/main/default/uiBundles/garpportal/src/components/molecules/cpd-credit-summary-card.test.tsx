import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { afterEach, describe, expect, it, vi } from "vitest"

import { CpdCreditSummaryCard } from "@/components/molecules/cpd-credit-summary-card"
import { CPD_NO_REQUIREMENT_MESSAGE } from "@/config/cpd"
import { cpdCycleInfo } from "@/testing/factories/cpd"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const certCycle = (overrides: Parameters<typeof cpdCycleInfo>[0] = {}) =>
	cpdCycleInfo({
		isFRMCompleted: true,
		completedFRMCertURL: "/apex/CPDCertificate_FRM?id=a-1",
		attestationID: "att-1",
		...overrides,
	})

afterEach(() => {
	vi.restoreAllMocks()
})

describe("the bars, or the honest absence of them", () => {
	it("names the cycle and says plainly when no credits are required", () => {
		renderWithProviders(
			<CpdCreditSummaryCard
				cycle={cpdCycleInfo({
					isFRMActive: false,
					creditsRequired: null,
					creditsRequiredFRM: null,
				})}
			/>,
		)
		expect(screen.getByText("2025/2027 Credit Summary")).toBeInTheDocument()
		expect(screen.getByText(CPD_NO_REQUIREMENT_MESSAGE)).toBeInTheDocument()
	})
})

describe("the attestation gate on certificates", () => {
	it("links straight to the PDF once the cycle is attested", () => {
		renderWithProviders(
			<CpdCreditSummaryCard cycle={certCycle({ isAttested: true })} />,
		)
		const link = screen.getByRole("link", { name: /FRM/ })
		expect(link.getAttribute("href")).toContain("/apex/CPDCertificate_FRM")
		expect(
			screen.queryByText(/asked to attest this cycle/),
		).not.toBeInTheDocument()
	})

	it("interposes the attestation dialog first, then opens the certificate", async () => {
		server.use(
			http.post("/services/apexrest/memberportal/cpdAttest", () =>
				HttpResponse.json(
					memberPortalEnvelope({
						status: "Success",
						msg: null,
						claimId: null,
					}),
				),
			),
		)
		const open = vi.spyOn(window, "open").mockReturnValue(null)
		const user = userEvent.setup()
		renderWithProviders(<CpdCreditSummaryCard cycle={certCycle()} />)

		expect(screen.getByText(/asked to attest this cycle/)).toBeInTheDocument()
		// Not a link — an unattested member must not reach the PDF directly.
		expect(screen.queryByRole("link")).not.toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: /FRM/ }))
		const dialog = await screen.findByRole("dialog")
		expect(open).not.toHaveBeenCalled()

		await user.click(
			screen.getByRole("checkbox", { name: /I attest that all I have submitted/ }),
		)
		await user.click(screen.getByRole("checkbox", { name: /Code of Conduct/ }))
		await user.click(screen.getByRole("button", { name: "Submit" }))

		await waitFor(() => expect(open).toHaveBeenCalledTimes(1))
		expect(String(open.mock.calls[0][0])).toContain("/apex/CPDCertificate_FRM")
		await waitFor(() => expect(dialog).not.toBeInTheDocument())
	})

	it("cancelling the dialog opens nothing", async () => {
		const open = vi.spyOn(window, "open").mockReturnValue(null)
		const user = userEvent.setup()
		renderWithProviders(<CpdCreditSummaryCard cycle={certCycle()} />)

		await user.click(screen.getByRole("button", { name: /FRM/ }))
		await screen.findByRole("dialog")
		await user.click(screen.getByRole("button", { name: "Cancel" }))

		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})
		expect(open).not.toHaveBeenCalled()
	})

	it("offers no certificate row for an unfinished designation", () => {
		renderWithProviders(
			<CpdCreditSummaryCard
				cycle={cpdCycleInfo({ isFRMCompleted: false })}
			/>,
		)
		expect(screen.queryByRole("button", { name: /FRM/ })).not.toBeInTheDocument()
		expect(screen.queryByRole("link")).not.toBeInTheDocument()
	})
})
