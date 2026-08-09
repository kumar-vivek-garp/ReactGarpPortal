import { createDataSDK, gql } from "@salesforce/platform-sdk"

import { AppError } from "@/api/client"
import type { CountryOption } from "@/api/personal-info/types"

type CountryQueryResult = {
	uiapi?: {
		query?: {
			Country_Code__c?: {
				edges?: Array<{
					node?: {
						Id?: string
						Country__c?: { value?: string | null } | null
						Name?: { value?: string | null } | null
						PhoneCode__c?: { value?: string | null } | null
					} | null
				}> | null
			} | null
		} | null
	} | null
}

const COUNTRIES_QUERY = gql`
	query PersonalInfoCountries($first: Int!) {
		uiapi {
			query {
				Country_Code__c(first: $first, orderBy: { Country__c: { order: ASC } }) {
					edges {
						node {
							Id
							Country__c @optional {
								value
							}
							Name @optional {
								value
							}
							PhoneCode__c @optional {
								value
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

/**
 * Loads country / phone-code options from `Country_Code__c` for Personal Info selects.
 */
export async function fetchCountryOptions(): Promise<CountryOption[]> {
	const sdk = await createDataSDK()
	const result = await sdk.graphql?.query<CountryQueryResult, { first: number }>({
		query: COUNTRIES_QUERY,
		variables: { first: 500 },
	})

	if (result?.errors?.length) {
		throw new AppError({
			messages: result.errors.map((error) => error.message),
		})
	}

	const edges = result?.data?.uiapi?.query?.Country_Code__c?.edges ?? []
	const seen = new Set<string>()
	const options: CountryOption[] = []

	for (const edge of edges) {
		const node = edge?.node
		const value = node?.Country__c?.value?.trim() || node?.Name?.value?.trim() || ""
		if (!value || seen.has(value)) continue
		seen.add(value)
		options.push({
			label: value,
			value,
			phoneCode: node?.PhoneCode__c?.value?.trim() || null,
		})
	}

	return options
}

/** Unique phone codes derived from country options (sorted). */
export function phoneCodeOptions(countries: CountryOption[]): Array<{
	label: string
	value: string
}> {
	const seen = new Set<string>()
	const codes: string[] = []
	for (const country of countries) {
		const code = country.phoneCode?.trim()
		if (!code || seen.has(code)) continue
		seen.add(code)
		codes.push(code)
	}
	codes.sort((a, b) => a.localeCompare(b, undefined, { numeric: true }))
	return codes.map((code) => ({ label: code, value: code }))
}
