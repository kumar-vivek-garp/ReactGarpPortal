import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { AccountView } from "@/api/account/types"
import { MembershipAccountCard } from "@/components/organisms/membership-account-card"
import { accountStanding, accountView } from "@/testing/factories/account"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

/**
 * The auto-renew wire behaviour: what Turn On posts, and that Disable asks
 * before posting anything. Card states live in
 * `membership-account-card.test.tsx`.
 */

const AUTO_RENEW_ON_PATH =
	"/services/apexrest/memberportal/membershipAutoRenewOn"
const AUTO_RENEW_OFF_PATH =
	"/services/apexrest/memberportal/membershipAutoRenewOff"

function individual(
	overrides: Partial<ReturnType<typeof accountStanding>> = {},
): AccountView {
	return accountView({
		identity: { isIndividualMember: true, membershipType: "Individual" },
		standing: accountStanding(overrides),
	})
}

async function renderCard(account: AccountView) {
	return renderWithRouterProviders(
		<MembershipAccountCard account={account} autoRenewSetupComplete={false} />,
	)
}

describe("MembershipAccountCard — Turn On", () => {
	it("posts the page's own return URL, tagged for the card-saved notice", async () => {
		const user = userEvent.setup()
		const bodies: unknown[] = []
		server.use(
			http.post(AUTO_RENEW_ON_PATH, async ({ request }) => {
				bodies.push(await request.json())
				return HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 200,
						statusMessage: null,
						needPaymentInfo: true,
						setupUrl: "https://checkout.stripe.com/c/setup/abc",
					}),
				)
			}),
		)
		await renderCard(individual({ isAutoRenewEnabled: false }))

		await user.click(screen.getByRole("button", { name: "Turn On Auto-Renew" }))

		await waitFor(() => expect(bodies).toHaveLength(1))
		expect(bodies[0]).toEqual({
			returnUrl: `${window.location.origin}${window.location.pathname}?status=autorenewsetupcomplete`,
		})
	})
})

describe("MembershipAccountCard — Disable asks first", () => {
	it("opens the confirm dialog and posts nothing until it is confirmed", async () => {
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

		const dialog = await screen.findByRole("dialog", { name: "Turn off auto-renew?" })
		expect(
			within(dialog).getByText(/stops your recurring payment/),
		).toBeInTheDocument()
		expect(hits).toHaveLength(0)

		await user.click(within(dialog).getByRole("button", { name: "Yes, turn it off" }))

		await waitFor(() => expect(hits).toHaveLength(1))
		await waitFor(() =>
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument(),
		)
	})

	it("Keep auto-renew closes the dialog without posting", async () => {
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
		const dialog = await screen.findByRole("dialog")
		await user.click(within(dialog).getByRole("button", { name: "Keep auto-renew" }))

		await waitFor(() =>
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument(),
		)
		expect(hits).toHaveLength(0)
		expect(
			screen.getByRole("button", { name: "Disable Auto Renew" }),
		).toBeEnabled()
	})

	it("stays open when the server refuses, so the member can retry or keep it", async () => {
		const user = userEvent.setup()
		server.use(
			// 500, not 401: the SDK transport retries once on 400/401/403.
			http.post(AUTO_RENEW_OFF_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Opportunity not found"), {
					status: 500,
				}),
			),
		)
		await renderCard(individual({ isAutoRenewEnabled: true }))

		await user.click(screen.getByRole("button", { name: "Disable Auto Renew" }))
		const dialog = await screen.findByRole("dialog")
		await user.click(within(dialog).getByRole("button", { name: "Yes, turn it off" }))

		await waitFor(() =>
			expect(
				within(dialog).getByRole("button", { name: "Yes, turn it off" }),
			).toBeEnabled(),
		)
		expect(screen.getByRole("dialog")).toBeInTheDocument()
	})
})
