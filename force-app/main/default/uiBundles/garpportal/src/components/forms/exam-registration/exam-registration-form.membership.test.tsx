import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import type {
	ExamRegisterRequest,
	FeesRequest,
} from "@/api/registration/exam-types"
import { EXAM_PROGRAMS, MEMBERSHIP_OFFER_COPY } from "@/config/registration"
import { examRegisterResult, verifyCustomerResult } from "@/testing/factories/exam"
import {
	membershipFeesResult,
	membershipLoad,
} from "@/testing/factories/membership-registration"
import { renderExamForm } from "@/testing/exam-registration-ui"
import { examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"

/**
 * The membership kind — GarpAppv1's `isMembership` branch: details, the
 * Risk.net add-on, payment with the auto-renew consent, addresses for the
 * offline methods, and nothing an exam or course would add. Priced like the
 * server prices it: the membership is the main line, the add-on follows it.
 */

/** Prices the cart the way Apex does, from what the form actually sent. */
function armFees() {
	const fees = examregPost<FeesRequest>("fees", (body) =>
		membershipFeesResult({
			riskNet: body.riskNetSelected === true,
			offline: Boolean(body.paymentType) && body.paymentType !== "Stripe",
		}),
	)
	server.use(fees.handler)
	return fees
}

function armSubmit() {
	const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
	// No order: the flow ends at `registered` without leaving for Stripe.
	const register = examregPost<ExamRegisterRequest>("register", () =>
		examRegisterResult({
			orderId: null,
			orderNumber: "ORD-MEM",
			registrationId: null,
			hasBilling: false,
			total: 0,
		}),
	)
	server.use(verify.handler, register.handler)
	return { verify, register }
}

const memberLoad = (contact: { id: string; isAutoRenewEnabled?: boolean } = { id: "003-member" }) =>
	membershipLoad({ isAuthenticated: true, contact })

async function renderMembership(
	options: Parameters<typeof renderExamForm>[0] = {},
) {
	return renderExamForm({
		load: memberLoad(),
		program: EXAM_PROGRAMS.membership,
		...options,
	})
}

const cardTile = () => screen.getByRole("radio", { name: /^Card$/ })
const wireTile = () => screen.getByRole("radio", { name: /Wire transfer/ })
const autoRenew = () =>
	screen.queryByRole("checkbox", { name: /Membership Automatic Renewal/ })

describe("ExamRegistrationForm — the membership kind", () => {
	it("is a membership checkout: no exam, no attestations, no course upsell, Back to Membership", async () => {
		armFees()
		await renderMembership()

		expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
			/Member Registration/,
		)
		expect(
			screen.queryByRole("combobox", { name: "Exam part" }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("checkbox", { name: /Candidate Responsibility/ }),
		).not.toBeInTheDocument()
		expect(screen.queryByText(MEMBERSHIP_OFFER_COPY.body)).not.toBeInTheDocument()
		expect(
			screen.getByText(/Exclusive Offer for Members/),
		).toBeInTheDocument()

		// A member's Back goes to Membership Benefits, not the programmes list.
		const back = screen.getByRole("link", { name: "Membership" })
		expect(back.getAttribute("href")).toContain("/membership")
		expect(back.getAttribute("href")).not.toContain("/membership/register")
		expect(screen.queryByRole("link", { name: "Programs" })).not.toBeInTheDocument()

		// The membership is the main line, priced without anything chosen.
		expect((await screen.findAllByText("$195.00")).length).toBeGreaterThan(0)
	})

	it("Add prices the Risk.net line into the rail; Remove drops it again", async () => {
		const fees = armFees()
		const user = userEvent.setup()
		await renderMembership()
		await waitFor(() => expect(fees.spy.hits).toBeGreaterThan(0))

		await user.click(screen.getByRole("button", { name: /Add/ }))
		await waitFor(() =>
			expect(fees.spy.bodies[fees.spy.bodies.length - 1]?.riskNetSelected).toBe(true),
		)
		expect(await screen.findByText("Risk.net Membership")).toBeInTheDocument()
		// Never on the membership form — there is no membership upsell to tick.
		expect(fees.spy.bodies[fees.spy.bodies.length - 1]?.membershipSelected).toBe(false)

		// Remove restores the initial request, which React Query answers from
		// its cache (same key, same body) — so the rail is the evidence, not a
		// second wire call.
		await user.click(screen.getByRole("button", { name: /Remove/ }))
		await waitFor(() =>
			expect(screen.queryByText("Risk.net Membership")).not.toBeInTheDocument(),
		)
		expect(screen.getByRole("button", { name: /Add/ })).toHaveAttribute(
			"aria-pressed",
			"false",
		)
	})

	it("offers auto-renew on a card order, unticked, in the paid-membership wording", async () => {
		armFees()
		const user = userEvent.setup()
		await renderMembership()

		await user.click(await screen.findByRole("radio", { name: /^Card$/ }))

		const consent = autoRenew()
		expect(consent).not.toBeChecked()
		expect(consent).toHaveAccessibleName(/your GARP Individual Membership renews/)
		expect(screen.queryByText(/complimentary/)).not.toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Pay and Register" })).toBeInTheDocument()
	})

	it("withholds auto-renew under wire — no saved card to renew against", async () => {
		armFees()
		const user = userEvent.setup()
		await renderMembership()

		await user.click(await screen.findByRole("radio", { name: /Wire transfer/ }))

		expect(autoRenew()).not.toBeInTheDocument()
		expect(screen.getByText("Billing & shipping")).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Submit Order" })).toBeInTheDocument()
		// Apex adds the processing fee line for an offline method.
		expect(await screen.findByText("Processing Fee")).toBeInTheDocument()
	})

	it("does not ask someone whose contract already auto-renews", async () => {
		armFees()
		const user = userEvent.setup()
		await renderMembership({
			load: memberLoad({ id: "003-member", isAutoRenewEnabled: true }),
		})

		await user.click(await screen.findByRole("radio", { name: /^Card$/ }))

		expect(autoRenew()).not.toBeInTheDocument()
	})

	it("posts a membership order: type mem, the add-on, the consent, and nothing an exam would send", async () => {
		armFees()
		const { register } = armSubmit()
		const user = userEvent.setup()
		const { onRegistered } = await renderMembership()

		await user.click(await screen.findByRole("radio", { name: /^Card$/ }))
		await user.click(screen.getByRole("button", { name: /Add/ }))
		await user.click(screen.getByRole("checkbox", { name: /Membership Automatic Renewal/ }))

		const submit = screen.getByRole("button", { name: "Pay and Register" })
		await waitFor(() => expect(submit).toBeEnabled())
		await user.click(submit)
		const dialog = await screen.findByRole("dialog", {
			name: "Confirm your registration",
		})
		expect(register.spy.hits).toBe(0)
		await user.click(
			within(dialog).getByRole("button", { name: "Pay and Register" }),
		)

		await waitFor(() => expect(register.spy.hits).toBe(1))
		expect(register.spy.bodies[0]).toMatchObject({
			type: "mem",
			riskNetSelected: true,
			membershipSelected: false,
			autoRenew: true,
			paymentType: "Stripe",
			selection: { partSelected: null, part1: null, part2: null },
			materials: [],
			personal: null,
		})
		expect(register.spy.bodies[0].consent.examPolicy).toBe(false)
		await waitFor(() => expect(onRegistered).toHaveBeenCalledTimes(1))
	})

	it("uses the exam wire tile's disabled state and Location for a guest like any programme", async () => {
		armFees()
		await renderMembership({ profile: null, isAuthenticated: false })

		// Nothing prefilled, the programme's own byline, no back link.
		expect(screen.getByLabelText(/First name/)).toHaveValue("")
		expect(screen.getByText(/Already a member\? Sign in/)).toBeInTheDocument()
		expect(screen.queryByRole("link", { name: "Membership" })).not.toBeInTheDocument()
		expect(screen.getByRole("combobox", { name: "Location" })).toBeInTheDocument()
		expect(await screen.findByRole("radio", { name: /^Card$/ })).toBeEnabled()
		expect(wireTile()).toBeEnabled()
		expect(cardTile()).toBeEnabled()
	})
})
