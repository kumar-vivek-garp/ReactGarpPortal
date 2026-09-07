import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { ProgramDetailRail } from "@/components/molecules/program-detail-rail"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	examPartInfo,
	examResources,
	programDetail,
} from "@/testing/factories/programs"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const renderRail = (detail: ReturnType<typeof programDetail>) =>
	renderWithRouterProviders(<ProgramDetailRail detail={detail} />)

describe("the exam resources block", () => {
	it("shows the learning platform and ADA rows only when the org supplies URLs", async () => {
		const { unmount } = await renderRail(
			programDetail({
				examResources: examResources({
					eLearningPlatformAccessURL: "https://learning.example.test/sso",
					eLearningPlatformName: "BenchPrep",
					ADAFormAccessURL: "https://ada.example.test/form",
				}),
			}),
		)
		const glp = screen.getByRole("link", { name: "GARP Learning Platform" })
		expect(glp).toHaveAttribute("href", "https://learning.example.test/sso")
		expect(glp).toHaveAttribute("target", "_blank")
		expect(screen.getByText("via BenchPrep")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "ADA Application" })).toHaveAttribute(
			"href",
			"https://ada.example.test/form",
		)
		unmount()

		await renderRail(programDetail({ examResources: examResources() }))
		expect(
			screen.queryByRole("link", { name: "GARP Learning Platform" }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: "ADA Application" }),
		).not.toBeInTheDocument()
	})

	it("links errata to the real errata page, and only for programmes that have one", async () => {
		const { unmount } = await renderRail(programDetail({ programType: "frm" }))
		expect(
			screen.getByRole("link", { name: "Submit Errata" }).getAttribute("href"),
		).toContain("/programs/frm/errata")
		unmount()

		// FRR25 has no published curriculum to report against (FRR itself
		// does — the errataForm action accepts it).
		await renderRail(programDetail({ programType: "frr25" }))
		expect(
			screen.queryByRole("link", { name: "Submit Errata" }),
		).not.toBeInTheDocument()
	})

	it("filters study materials to the programme", async () => {
		await renderRail(programDetail({ programType: "RiskAI" }))
		expect(
			screen.getByRole("link", { name: "Study Materials" }).getAttribute("href"),
		).toBe("/study-materials?tab=rai")
	})

	it("offers the prep-provider opt-in until it is taken up, and never for ERP", async () => {
		const user = userEvent.setup()
		const { unmount } = await renderRail(programDetail({ programType: "FRM" }))
		await user.click(screen.getByRole("button", { name: "Need Help Studying?" }))
		expect(
			await screen.findByRole("dialog", { name: "Need Help Studying?" }),
		).toBeInTheDocument()
		unmount()

		const { unmount: unmountOpted } = await renderRail(
			programDetail({
				programType: "FRM",
				examResources: examResources({ IsOptedIntoEPP: true }),
			}),
		)
		expect(
			screen.queryByRole("button", { name: "Need Help Studying?" }),
		).not.toBeInTheDocument()
		unmountOpted()

		await renderRail(programDetail({ programType: "ERP" }))
		expect(
			screen.queryByRole("button", { name: "Need Help Studying?" }),
		).not.toBeInTheDocument()
	})
})

describe("the member details block", () => {
	/** Identity is only shown while a sitting is in play — scheduling open here. */
	const inPlay = (overrides = {}) =>
		programDetail({ isAnyPartSchedulingOpen: true, ...overrides })

	it("stays away entirely for a member with nothing on file and no OSTA duty", async () => {
		await renderRail(inPlay())
		expect(
			screen.queryByRole("heading", { name: "Member details" }),
		).not.toBeInTheDocument()
	})

	it("stays away once no sitting is in play, whatever is on file", async () => {
		await renderRail(
			programDetail({
				IDName: "ADA LOVELACE",
				isOSTACandidate: true,
				examPart1Info: examPartInfo({
					examPartState: "SchedulingClosedResultsAvailable",
				}),
			}),
		)
		expect(
			screen.queryByRole("heading", { name: "Member details" }),
		).not.toBeInTheDocument()
	})

	it("shows the ID on file, read-only, masking the number until asked", async () => {
		const user = userEvent.setup()
		await renderRail(
			inPlay({
				IDName: "ADA LOVELACE",
				IDType: "Passport",
				IDNumber: "••••1234",
				phoneCode: "+44",
				phoneNumber: "2071234567",
			}),
		)
		expect(
			screen.getByRole("heading", { name: "Member details" }),
		).toBeInTheDocument()
		expect(screen.getByText("ADA LOVELACE")).toBeInTheDocument()
		expect(screen.getByText("+44 2071234567")).toBeInTheDocument()
		expect(screen.queryByText("••••1234")).not.toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /Update ID|Add your ID/ }),
		).not.toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Contact Member Services" }),
		).toHaveAttribute("href", expect.stringMatching(/^mailto:memberservices@garp\.com/))

		await user.click(screen.getByRole("button", { name: "Show ID number" }))
		expect(screen.getByText("••••1234")).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Show ID number" }),
		).not.toBeInTheDocument()
	})

	it("offers the empty-handed OSTA candidate the Add control — they need it most", async () => {
		server.use(
			http.get("/services/apexrest/memberportal/osta", () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						ostaIdInfo: null,
					}),
				),
			),
			sdkGraphqlHandler({}),
		)
		const user = userEvent.setup()
		await renderRail(inPlay({ isOSTACandidate: true }))

		const add = screen.getByRole("button", { name: /Add your ID/ })
		expect(screen.getByText("No ID on file.")).toBeInTheDocument()

		await user.click(add)
		expect(
			await screen.findByRole("dialog", { name: "Identity details" }),
		).toBeInTheDocument()
	})

	it("relabels to Update once an ID is stored, and lists the OSTA details", async () => {
		await renderRail(
			inPlay({
				isOSTACandidate: true,
				IDName: "ADA LOVELACE",
				OSTANameInChinese: "阿达",
				OSTAWorkingStatus: "Working",
			}),
		)
		expect(screen.getByRole("button", { name: /Update ID/ })).toBeInTheDocument()
		expect(screen.getByText("OSTA details")).toBeInTheDocument()
		expect(screen.getByText("阿达")).toBeInTheDocument()
		expect(screen.getByText("Working")).toBeInTheDocument()
	})

	it("keeps the OSTA list read-only for a member no longer flagged", async () => {
		await renderRail(
			inPlay({
				isOSTACandidate: false,
				OSTANameInChinese: "阿达",
			}),
		)
		// Not a candidate: the OSTA rows are hidden with the rest.
		expect(
			screen.queryByRole("heading", { name: "Member details" }),
		).not.toBeInTheDocument()
	})
})
