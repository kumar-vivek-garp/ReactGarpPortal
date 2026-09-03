import { http, HttpResponse, type JsonBodyType } from "msw"

/**
 * The Data SDK's GraphQL endpoint. The API version is pinned to 65.0 under
 * Vitest (the `__SF_API_VERSION__` define is build-only), matching the CSRF
 * handler in `core.ts`.
 */
export const SDK_GRAPHQL_URL = "/services/data/v65.0/graphql"

type SdkGraphqlRequestBody = {
	query?: string
	variables?: Record<string, unknown>
	operationName?: string
}

type SdkGraphqlResolver = (
	variables: Record<string, unknown>,
) => JsonBodyType | Promise<JsonBodyType>

/**
 * Routes Data SDK GraphQL POSTs to per-operation resolvers.
 *
 * The api modules do not pass `operationName` (it is dropped from the JSON
 * body as `undefined`), so operations are matched against the printed query
 * text — `query ContactPreferences(...)` / `mutation UpdateSmsPreferences(...)`.
 *
 * GraphQL failures are HTTP 200 with a top-level `errors[]`; model them by
 * resolving `{ errors: [{ message: "…" }] }`. An operation with no resolver
 * comes back as a GraphQL error naming itself, so the failing test says which
 * call it did not expect.
 */
export function sdkGraphqlHandler(resolvers: Record<string, SdkGraphqlResolver>) {
	return http.post(SDK_GRAPHQL_URL, async ({ request }) => {
		const body = (await request.json()) as SdkGraphqlRequestBody
		const query = body.query ?? ""
		const operation = Object.keys(resolvers).find((name) =>
			new RegExp(`\\b(?:query|mutation)\\s+${name}\\b`).test(query),
		)
		if (!operation) {
			return HttpResponse.json({
				errors: [
					{
						message: `No test resolver for GraphQL operation: ${query.slice(0, 80)}`,
					},
				],
			})
		}
		return HttpResponse.json(await resolvers[operation](body.variables ?? {}))
	})
}
