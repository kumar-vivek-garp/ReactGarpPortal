import { screen, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { personalInfoQueryKeys } from "@/api/personal-info/query-options"
import { ExamRegistrationPanel } from "@/components/forms/exam-registration/exam-registration-panel"
import { EXAM_PROGRAMS } from "@/config/registration"
import { memberPortalError } from "@/testing/factories/envelope"
import { examLoad, feesResult } from "@/testing/factories/exam"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import {
	EXAMREG_PATH,
	examregGet,
	examregPost,
} from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003-member",
	photoUrl: null,
}

async function renderPanel({
	user = null,
	seedProfile = true,
	regCode,
}: {
	user?: CurrentUser | null
	seedProfile?: boolean
	regCode?: string
} = {}) {
	const queryClient = createTestQueryClient(user)
	if (user?.contactId && seedProfile) {
		queryClient.setQueryData(
			personalInfoQueryKeys.edit(user.contactId),
			personalInfoEditData({ contactId: user.contactId }),
		)
	}
	return renderWithRouterProviders(
		<ExamRegistrationPanel
			program={EXAM_PROGRAMS.frm}
			programType="frm"
			regCode={regCode}
			onNavigateBack={vi.fn()}
		/>,
		{ user, queryClient },
	)
}

describe("ExamRegistrationPanel — load branches", () => {
	it("shows the skeleton, then the form — a guest is NOT stranded on the disabled profile query", async () => {
		const info = examregGet("info", () => examLoad())
		const fees = examregPost("fees", () => feesResult(100))
		server.use(info.handler, fees.handler)

		await renderPanel({ user: null })

		// While the load is in flight the page-shaped skeleton is up.
		expect(screen.getByText("Loading your registration…")).toBeInTheDocument()

		// The guest's profile query is disabled (no contact id) and a disabled
		// query is pending FOR EVER — the panel must not wait on it. This is the
		// regression for the guest-stuck-on-skeleton-for-ever trap.
		expect(
			await screen.findByText("Your details"),
		).toBeInTheDocument()
		expect(
			screen.queryByText("Loading your registration…"),
		).not.toBeInTheDocument()

		// Nothing was prefilled, and the sign-in offer is above the form.
		expect(screen.getByLabelText(/First name/)).toHaveValue("")
		expect(screen.getByRole("link", { name: "Sign in" })).toBeInTheDocument()
	})

	it("gives a member the form seeded from their profile, without identity controls", async () => {
		const info = examregGet("info", () => examLoad({ isAuthenticated: true }))
		const fees = examregPost("fees", () => feesResult(100))
		server.use(info.handler, fees.handler)

		await renderPanel({ user: MEMBER })

		expect(
			await screen.findByText("Contact details"),
		).toBeInTheDocument()
		// Prefill reached react-hook-form before mount — the phone shows the
		// member's own number, and the composite dial code resolved.
		expect(
			screen.getByRole("textbox", { name: /Mobile phone/ }),
		).toHaveValue("5551234")
		expect(
			screen.getByRole("combobox", { name: "Mobile phone country code" }),
		).toHaveTextContent("United States (+1)")
		// Name and email stay on the record, not on the screen.
		expect(screen.queryByLabelText(/First name/)).not.toBeInTheDocument()
		expect(screen.queryByLabelText(/Email/)).not.toBeInTheDocument()
	})

	it("keeps a member on the skeleton while their profile is still loading", async () => {
		const info = examregGet("info", () => examLoad({ isAuthenticated: true }))
		server.use(
			info.handler,
			// The profile hydrate never resolves — the form must not mount and
			// then fail to seed the Radix selects.
			http.post(/\/graphql$/, () => new Promise<never>(() => undefined)),
		)

		await renderPanel({ user: MEMBER, seedProfile: false })

		expect(screen.getByText("Loading your registration…")).toBeInTheDocument()
		await waitFor(() => {
			expect(info.spy.hits).toBeGreaterThan(0)
		})
		expect(screen.getByText("Loading your registration…")).toBeInTheDocument()
		expect(
			screen.queryByText("Contact details"),
		).not.toBeInTheDocument()
	})

	it("carries the reg code into the load request", async () => {
		const urls: string[] = []
		server.use(
			http.get(`${EXAMREG_PATH}/info`, ({ request }) => {
				urls.push(request.url)
				return HttpResponse.json({
					status: "Success",
					statusCode: 200,
					errorMessage: null,
					data: examLoad(),
				})
			}),
			examregPost("fees", () => feesResult(100)).handler,
		)

		await renderPanel({ user: null, regCode: "TEAM24" })

		await screen.findByText("Your details")
		expect(urls[0]).toContain("regCode=TEAM24")
	})

	it("shows the load failure with the server's own message", async () => {
		server.use(
			http.get(`${EXAMREG_PATH}/info`, () =>
				HttpResponse.json(
					memberPortalError(500, "The registration service is down."),
					{ status: 500 },
				),
			),
		)

		await renderPanel({ user: null })

		expect(
			await screen.findByRole("heading", { name: "Unable to open registration" }),
		).toBeInTheDocument()
		expect(
			screen.getByText("The registration service is down."),
		).toBeInTheDocument()
		// A guest's only way out is the public site — no in-app back link.
		expect(
			screen.getByRole("link", { name: "Back to GARP.org" }),
		).toHaveAttribute("href", "https://www.garp.org")
		expect(
			screen.queryByRole("link", { name: "Programs" }),
		).not.toBeInTheDocument()
	})

	it("shows a refusal as a notice with the server sentence, not as an error", async () => {
		const info = examregGet("info", () =>
			examLoad({
				isAuthenticated: true,
				eligibility: {
					isEligible: false,
					message: "Registration opens in March.",
				},
				examSelection: null,
			}),
		)
		server.use(info.handler)

		await renderPanel({ user: MEMBER })

		expect(
			await screen.findByRole("heading", { name: "Registration is not open" }),
		).toBeInTheDocument()
		expect(screen.getByText("Registration opens in March.")).toBeInTheDocument()
		// A member keeps the normal way back; no exit to garp.org is offered.
		expect(screen.getByRole("link", { name: "Programs" })).toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: "Back to GARP.org" }),
		).not.toBeInTheDocument()
	})

	it("falls back to its own wording when the refusal has no message", async () => {
		const info = examregGet("info", () =>
			examLoad({
				eligibility: { isEligible: false },
				examSelection: null,
			}),
		)
		server.use(info.handler)

		await renderPanel({ user: null })

		expect(
			await screen.findByText(
				"Registration is not currently open for this exam.",
			),
		).toBeInTheDocument()
	})
})
