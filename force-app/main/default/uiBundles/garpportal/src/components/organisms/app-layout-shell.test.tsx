import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { programsQueryKeys } from "@/api/programs"
import type { ProgramsView } from "@/api/programs/types"
import { TooltipProvider } from "@/components/atoms/tooltip"
import { AppLayoutShell } from "@/components/organisms/app-layout-shell"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

const ALERT_BAR_PATH = "/services/apexrest/memberportal/alertBar"

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003-member",
	photoUrl: null,
}

function programsView(): ProgramsView {
	return {
		statusMessage: null,
		statusCode: 200,
		enrolledPrograms: [],
		completedPrograms: [],
		otherPrograms: [],
		hasCPDProgram: false,
		hasExamResults: false,
		microCourseConfig: null,
	}
}

function serveNoAlert() {
	server.use(
		http.get(ALERT_BAR_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: "No alerts found",
					statusCode: 200,
					examType: null,
					examPart: null,
					alertStatus: null,
					deadline: null,
					orderId: null,
					route: null,
				}),
			),
		),
	)
}

describe("AppLayoutShell", () => {
	it("wraps page content in the full portal chrome", async () => {
		serveNoAlert()
		const queryClient = createTestQueryClient(MEMBER)
		queryClient.setQueryData(programsQueryKeys.view, programsView())

		await renderWithRouterProviders(
			<TooltipProvider>
				<AppLayoutShell>
					<p>page content under test</p>
				</AppLayoutShell>
			</TooltipProvider>,
			{ path: "/dashboard", queryClient },
		)

		// The page's children land inside the main region…
		expect(screen.getByRole("main")).toHaveTextContent(
			"page content under test",
		)
		// …surrounded by the toolbar chrome and the footer.
		expect(screen.getAllByRole("banner").length).toBeGreaterThanOrEqual(1)
		expect(screen.getByRole("contentinfo")).toBeInTheDocument()
		// The sidebar greets the signed-in member by name.
		expect(screen.getAllByText("Ada Lovelace").length).toBeGreaterThanOrEqual(1)
	})
})
