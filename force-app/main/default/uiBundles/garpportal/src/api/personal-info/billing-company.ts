import { createDataSDK, gql } from "@salesforce/platform-sdk"

import { AppError } from "@/api/client"
import type { BillingCompany } from "@/api/personal-info/types"

/**
 * The one field `GET /memberportal/account` leaves out: the Account's
 * `Billing_Address_Company__c`. `POST /memberportal/addresses` writes it
 * unconditionally, so the form has to hydrate the stored value or every save
 * would blank it. A single-object, single-hop read is the case the data-access
 * rule keeps GraphQL for; do not grow this query.
 */

type BillingCompanyQueryResult = {
	uiapi?: {
		query?: {
			Contact?: {
				edges?: Array<{
					node?: {
						Id?: string
						Account?: {
							Id?: string | null
							Billing_Address_Company__c?: { value?: string | null } | null
						} | null
					} | null
				} | null> | null
			} | null
		} | null
	} | null
}

const BILLING_COMPANY_QUERY = gql`
	query BillingCompany($contactId: ID!, $first: Int!) {
		uiapi {
			query {
				Contact(where: { Id: { eq: $contactId } }, first: $first) {
					edges {
						node {
							Id
							Account @optional {
								Id
								Billing_Address_Company__c @optional {
									value
								}
							}
						}
					}
					pageInfo {
						hasNextPage
						endCursor
					}
				}
			}
		}
	}
`

export async function fetchBillingCompany(
	contactId: string,
): Promise<BillingCompany> {
	const trimmedId = contactId.trim()
	if (!trimmedId) {
		throw new AppError({ messages: ["Contact Id is required."] })
	}

	const sdk = await createDataSDK()
	// Bypass SDK OneStore (300s TTL) — TanStack Query caches this hydrate.
	const result = await sdk.graphql?.query<
		BillingCompanyQueryResult,
		{ contactId: string; first: number }
	>({
		query: BILLING_COMPANY_QUERY,
		variables: { contactId: trimmedId, first: 1 },
		cacheControl: "no-cache",
	})

	if (result?.errors?.length) {
		throw new AppError({
			messages: result.errors.map((error) => error.message),
		})
	}

	const node = result?.data?.uiapi?.query?.Contact?.edges?.[0]?.node
	if (!node?.Id) {
		throw new AppError({ messages: ["Unable to load billing details."] })
	}

	return {
		accountId: node.Account?.Id?.trim() || null,
		billingCompany: node.Account?.Billing_Address_Company__c?.value?.trim() || null,
	}
}
