import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { ProgramDetailRail } from "@/components/molecules/program-detail-rail"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { examResources, programDetail } from "@/testing/factories/programs"
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

		// FRR has no published curriculum to report against.
		await renderRail(programDetail({ programType: "frr" }))
		expect(
			screen.queryByRole("link", { name: "Submit Errata" }),
		).not.toBeInTheDocument()
	})

	it("always offers study materials and the prep-provider hand-off", async () => {
		await renderRail(programDetail())
		expect(
			screen.getByRole("link", { name: "Study Materials" }).getAttribute("href"),
		).toContain("/study-materials")
		expect(
			screen.getByRole("link", { name: "Need Help Studying?" }),
		).toHaveAttribute("href", "https://www.garp.org/exam-prep-providers")
	})
})

describe("the member details block", () => {
	it("stays away entirely for a member with nothing on file and no OSTA duty", async () => {
		await renderRail(programDetail())
		expect(
			screen.queryByRole("heading", { name: "Member details" }),
		).not.toBeInTheDocument()
	})

	it("shows the ID on file, read-only, for a non-OSTA member", async () => {
		await renderRail(
			programDetail({
				IDName: "ADA LOVELACE",
				IDType: "Passport",
				phoneCode: "+44",
				phoneNumber: "2071234567",
			}),
		)
		expect(
			screen.getByRole("heading", { name: "Member details" }),
		).toBeInTheDocument()
		expect(screen.getByText("ADA LOVELACE")).toBeInTheDocument()
		expect(screen.getByText("+44 2071234567")).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /Update ID|Add your ID/ }),
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
		await renderRail(programDetail({ isOSTACandidate: true }))

		const add = screen.getByRole("button", { name: /Add your ID/ })
		expect(screen.getByText("No ID on file.")).toBeInTheDocument()

		await user.click(add)
		expect(
			await screen.findByRole("dialog", { name: "Identity details" }),
		).toBeInTheDocument()
	})

	it("relabels to Update once an ID is stored, and lists the OSTA details", async () => {
		await renderRail(
			programDetail({
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
			programDetail({
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
