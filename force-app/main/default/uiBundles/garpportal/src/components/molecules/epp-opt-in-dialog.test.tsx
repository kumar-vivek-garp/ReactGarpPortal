import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import { programsQueryKeys } from "@/api/programs"
import { EppOptInDialog } from "@/components/molecules/epp-opt-in-dialog"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { eppOptInResult, programDetail } from "@/testing/factories/programs"
import { eppOptInHandler } from "@/testing/msw/handlers/programs"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

function renderDialog(programType = "FRM") {
	const onOpenChange = vi.fn()
	const view = renderWithProviders(
		<EppOptInDialog open onOpenChange={onOpenChange} programType={programType} />,
	)
	// The detail this page was built from, so the refetch is observable.
	view.queryClient.setQueryData(programsQueryKeys.detail(programType), {
		statusMessage: null,
		statusCode: 200,
		programsDetailInfo: programDetail(),
	})
	return { ...view, onOpenChange }
}

const THANKS =
	/Thank you for opting into GARP's network of Exam Prep Providers/

describe("EppOptInDialog", () => {
	it("asks the question and closes on No without writing anything", async () => {
		const { spy, handler } = eppOptInHandler()
		server.use(handler)
		const user = userEvent.setup()
		const { onOpenChange } = renderDialog()

		expect(
			screen.getByText(
				"Would you like to be contacted by GARP's network of exam prep providers?",
			),
		).toBeInTheDocument()
		await user.click(screen.getByRole("button", { name: "No" }))

		expect(onOpenChange).toHaveBeenCalledWith(false)
		expect(spy.hits).toBe(0)
	})

	it("records a Yes once, against the programme, then thanks the member and refetches", async () => {
		const { spy, handler } = eppOptInHandler()
		server.use(handler)
		const user = userEvent.setup()
		const { queryClient } = renderDialog("FRM")

		await user.click(screen.getByRole("button", { name: "Yes" }))

		expect(await screen.findByText(THANKS)).toBeInTheDocument()
		expect(spy.hits).toBe(1)
		expect(spy.bodies[0]).toEqual({ examType: "frm", optIn: true })
		await waitFor(() => {
			expect(
				queryClient.getQueryState(programsQueryKeys.detail("FRM"))
					?.isInvalidated,
			).toBe(true)
		})
		expect(screen.getByRole("button", { name: "Done" })).toBeInTheDocument()
	})

	it("keeps the question up when the org refuses", async () => {
		const { spy, handler } = eppOptInHandler(() =>
			HttpResponse.json(
				memberPortalEnvelope(
					eppOptInResult({
						statusMessage: "Exam Attempt not found",
						statusCode: 401,
					}),
				),
			),
		)
		server.use(handler)
		const user = userEvent.setup()
		renderDialog()

		await user.click(screen.getByRole("button", { name: "Yes" }))

		await waitFor(() => expect(spy.hits).toBe(1))
		expect(screen.queryByText(THANKS)).not.toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Yes" })).toBeEnabled()
	})
})
