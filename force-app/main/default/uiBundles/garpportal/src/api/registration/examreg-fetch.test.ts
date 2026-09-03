/**
 * The transport split (§4 of registration-forms.md): a guest cannot use the
 * Data SDK, so `examregFetch` probes `whoami` and picks plain same-origin
 * fetch for guests, falling back on a Connect refusal.
 *
 * `@/auth/sfdc-env` is mocked (the events-presentation idiom) because jsdom's
 * origin is localhost, which would otherwise force the local-CLI branch where
 * the probe never runs. The probe is memoised per module load, so every test
 * re-imports a fresh module via `vi.resetModules()`.
 */
import { http, HttpResponse } from "msw"
import { beforeEach, describe, expect, it, vi } from "vitest"

vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => ({ apiPath: "/" })),
}))

import { getSfdcEnv } from "@/auth/sfdc-env"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const CSRF_PATH = "/services/data/v65.0/ui-api/session/csrf"
const MESSAGES = { unreachable: "Unreachable.", fallback: "Fallback." }

async function freshExamregFetch() {
	vi.resetModules()
	const module = await import("@/api/registration/examreg-fetch")
	return module.examregFetch
}

function counting(path: string, respond: () => Response) {
	const spy = { hits: 0 }
	const handler = http.get(path, () => {
		spy.hits += 1
		return respond()
	})
	return { spy, handler }
}

beforeEach(() => {
	vi.mocked(getSfdcEnv).mockReturnValue({ apiPath: "/" })
})

describe("examregFetch — guest transport", () => {
	it("routes to plain fetch when whoami says guest, memoising the probe", async () => {
		const examregFetch = await freshExamregFetch()
		const whoami = counting("/services/apexrest/examreg/whoami", () =>
			HttpResponse.json(
				memberPortalEnvelope({ isAuthenticated: false, userType: "Guest" }),
			),
		)
		const csrf = counting(CSRF_PATH, () =>
			HttpResponse.json({ csrfToken: "should-never-be-fetched" }),
		)
		server.use(
			whoami.handler,
			csrf.handler,
			http.get("/services/apexrest/examreg/info", () =>
				HttpResponse.json(memberPortalEnvelope({ programType: "frm" })),
			),
		)

		await expect(
			examregFetch("/info", { method: "GET" }, MESSAGES),
		).resolves.toEqual({ programType: "frm" })
		await examregFetch("/info", { method: "GET" }, MESSAGES)

		// The session cannot change without a navigation — one probe only.
		expect(whoami.spy.hits).toBe(1)
		// The guest transport never touches the Connect-family CSRF endpoint.
		expect(csrf.spy.hits).toBe(0)
	})

	it("strips the proxy base's trailing slash so URLs stay same-origin", async () => {
		vi.mocked(getSfdcEnv).mockReturnValue({ apiPath: "/garpportal/sf/api/" })
		const examregFetch = await freshExamregFetch()
		server.use(
			http.get("/garpportal/sf/api/services/apexrest/examreg/whoami", () =>
				HttpResponse.json(memberPortalEnvelope({ isAuthenticated: false })),
			),
			http.get("/garpportal/sf/api/services/apexrest/examreg/info", () =>
				HttpResponse.json(memberPortalEnvelope({ ok: true })),
			),
		)

		await expect(
			examregFetch("/info", { method: "GET" }, MESSAGES),
		).resolves.toEqual({ ok: true })
	})

	it("takes the SDK path when whoami errors, then falls back on a Connect refusal", async () => {
		vi.mocked(getSfdcEnv).mockReturnValue({ apiPath: "/proxy" })
		const examregFetch = await freshExamregFetch()

		const sdkHits = { count: 0 }
		server.use(
			// `status: "Error"` reads as "cannot tell" — unknown takes the SDK path.
			http.get("/proxy/services/apexrest/examreg/whoami", () =>
				HttpResponse.json({ status: "Error", statusCode: 500, data: null }),
			),
			// The SDK path (bare /services) is refused the way the org refuses guests.
			http.get("/services/apexrest/examreg/load", () => {
				sdkHits.count += 1
				return HttpResponse.json(
					{
						message:
							"The Chatter Connect API is not enabled for this organization or user type",
					},
					{ status: 403 },
				)
			}),
			// The guest retry lands on the proxy and succeeds.
			http.get("/proxy/services/apexrest/examreg/load", () =>
				HttpResponse.json(memberPortalEnvelope({ recovered: true })),
			),
		)

		await expect(
			examregFetch("/load", { method: "GET" }, MESSAGES),
		).resolves.toEqual({ recovered: true })
		// The Data SDK retries once on 403 before the refusal is inspected.
		expect(sdkHits.count).toBe(2)
	})

	it("treats a probe network failure as authenticated and uses the SDK", async () => {
		vi.mocked(getSfdcEnv).mockReturnValue({ apiPath: "/proxy" })
		const examregFetch = await freshExamregFetch()
		server.use(
			http.get("/proxy/services/apexrest/examreg/whoami", () =>
				HttpResponse.error(),
			),
			// ONLY the SDK's bare /services path is handled — a guest-transport
			// request would go to /proxy/services/… and fail the strict server.
			http.get("/services/apexrest/examreg/info", () =>
				HttpResponse.json(memberPortalEnvelope({ viaSdk: true })),
			),
		)

		await expect(
			examregFetch("/info", { method: "GET" }, MESSAGES),
		).resolves.toEqual({ viaSdk: true })
	})
})
