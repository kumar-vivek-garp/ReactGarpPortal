/**
 * Turning auto-renew ON ends in `window.location.assign(setupUrl)`. jsdom's
 * Location is [LegacyUnforgeable] — its properties are non-configurable own
 * properties, so the call can be neither spied on nor replaced. The line
 * still executes (jsdom logs "Not implemented: navigation" to its virtual
 * console and returns), so the tests assert everything around it instead:
 * the request body, that the mutation resolves, and that no cache is
 * invalidated and no success toast fires. The assigned URL itself cannot be
 * asserted here — the mocked e2e suite covers the navigation.
 */
import type { QueryClient } from "@tanstack/react-query"
import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { toast } from "sonner"
import { beforeEach, describe, expect, it, vi } from "vitest"

import { accountQueryKeys } from "@/api/account/query-options"
import { authQueryKeys } from "@/api/auth/query-options"
import { personalInfoQueryKeys } from "@/api/personal-info"
import {
	useTurnOffMembershipAutoRenew,
	useTurnOnMembershipAutoRenew,
} from "@/hooks/use-membership-auto-renew"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderHookWithProviders } from "@/testing/render"

const OFF_PATH = "/services/apexrest/memberportal/membershipAutoRenewOff"
const ON_PATH = "/services/apexrest/memberportal/membershipAutoRenewOn"
const RETURN_URL = "http://localhost:3000/my-account?status=autorenewsetupcomplete"

const CONTACT_ID = "003XX0000012345"

/** Every cache `invalidateAccountCaches` refreshes after a successful flip. */
const ACCOUNT_KEYS = [
	accountQueryKeys.detail,
	authQueryKeys.currentUser,
	// Invalidated through the `personal-info` prefix.
	personalInfoQueryKeys.billingCompany(CONTACT_ID),
]

function seededClient(): QueryClient {
	const queryClient = createTestQueryClient()
	for (const key of ACCOUNT_KEYS) {
		queryClient.setQueryData(key, { seeded: true })
	}
	return queryClient
}

function invalidatedFlags(queryClient: QueryClient): (boolean | undefined)[] {
	return ACCOUNT_KEYS.map(
		(key) => queryClient.getQueryState(key)?.isInvalidated,
	)
}

beforeEach(() => {
	vi.mocked(toast.success).mockClear()
})

describe("useTurnOffMembershipAutoRenew", () => {
	it("invalidates every account cache on success", async () => {
		server.use(
			http.post(OFF_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ statusMessage: "ok", statusCode: 200 }),
				),
			),
		)

		const { result, queryClient } = renderHookWithProviders(
			() => useTurnOffMembershipAutoRenew(),
			{ queryClient: seededClient() },
		)
		act(() => {
			result.current.mutate()
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(invalidatedFlags(queryClient)).toEqual([true, true, true])
	})

	it("leaves the caches alone when the server refuses", async () => {
		server.use(
			// 500, not 4xx: the SDK transport retries once on 400/401/403.
			http.post(OFF_PATH, () =>
				HttpResponse.json(memberPortalError(500, "off failed"), {
					status: 500,
				}),
			),
		)

		const { result, queryClient } = renderHookWithProviders(
			() => useTurnOffMembershipAutoRenew(),
			{ queryClient: seededClient() },
		)
		act(() => {
			result.current.mutate()
		})

		await waitFor(() => expect(result.current.isError).toBe(true))
		expect(result.current.error?.message).toBe("off failed")
		expect(invalidatedFlags(queryClient)).toEqual([false, false, false])
	})
})

describe("useTurnOnMembershipAutoRenew", () => {
	it("posts the return URL and leaves for Stripe without touching the caches", async () => {
		let body: unknown
		server.use(
			http.post(ON_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						needPaymentInfo: true,
						setupUrl: "https://checkout.stripe.com/c/setup/abc",
					}),
				)
			}),
		)

		const { result, queryClient } = renderHookWithProviders(
			() => useTurnOnMembershipAutoRenew(),
			{ queryClient: seededClient() },
		)
		act(() => {
			result.current.mutate(RETURN_URL)
		})

		// The member leaves for Stripe (see the header comment): the mutation
		// resolves, but nothing local is refreshed or announced — the contract
		// only flips once the webhook lands.
		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(body).toEqual({ returnUrl: RETURN_URL })
		expect(result.current.data?.setupUrl).toBe(
			"https://checkout.stripe.com/c/setup/abc",
		)
		expect(invalidatedFlags(queryClient)).toEqual([false, false, false])
		expect(vi.mocked(toast.success)).not.toHaveBeenCalled()
	})

	it("reports a refusal and stays on the page", async () => {
		server.use(
			http.post(ON_PATH, () =>
				HttpResponse.json(
					memberPortalError(500, "Active Membership contract not found"),
					{ status: 500 },
				),
			),
		)

		const { result, queryClient } = renderHookWithProviders(
			() => useTurnOnMembershipAutoRenew(),
			{ queryClient: seededClient() },
		)
		act(() => {
			result.current.mutate(RETURN_URL)
		})

		await waitFor(() => expect(result.current.isError).toBe(true))
		expect(result.current.error?.message).toBe(
			"Active Membership contract not found",
		)
		expect(invalidatedFlags(queryClient)).toEqual([false, false, false])
	})
})
