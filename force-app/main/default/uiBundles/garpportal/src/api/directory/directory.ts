import { createDataSDK, gql } from "@salesforce/platform-sdk"

import { AppError } from "@/api/client"
import type { DirectoryMember } from "@/api/directory/types"

type DirectoryQueryResult = {
	uiapi?: {
		query?: {
			Contact?: {
				edges?: Array<{
					node?: {
						Id?: string
						Name?: { value?: string | null } | null
						Company__c?: { value?: string | null } | null
						MailingCountry?: { value?: string | null } | null
						Corporate_Title__c?: { value?: string | null } | null
						Job_Function__c?: { value?: string | null } | null
					} | null
				}> | null
			} | null
		} | null
	} | null
}

/**
 * Opted-in directory contacts matching name / company / mailing country.
 * Field names align with GarpAppv1 SearchMemberDirectory (Contact UI API).
 * `@optional` keeps rows when FLS hides a field.
 */
const DIRECTORY_SEARCH_QUERY = gql`
	query SearchMemberDirectory($term: String!, $first: Int!) {
		uiapi {
			query {
				Contact(
					where: {
						and: [
							{ GARP_Directory_Opt_In__c: { eq: true } }
							{
								or: [
									{ Name: { like: $term } }
									{ Company__c: { like: $term } }
									{ MailingCountry: { like: $term } }
								]
							}
						]
					}
					orderBy: { Name: { order: ASC } }
					first: $first
				) {
					edges {
						node {
							Id
							Name @optional {
								value
							}
							Company__c @optional {
								value
							}
							MailingCountry @optional {
								value
							}
							Corporate_Title__c @optional {
								value
							}
							Job_Function__c @optional {
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
 * Searches members who opted into the GARP Directory via GraphQL `uiapi.Contact`.
 * Returns up to `first` rows (default 25). Empty term → `[]` (no network call).
 */
export async function searchDirectory(
	term: string,
	first = 25,
): Promise<DirectoryMember[]> {
	const trimmed = term.trim()
	if (!trimmed) return []

	const sdk = await createDataSDK()
	const result = await sdk.graphql?.query<
		DirectoryQueryResult,
		{ term: string; first: number }
	>({
		query: DIRECTORY_SEARCH_QUERY,
		variables: { term: `%${trimmed}%`, first },
	})

	if (result?.errors?.length) {
		throw new AppError({
			messages: result.errors.map((error) => error.message),
		})
	}

	const edges = result?.data?.uiapi?.query?.Contact?.edges ?? []
	return edges.flatMap((edge) => {
		const node = edge?.node
		if (!node?.Id) return []
		return [
			{
				id: node.Id,
				name: node.Name?.value ?? null,
				company: node.Company__c?.value ?? null,
				country: node.MailingCountry?.value ?? null,
				corporateTitle: node.Corporate_Title__c?.value ?? null,
				jobFunction: node.Job_Function__c?.value ?? null,
			},
		]
	})
}
