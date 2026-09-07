import { screen, within } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { AccountView } from "@/api/account/types"
import { MembershipAccountCard } from "@/components/organisms/membership-account-card"
import { accountStanding, accountView } from "@/testing/factories/account"
import { renderWithRouterProviders } from "@/testing/router"

/**
 * The card's states — which notice and which single footer action each
 * membership standing produces. The auto-renew wire behaviour (Turn On's
 * request, the Disable confirm dialog) is in
 * `membership-account-card.auto-renew.test.tsx`.
 */

/** An Individual member with a live contract; flags overridden per case. */
function individual(
	overrides: Partial<ReturnType<typeof accountStanding>> = {},
): AccountView {
	return accountView({
		identity: { isIndividualMember: true, membershipType: "Individual" },
		standing: accountStanding(overrides),
	})
}

async function renderCard(
	account: AccountView,
	autoRenewSetupComplete = false,
) {
	return renderWithRouterProviders(
		<MembershipAccountCard
			account={account}
			autoRenewSetupComplete={autoRenewSetupComplete}
		/>,
	)
}

describe("MembershipAccountCard — facts", () => {
	it("lists GARP ID, member type, status and member since", async () => {
		await renderCard(individual({ isAutoRenewEnabled: true }))

		expect(screen.getByText("G-STANDING")).toBeInTheDocument()
		expect(screen.getByText("Individual")).toBeInTheDocument()
		expect(screen.getByText("Active (until March 1, 2027)")).toBeInTheDocument()
		expect(screen.getByText("Member Since")).toBeInTheDocument()
		expect(screen.getByText("March 1, 2020")).toBeInTheDocument()
	})

	it("marks a certification holder", async () => {
		await renderCard(individual({ isCertHolder: true }))
		expect(screen.getByText("Certification holder")).toBeInTheDocument()
	})
})

describe("MembershipAccountCard — auto-renew off", () => {
	it("warns with the expiry date and offers Turn On plus Renew Now", async () => {
		await renderCard(individual({ isAutoRenewEnabled: false }))

		expect(screen.getByText(/Auto renew is off/)).toBeInTheDocument()
		expect(screen.getByText("March 1, 2027")).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Turn On Auto-Renew" }),
		).toBeEnabled()
		// The in-app membership form, tagged so the sale is attributed to this card.
		expect(screen.getByRole("link", { name: "Renew Now" })).toHaveAttribute(
			"href",
			"/membership/register?track_cta=PortalMyAccountPage",
		)
		expect(
			screen.queryByRole("button", { name: "Disable Auto Renew" }),
		).not.toBeInTheDocument()
	})
})

describe("MembershipAccountCard — auto-renew on", () => {
	it("confirms the standing arrangement with the rate and offers only Disable", async () => {
		await renderCard(individual({ isAutoRenewEnabled: true }))

		const notice = screen.getByText(
			/GARP will automatically renew your Individual Membership/,
		)
		expect(notice).toHaveTextContent("USD 195")
		expect(within(notice).getByText("March 1, 2027")).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Disable Auto Renew" }),
		).toBeEnabled()
		expect(
			screen.queryByRole("button", { name: "Turn On Auto-Renew" }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: "Renew Now" }),
		).not.toBeInTheDocument()
	})

	it("quotes the certification-holder rate", async () => {
		await renderCard(individual({ isAutoRenewEnabled: true, isCertHolder: true }))
		expect(
			screen.getByText(/GARP will automatically renew your Individual Membership/),
		).toHaveTextContent("USD 150")
	})
})

describe("MembershipAccountCard — transitional states", () => {
	it("a pending renewal order shows Payment Pending, names the order, and offers View Order alone", async () => {
		await renderCard(
			individual({
				isAutoRenewEnabled: true,
				pendingOrderId: "801PENDING",
				pendingOrderNumber: "ORD-9",
				pendingOrderAmount: 195,
			}),
		)

		expect(screen.getByText("Payment Pending")).toBeInTheDocument()
		expect(
			screen.getByText("Order ORD-9 — $195.00 is waiting to be paid."),
		).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "View Order" })).toHaveAttribute(
			"href",
			"/my-account/orders/801PENDING",
		)
		// Both auto-renew notices are suppressed while an order is pending.
		expect(
			screen.queryByText(/GARP will automatically renew/),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Disable Auto Renew" }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Turn On Auto-Renew" }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: "Renew Now" }),
		).not.toBeInTheDocument()
	})

	it("back from Stripe, says the card is saved and keeps Renew Now available", async () => {
		await renderCard(individual({ isAutoRenewEnabled: false }), true)

		expect(screen.getByText("Card saved")).toBeInTheDocument()
		expect(
			screen.getByText(/Auto-renew takes effect once the payment is confirmed/),
		).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Renew Now" })).toBeEnabled()
		expect(
			screen.queryByRole("button", { name: "Turn On Auto-Renew" }),
		).not.toBeInTheDocument()
	})

	it("a lapsed Individual is asked to renew and gets no auto-renew notice", async () => {
		await renderCard(
			individual({
				memberStatus: "Expired",
				statusLabel: "Lapsed",
				expirationDate: "2026-03-01",
			}),
		)

		expect(screen.getByText("Lapsed (expired March 1, 2026)")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Renew Now" })).toBeInTheDocument()
		expect(screen.queryByText(/Auto renew is off/)).not.toBeInTheDocument()
	})

	it("an Affiliate is offered the Upgrade path instead of renewal controls", async () => {
		await renderCard(
			accountView({
				identity: { isAffiliateMember: true, membershipType: "Affiliate" },
				standing: accountStanding({ memberType: "Affiliate" }),
			}),
		)

		expect(screen.getByRole("link", { name: "Upgrade" })).toHaveAttribute(
			"href",
			"/membership/register?track_cta=PortalMyAccountPage",
		)
		expect(
			screen.queryByRole("button", { name: "Turn On Auto-Renew" }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: "Renew Now" }),
		).not.toBeInTheDocument()
	})
})
