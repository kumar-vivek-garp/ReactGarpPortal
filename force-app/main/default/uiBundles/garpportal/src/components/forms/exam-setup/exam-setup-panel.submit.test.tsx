import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { ExamSetupIdSaveResult, ExamSetupView } from "@/api/exam-setup"
import { ExamSetupPanel } from "@/components/forms/exam-setup/exam-setup-panel"
import { accountOptionsView } from "@/testing/factories/account-options"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	examSetupAuthorizeResult,
	examSetupIdInfo,
	examSetupSaveResult,
	examSetupView,
} from "@/testing/factories/exam-setup"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const FORM_PATH = "/services/apexrest/memberportal/examSetup"
const OPTIONS_PATH = "/services/apexrest/memberportal/options"
const SAVE_PATH = "/services/apexrest/memberportal/examSetupId"
const FEES_PATH = "/services/apexrest/memberportal/examSetupFees"
const AUTHORIZE_PATH = "/services/apexrest/memberportal/examSetupAuthorize"

type Spy = { saves: unknown[]; feeCalls: unknown[]; authorizeCalls: unknown[] }

const FEE_LINES = [
	{ name: "FRM Part I from Nov 2026 to May 2027", type: "fee", amount: 250, description: "Standard exam administration change fee", productCode: "FRM1", glCode: "4040", accountingCode: null, examRegId: null, examSiteId: null },
	{ name: "OSTA Location Fee", type: "refund", amount: 40, description: null, productCode: "CHLF", glCode: "2008", accountingCode: null, examRegId: null, examSiteId: null },
]

function org({
	view = examSetupView(),
	save = examSetupSaveResult(),
}: { view?: ExamSetupView; save?: ExamSetupIdSaveResult } = {}): Spy {
	const spy: Spy = { saves: [], feeCalls: [], authorizeCalls: [] }
	server.use(
		http.get(FORM_PATH, () => HttpResponse.json(memberPortalEnvelope(view))),
		http.get(OPTIONS_PATH, () => HttpResponse.json(memberPortalEnvelope(accountOptionsView()))),
		http.post(SAVE_PATH, async ({ request }) => {
			spy.saves.push(await request.json())
			return HttpResponse.json(memberPortalEnvelope(save), { status: save.statusCode })
		}),
		http.post(FEES_PATH, async ({ request }) => {
			spy.feeCalls.push(await request.json())
			return HttpResponse.json(
				memberPortalEnvelope({ statusMessage: null, statusCode: 200, examType: "FRM", fees: FEE_LINES, examEmailParts: null, deferralSubType: "Deferral Standard", transactionType: "Salesforce - Deferral" }),
			)
		}),
	)
	return spy
}

const mount = () => renderWithRouterProviders(<ExamSetupPanel programType="frm" />)
const save = async (user: ReturnType<typeof userEvent.setup>) => {
	await user.click(await screen.findByRole("button", { name: "Save exam setup" }))
}

describe("ExamSetupPanel — validation", () => {
	it("names the field at fault instead of disabling the button", async () => {
		const user = userEvent.setup()
		const spy = org()
		await mount()
		await user.clear(await screen.findByLabelText(/^Name as it appears on your ID/))

		const button = screen.getByRole("button", { name: "Save exam setup" })
		expect(button).toBeEnabled()
		await user.click(button)

		expect(await screen.findByText("Name as it appears on your ID is required.")).toBeInTheDocument()
		expect(spy.saves).toHaveLength(0)
	})

	it("catches a mistyped confirmation before anything is written", async () => {
		const user = userEvent.setup()
		const spy = org()
		await mount()
		const confirm = await screen.findByLabelText(/^Confirm ID number/)
		await user.clear(confirm)
		await user.type(confirm, "99999")
		await save(user)

		expect(await screen.findByText("The two ID numbers do not match.")).toBeInTheDocument()
		expect(spy.saves).toHaveLength(0)
	})

	it("requires the OSTA consent tick", async () => {
		const user = userEvent.setup()
		const spy = org({ view: examSetupView({ idInfo: examSetupIdInfo({ isOSTA: true }) }) })
		await mount()
		await save(user)

		expect(
			await screen.findByText("You must agree before we can share your details with OSTA."),
		).toBeInTheDocument()
		expect(spy.saves).toHaveLength(0)
	})
})

