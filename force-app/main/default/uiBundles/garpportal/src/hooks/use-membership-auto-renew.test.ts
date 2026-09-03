/**
 * The `needPaymentInfo` branch ends in `window.location.assign(...)` to the
 * Stripe setup URL. jsdom's Location is [LegacyUnforgeable] — its properties
 * are non-configurable own properties, so the call can be neither spied on nor
 * replaced. The line still executes (jsdom logs "Not implemented: navigation"
 * to its virtual console and returns), so the tests assert everything around
 * it instead: the mutation resolves, no cache is invalidated, and no success
 * toast fires. The assigned URL itself cannot be asserted.
 */
import type { QueryClient } from "@tanstack/react-query"
import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { toast } from "sonner"
import { beforeEach, describe, expect, it, vi } from "vitest"

import { accountQueryKeys } from "@/api/account/query-options"
import { authQueryKeys } from "@/api/auth/query-options"
import { contactPreferencesQueryKeys } from "@/api/contact-preferences/query-options"
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

const CONTACT_ID = "003XX0000012345"

/** Every cache `invalidateAccountCaches` refreshes after a successful flip. */
const ACCOUNT_KEYS = [
	accountQueryKeys.detail,
	accountQueryKeys.contact(CONTACT_ID),
	authQueryKeys.currentUser,
	personalInfoQueryKeys.edit(CONTACT_ID),
	contactPreferencesQueryKeys.detail(CONTACT_ID),
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
			() => useTurnOffMembershipAutoRenew(CONTACT_ID),
			{ queryClient: seededClient() },
		)
		act(() => {
			result.current.mutate()
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(invalidatedFlags(queryClient)).toEqual([
			true,
			true,
			true,
			true,
			true,
		])
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
			() => useTurnOffMembershipAutoRenew(CONTACT_ID),
			{ queryClient: seededClient() },
		)
		act(() => {
			result.current.mutate()
		})

		await waitFor(() => expect(result.current.isError).toBe(true))
		expect(result.current.error?.message).toBe("off failed")
		expect(invalidatedFlags(queryClient)).toEqual([
			false,
			false,
			false,
			false,
			false,
		])
	})
})

describe("useTurnOnMembershipAutoRenew", () => {
	it("invalidates and toasts when no payment info is needed", async () => {
		server.use(
			// `needPaymentInfo` deliberately absent: the api coerces a missing
			// flag to `false`, so this also pins the invalidation path for it.
			http.post(ON_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ statusMessage: null, statusCode: 200 }),
				),
			),
		)

		const { result, queryClient } = renderHookWithProviders(
			() => useTurnOnMembershipAutoRenew(CONTACT_ID),
			{ queryClient: seededClient() },
		)
		act(() => {
			result.current.mutate()
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(result.current.data?.needPaymentInfo).toBe(false)
		expect(invalidatedFlags(queryClient)).toEqual([
			true,
			true,
			true,
			true,
			true,
		])
		expect(vi.mocked(toast.success)).toHaveBeenCalledWith(
			"Auto-renew is on",
			undefined,
		)
	})

	it("skips invalidation and the toast when Stripe setup is needed", async () => {
		server.use(
			http.post(ON_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						needPaymentInfo: true,
						orderId: "006XX0000000001",
					}),
				),
			),
		)

		const { result, queryClient } = renderHookWithProviders(
			() => useTurnOnMembershipAutoRenew(CONTACT_ID),
			{ queryClient: seededClient() },
		)
		act(() => {
			result.current.mutate()
		})

		// The member leaves for Stripe (see the header comment): the mutation
		// still resolves, but nothing local is refreshed or announced.
		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(result.current.data?.needPaymentInfo).toBe(true)
		expect(invalidatedFlags(queryClient)).toEqual([
			false,
			false,
			false,
			false,
			false,
		])
		expect(vi.mocked(toast.success)).not.toHaveBeenCalled()
	})
})
