---
paths:
  - "**/api/**/*.ts"
  - "**/api/**/*.tsx"
  - "**/*.graphql"
  - "**/hooks/**/*.ts"
  - "**/hooks/**/*.tsx"
  - "**/cspTrustedSites/**"
---

# Salesforce data access rules

**Before writing any code that connects to Salesforce, you MUST invoke the `using-ui-bundle-salesforce-data` skill. Do not write any data access code without consulting it first.**

After the SDK call, normalize and surface errors via `src/api/client/` (see **api-client-and-errors**): return `T` or throw `AppError`, wire React Query `meta` for Sonner — do not invent a parallel fetch/toast stack.

This applies to: GraphQL queries/mutations, REST calls, SDK initialization, custom hooks that fetch data, or any code that imports from `@salesforce/platform-sdk`.

- **All data access uses the Data SDK** (`@salesforce/platform-sdk`) via `createDataSDK()`.
- **Never** use `fetch()` or `axios` directly for Salesforce data.
- **GraphQL is preferred** for record operations (`sdk.graphql`). Use `sdk.fetch` only when GraphQL cannot cover the case (UI API REST, Apex REST, Connect REST, Einstein LLM).
- Use optional chaining: `sdk.graphql?.()`, `sdk.fetch?.()`.
- Apply the `@optional` directive to all record fields for field-level security resilience.
- Verify field and object names via `scripts/graphql-search.sh` before writing queries.
- Use `__SF_API_VERSION__` global for API version in REST calls.
- **Blocked APIs:** Enterprise REST query endpoint (`/query` with SOQL), `@AuraEnabled` Apex, Chatter API.

## Permitted APIs

| API | Method | Endpoints / Use Case |
|-----|--------|----------------------|
| GraphQL | `sdk.graphql` | All record queries and mutations via `uiapi { }` namespace |
| UI API REST | `sdk.fetch` | `/services/data/v{ver}/ui-api/records/{id}` |
| Apex REST | `sdk.fetch` | `/services/apexrest/{resource}` |
| Connect REST | `sdk.fetch` | `/services/data/v{ver}/connect/...` |
| Einstein LLM | `sdk.fetch` | `/services/data/v{ver}/einstein/llm/prompt/generations` |

Any endpoint not listed above is not permitted.

## GraphQL non-negotiable rules

1. **Schema is the single source of truth** — every entity and field name must be confirmed via the schema search script before use. Never guess.
2. **`@optional` on all record fields** — FLS causes entire queries to fail if any field is inaccessible. Apply to every scalar, parent, and child relationship field.
3. **Correct mutation syntax** — mutations wrap under `uiapi(input: { allOrNone: true/false })`, not bare `uiapi { ... }`.
4. **Explicit `first:` in every query** — omitting it silently defaults to 10 records. Always include `pageInfo { hasNextPage endCursor }` for paginated queries.
5. **SOQL-derived execution limits** — max 10 subqueries per request, max 5 levels of child-to-parent traversal, max 1 level parent-to-child, max 2,000 records per subquery.
6. **HTTP 200 does not mean success** — Salesforce returns HTTP 200 even on failure. Always check the `errors` array in the response body.

## GraphQL inline queries

Must use the `gql` template tag from `@salesforce/platform-sdk` — plain template strings bypass `@graphql-eslint` schema validation. For complex queries, use external `.graphql` files with codegen.

## Current user info

Use GraphQL (`uiapi { currentUser { Id Name { value @optional } Contact { GARP_Member_ID__c { value @optional } } } }`), not Chatter (`/chatter/users/me`).

## Schema file (`schema.graphql`)

The `schema.graphql` file at the SFDX project root is the source of truth for all entity and field name lookups. It is 265K+ lines — never open or parse it directly. Use the schema search script instead.

- **Generate/refresh:** Run `npm run graphql:schema` from the UI bundle directory
- **When to regenerate:** After any metadata deployment that changes objects, fields, or permission sets
- **Custom objects** only appear in the schema after metadata deployment AND permission set assignment
- **After regenerating:** Always re-run `npm run graphql:codegen` and `npm run build` (schema changes may affect generated types)

## CSP trusted sites

Any external domain the app calls (APIs, CDNs, fonts) must have a `.cspTrustedSite-meta.xml` file under `<sfdx-source>/cspTrustedSites/`. Unregistered domains are blocked at runtime. Each subdomain needs its own entry. URLs must be HTTPS with no trailing slash, no path, and no wildcards.
