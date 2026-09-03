import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import { feesResult } from "@/testing/factories/exam"
import { personalInfoEditData, portalAddressFields } from "@/testing/factories/personal-info"
import {
	chooseSelectOption,
	pricedExamLoad,
	renderExamForm,
} from "@/testing/exam-registration-ui"
import { examregGet, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"

function armFees(total = 100) {
	const fees = examregPost("fees", () => feesResult(total))
	server.use(fees.handler)
	return fees
}

describe("ExamRegistrationForm — member vs guest", () => {
	it("hides a member's identity controls but keeps phone and the SMS opt-in", async () => {
		armFees()
		await renderExamForm()

		// Name and email live on the record; registering does not change them.
		expect(screen.queryByLabelText(/First name/)).not.toBeInTheDocument()
		expect(screen.queryByLabelText(/Last name/)).not.toBeInTheDocument()
		expect(screen.queryByLabelText(/Email/)).not.toBeInTheDocument()

		// The phone is how exam-day changes reach a candidate — everyone is
		// asked, and the marketing opt-in stays with it.
		expect(
			screen.getByRole("textbox", { name: /Mobile phone/ }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("checkbox", { name: /promotional text messages/ }),
		).not.toBeChecked()

		// Members navigate: the back link lives in the sticky bar.
		expect(screen.getByRole("link", { name: "Programs" })).toBeInTheDocument()
		// And the guest byline has no business here.
		expect(screen.queryByText(/must sign in to continue/)).not.toBeInTheDocument()
	})

	it("gives a guest the identity fields, the byline with a sign-in offer, and no back link", async () => {
		armFees()
		await renderExamForm({ profile: null, isAuthenticated: false })

		expect(screen.getByLabelText(/First name/)).toHaveValue("")
		expect(screen.getByLabelText(/Last name/)).toHaveValue("")
		expect(screen.getByLabelText(/Email/)).toHaveValue("")

		// FRM's own byline, with the sign-in offer BEFORE anything is typed —
		// signing in is a full navigation that discards the form.
		expect(
			screen.getByText(/must sign in to continue with registration/),
		).toBeInTheDocument()
		// LOGIN_PATH is "/Login"; the return path rides along as startUrl.
		const signIn = screen.getByRole("link", { name: "Sign in" })
		expect(signIn.getAttribute("href")).toContain("/Login?startUrl=")

		// Every in-app parent is behind the session guard — no back arrow.
		expect(screen.queryByRole("link", { name: "Programs" })).not.toBeInTheDocument()

		// The page title is the same h1 for both audiences.
		expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
			/Financial Risk Manager/,
		)
	})

	it("gates Location on the address card being absent, not on being signed in", async () => {
		armFees(600)
		const user = userEvent.setup()
		await renderExamForm({ profile: null, isAuthenticated: false })

		// A guest IS asked for their location while no address card is up.
		expect(screen.getByRole("combobox", { name: "Location" })).toBeInTheDocument()

		// Wire shows the billing card, which carries its own country — asking
		// twice is two chances to disagree, so Location hands over. Same rule,
		// same audience: still a guest.
		await user.click(await screen.findByRole("radio", { name: "Wire transfer" }))
		await waitFor(() => {
			expect(
				screen.queryByRole("combobox", { name: "Location" }),
			).not.toBeInTheDocument()
		})
		expect(screen.getByText("Billing & shipping")).toBeInTheDocument()
		// The guest's identity fields survive the switch.
		expect(screen.getByLabelText(/First name/)).toBeInTheDocument()
	})

	it("starts every consent unticked, including the compliance ticks", async () => {
		armFees()
		// A German member: the billing country carries the compliance tag, so
		// the explicit policy checkboxes render instead of the implicit notice.
		await renderExamForm({
			profile: personalInfoEditData({
				billing: portalAddressFields({ country: "Germany", state: "" }),
			}),
		})

		expect(
			screen.getByText(/requires us to record these separately/),
		).toBeInTheDocument()

		for (const checkbox of screen.getAllByRole("checkbox")) {
			expect(checkbox).not.toBeChecked()
		}
		// All five statements are individually on screen.
		expect(
			screen.getByRole("checkbox", { name: /Candidate Responsibility/ }),
		).toBeInTheDocument()
		expect(screen.getByRole("checkbox", { name: /Exam Policies/ })).toBeInTheDocument()
		expect(
			screen.getByRole("checkbox", { name: /Privacy Notice/ }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("checkbox", { name: /Limitation of Liability/ }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("checkbox", { name: /Waiver and Release/ }),
		).toBeInTheDocument()
	})

	it("asks for the China identity block only once an OSTA exam centre is chosen", async () => {
		armFees()
		const options = examregGet("options", () => ({ companies: [], schools: [] }))
		server.use(options.handler)
		const user = userEvent.setup()

		const load = pricedExamLoad()
		const part1 = load.examSelection?.parts[0]
		if (part1) part1.admins[0].sites[0] = { id: "site-a1", name: "Shanghai", isOSTA: true }
		await renderExamForm({ load })

		expect(
			screen.queryByText("Identity details for your exam centre"),
		).not.toBeInTheDocument()

		await chooseSelectOption(user, "Exam part", "FRM Exam Part I")
		await chooseSelectOption(user, "Where you will sit", "Shanghai")

		// The card arrives with the choice that requires it, consent unticked.
		expect(
			await screen.findByText("Identity details for your exam centre"),
		).toBeInTheDocument()
		expect(
			screen.getByRole("checkbox", { name: /sharing my passport/ }),
		).not.toBeChecked()
		// And the site itself is flagged where it was chosen.
		expect(screen.getByText(/Simplified Chinese/)).toBeInTheDocument()
	})

	it("renders a course without the exam card or candidate acknowledgements, with the membership offer", async () => {
		armFees()
		await renderExamForm({
			load: pricedExamLoad({
				program: { type: "frr25", kind: "course" },
				examSelection: null,
				studyMaterials: [],
				membershipOffer: { productCode: "MEMI", amount: 250 },
			}),
		})

		expect(screen.queryByText("Your exam")).not.toBeInTheDocument()
		expect(
			screen.queryByRole("checkbox", { name: /Candidate Responsibility/ }),
		).not.toBeInTheDocument()
		// The upsell card, unticked — nothing lands in a cart on its own.
		expect(screen.getByText("Membership")).toBeInTheDocument()
		// Outside a compliance country the agreement is implicit, and says so.
		expect(screen.getByText(/By selecting/)).toBeInTheDocument()
	})
})
