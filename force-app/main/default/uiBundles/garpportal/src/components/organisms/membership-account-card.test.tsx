import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { AccountView } from "@/api/account/types"
import { MembershipAccountCard } from "@/components/organisms/membership-account-card"
import { MEMBERSHIP_REGISTRATION_URL } from "@/config/membership-account"
import { accountStanding, accountView } from "@/testing/factories/account"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const AUTO_RENEW_ON_PATH =
	"/services/apexrest/memberportal/membershipAutoRenewOn"
const AUTO_RENEW_OFF_PATH =
	"/services/apexrest/memberportal/membershipAutoRenewOff"

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

describe("MembershipAccountCard — auto-renew off", () => {
	it("warns with the expiry date and offers Turn On plus Renew Now", async () => {
		await renderCard(individual({ isAutoRenewEnabled: false }))

		expect(screen.getByText(/Auto renew is off/)).toBeInTheDocument()
		expect(screen.getByText("March 1, 2027")).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Turn On Auto-Renew" }),
		).toBeEnabled()
		const renewNow = screen.getByRole("link", { name: "Renew Now" })
		expect(renewNow).toHaveAttribute("href", MEMBERSHIP_REGISTRATION_URL)
		expect(
			screen.queryByRole("button", { name: "Disable Auto Renew" }),
		).not.toBeInTheDocument()
	})

	it("Turn On posts to the auto-renew service", async () => {
		const user = userEvent.setup()
		const hits: number[] = []
		server.use(
			http.post(AUTO_RENEW_ON_PATH, () => {
				hits.push(1)
				// No orderId: nothing further to hand to Stripe in this test.
				return HttpResponse.json(
					memberPortalEnvelope({ statusCode: 200, orderId: null }),
				)
			}),
		)
		await renderCard(individual({ isAutoRenewEnabled: false }))

		await user.click(screen.getByRole("button", { name: "Turn On Auto-Renew" }))

		expect(hits).toHaveLength(1)
	})
})

describe("MembershipAccountCard — auto-renew on", () => {
	it("confirms the standing arrangement and offers only Disable", async () => {
		await renderCard(individual({ isAutoRenewEnabled: true }))

		expect(
			screen.getByText(/GARP will automatically renew my Individual Membership/),
		).toBeInTheDocument()
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

	it("Disable posts to the auto-renew-off service", async () => {
		const user = userEvent.setup()
		const hits: number[] = []
		server.use(
			http.post(AUTO_RENEW_OFF_PATH, () => {
				hits.push(1)
				return HttpResponse.json(memberPortalEnvelope({ statusCode: 200 }))
			}),
		)
		await renderCard(individual({ isAutoRenewEnabled: true }))

		await user.click(screen.getByRole("button", { name: "Disable Auto Renew" }))

		expect(hits).toHaveLength(1)
	})
})

describe("MembershipAccountCard — transitional states", () => {
	it("a pending renewal order shows Payment Pending and View Order alone", async () => {
		await renderCard(
			individual({
				isAutoRenewEnabled: false,
				pendingOrderId: "801PENDING",
				pendingOrderNumber: "ORD-9",
			}),
		)

		expect(screen.getByText("Payment Pending")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "View Order" })).toHaveAttribute(
			"href",
			"/my-account/orders/801PENDING",
		)
		expect(
			screen.queryByRole("button", { name: "Turn On Auto-Renew" }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: "Renew Now" }),
		).not.toBeInTheDocument()
	})

	it("an in-flight auto-renew setup parks Renew Now disabled with the pending note", async () => {
		await renderCard(individual({ isAutoRenewEnabled: false }), true)

		expect(
			screen.getByText("Auto-Renew is being setup, please check back later."),
		).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Renew Now" })).toBeDisabled()
		expect(
			screen.queryByRole("button", { name: "Turn On Auto-Renew" }),
		).not.toBeInTheDocument()
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
			MEMBERSHIP_REGISTRATION_URL,
		)
		expect(
			screen.queryByRole("button", { name: "Turn On Auto-Renew" }),
		).not.toBeInTheDocument()
	})
})
