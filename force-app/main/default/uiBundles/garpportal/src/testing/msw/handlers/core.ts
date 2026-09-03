import { http, HttpResponse } from "msw"

export const TEST_CSRF_TOKEN = "test-csrf-token"

/**
 * Baseline handlers every suite needs. The Data SDK fetches a CSRF token
 * before EVERY `/services/apexrest/*` request (`alwaysProtectedUrls`) and
 * before GraphQL POSTs — without this handler each SDK call rejects before
 * the request under test is ever made. The API version is pinned to 65.0
 * under Vitest (the `__SF_API_VERSION__` define is build-only).
 */
export const coreHandlers = [
	http.get("/services/data/v65.0/ui-api/session/csrf", () =>
		HttpResponse.json({ csrfToken: TEST_CSRF_TOKEN }),
	),
]