describe("ExamSetupPanel — the save and what follows", () => {
	it("posts both halves in one call and lands on the outcome", async () => {
		const user = userEvent.setup()
		const spy = org()
		await mount()
		await save(user)

		expect(await screen.findByText("Thank you")).toBeInTheDocument()
		expect(screen.queryByRole("button", { name: "Save exam setup" })).not.toBeInTheDocument()
		expect(spy.saves).toEqual([
			{
				programType: "frm",
				id: {
					idName: "Ada Lovelace",
					mobilePhoneLocation: "United States (+1)",
					mobilePhoneNumber: "5551234",
					idType: "passport",
					idNumber: "45678",
					idExpireDate: "01/01/2030",
				},
				selection: {
					selectedAdminPart1: "admin-may",
					selectedSitePart1: "site-london",
					selectedAdminPart2: null,
					selectedSitePart2: null,
				},
			},
		])
	})

	// Every deferral rule arrives this way. It lands against the form the
	// member has to change, not as a toast over a screen they have left.
	it("keeps a refusal on the form, in the server's own words", async () => {
		const user = userEvent.setup()
		org({ save: examSetupSaveResult({ statusCode: 505, statusMessage: "Part II cannot be taken before Part I" }) })
		await mount()
		await save(user)

		expect(await screen.findByRole("alert")).toHaveTextContent("Part II cannot be taken before Part I")
		expect(screen.getByRole("button", { name: "Save exam setup" })).toBeInTheDocument()
	})

	it("reports a transport failure the same way", async () => {
		const user = userEvent.setup()
		org()
		server.use(
			http.post(SAVE_PATH, () =>
				HttpResponse.json(
					{ status: "Error", statusCode: 500, errorMessage: "The exam setup service is unavailable.", data: {} },
					{ status: 500 },
				),
			),
		)
		await mount()
		await save(user)

		expect(await screen.findByRole("alert")).toHaveTextContent("The exam setup service is unavailable.")
	})

	it("prices the change and offers checkout when a fee is due", async () => {
		const user = userEvent.setup()
		const spy = org({
			save: examSetupSaveResult({ nextScreen: "Pay Fees", paymentRequired: true, examModificationId: "a0M999" }),
		})
		await mount()
		await save(user)

		expect(await screen.findByText("There's a fee for this change")).toBeInTheDocument()
		expect(spy.feeCalls).toEqual([{ modificationId: "a0M999" }])
		// A refund counts against the total rather than reading as a charge.
		expect(await screen.findByText("−$40.00")).toBeInTheDocument()
		expect(screen.getByText("$210.00")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Pay Fees/ })).toHaveAttribute(
			"href",
			expect.stringContaining("myprograms/setup/feescheckout/a0M999"),
		)
	})

	it("does not price anything when nothing is owed", async () => {
		const user = userEvent.setup()
		const spy = org()
		await mount()
		await save(user)
		await screen.findByText("Thank you")
		expect(spy.feeCalls).toHaveLength(0)
	})

	it("pushes to the provider and offers the scheduling links", async () => {
		const user = userEvent.setup()
		const spy = org({ save: examSetupSaveResult({ nextScreen: "Check Authorization", schedulingRequired: true }) })
		server.use(
			http.post(AUTHORIZE_PATH, async ({ request }) => {
				spy.authorizeCalls.push(await request.json())
				return HttpResponse.json(
					memberPortalEnvelope(
						examSetupAuthorizeResult({
							isAuthorized: true,
							examScheduleExamURLPart1: "https://provider.example/one",
							examScheduleExamURLPart2: "https://provider.example/two",
						}),
					),
				)
			}),
		)
		await mount()
		await save(user)

		expect(await screen.findByText("Your exam setup was successful.")).toBeInTheDocument()
		expect(spy.authorizeCalls).toEqual([{ programType: "frm", isRetry: false }])
		expect(screen.getByRole("link", { name: /Schedule Exam Part I$/ })).toHaveAttribute("href", "https://provider.example/one")
		expect(screen.getByRole("link", { name: /Schedule Exam Part II$/ })).toHaveAttribute("href", "https://provider.example/two")
	})

	// We genuinely do not know whether the provider took it, so the screen must
	// say so rather than claim either way. The two-attempt retry itself is
	// covered with fake timers in use-exam-setup.authorize.test.ts.
	it("says the setup is not completed when the provider cannot be reached", async () => {
		const user = userEvent.setup()
		org({ save: examSetupSaveResult({ nextScreen: "Check Authorization", schedulingRequired: true }) })
		server.use(
			http.post(AUTHORIZE_PATH, () =>
				HttpResponse.json(
					{ status: "Error", statusCode: 500, errorMessage: "Provider unreachable", data: {} },
					{ status: 500 },
				),
			),
		)
		await mount()
		await save(user)

		expect(await screen.findByText("Your exam setup was not completed.")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Contact member services/ })).toBeInTheDocument()
	})
})
