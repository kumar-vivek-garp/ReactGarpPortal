import { useMemo } from "react"
import { useQuery } from "@tanstack/react-query"

import { accountQueryOptions } from "@/api/account/query-options"
import { currentUserQueryOptions } from "@/api/auth/query-options"
import { toPersonalInfoEditData } from "@/api/personal-info/edit-data"
import { billingCompanyQueryOptions } from "@/api/personal-info/query-options"

/**
 * Personal Information hydrate: the composed `GET /memberportal/account`
 * payload (one cache entry, shared with the My Account page) plus the Account
 * billing company it omits. The server resolves the contact from the session,
 * so callers no longer pass an id; `enabled` still keeps a guest off a
 * member-only read.
 *
 * The contact id for the billing read comes from the cached session (never
 * fetched here — the layout guard already resolved it), falling back to the
 * account payload's own identity.
 */
export function usePersonalInfoEditData(enabled = true) {
	const session = useQuery({ ...currentUserQueryOptions, enabled: false })
	const account = useQuery({ ...accountQueryOptions, enabled })
	const contactId =
		session.data?.contactId?.trim() ||
		account.data?.identity.contactId?.trim() ||
		""
	const billing = useQuery({
		...billingCompanyQueryOptions(contactId),
		enabled: enabled && Boolean(contactId),
	})

	const data = useMemo(
		() =>
			account.data && billing.data
				? toPersonalInfoEditData(account.data, billing.data.billingCompany)
				: undefined,
		[account.data, billing.data],
	)

	return {
		data,
		isPending: account.isPending || billing.isPending,
		isLoading: account.isLoading || billing.isLoading,
		isError: account.isError || billing.isError,
		error: account.error ?? billing.error,
	}
}
