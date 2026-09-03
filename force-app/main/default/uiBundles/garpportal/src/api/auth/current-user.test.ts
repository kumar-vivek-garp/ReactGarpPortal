/**
 * `fetchCurrentUser`'s Data SDK branch. Under jsdom the origin is localhost,
 * which would route to the CLI-gateway path — `@/auth/sfdc-env` is mocked
 * (module-level, per the events-presentation idiom) because there is no HTTP
 * boundary that decides the host; MSW then serves the SDK's GraphQL wire.
 */
import { http, HttpResponse } from "msw"
import { beforeEach, describe, expect, it, vi } from "vitest"

vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => undefined),
}))

import { fetchCurrentUser } from "@/api/auth/current-user"
import {
	SDK_GRAPHQL_URL,
	sdkGraphqlHandler,
} from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"

function currentUserNode(contact: Record<string, unknown> | null) {
	return {
		data: {
			uiapi: {
				currentUser: {
					Id: "005xx0001",
					Name: { value: "Ada Lovelace" },
					Contact: contact,
				},
			},
		},
	}
}

beforeEach(() => {
	sessionStorage.clear()
})

describe("fetchCurrentUser (Data SDK branch)", () => {
	it("resolves identity in one round trip when the Contact fields are populated", async () => {
		let enrichCalls = 0
		server.use(
			sdkGraphqlHandler({
				CurrentUser: () =>
					currentUserNode({
						Id: "003xx0009",
						GARP_Member_ID__c: { value: " G-42 " },
						Photo_URL__c: { value: "/servlet/photo" },
					}),
				ContactProfileExtras: () => {
					enrichCalls += 1
					return { data: {} }
				},
			}),
		)

		await expect(fetchCurrentUser()).resolves.toEqual({
			id: "005xx0001",
			name: "Ada Lovelace",
			garpId: "G-42",
			contactId: "003xx0009",
			photoUrl: "/servlet/photo",
		})
		expect(enrichCalls).toBe(0)
	})

	it("enriches blank Contact custom fields with a direct Contact query", async () => {
		server.use(
			sdkGraphqlHandler({
				CurrentUser: () =>
					currentUserNode({
						Id: "003xx0009",
						GARP_Member_ID__c: { value: "  " },
						Photo_URL__c: null,
					}),
				ContactProfileExtras: (variables) => {
					expect(variables).toMatchObject({ contactId: "003xx0009", first: 1 })
					return {
						data: {
							uiapi: {
								query: {
									Contact: {
										edges: [
											{
												node: {
													Id: "003xx0009",
													GARP_Member_ID__c: { value: "G-77" },
													Photo_URL__c: { value: "/photo.png" },
													Name: { value: "Ada L." },
												},
											},
										],
									},
								},
							},
						},
					}
				},
			}),
		)

		await expect(fetchCurrentUser()).resolves.toMatchObject({
			garpId: "G-77",
			photoUrl: "/photo.png",
			// The session name was present, so the enrich name is NOT taken.
			name: "Ada Lovelace",
		})
	})

	it("treats GraphQL errors as guest, not as a failure", async () => {
		server.use(
			sdkGraphqlHandler({
				CurrentUser: () => ({ errors: [{ message: "401 unauthorized" }] }),
			}),
		)
		await expect(fetchCurrentUser()).resolves.toBeNull()
	})

	it("treats a missing currentUser as guest", async () => {
		server.use(
			sdkGraphqlHandler({
				CurrentUser: () => ({ data: { uiapi: { currentUser: null } } }),
			}),
		)
		await expect(fetchCurrentUser()).resolves.toBeNull()
	})

	it("treats a transport failure as guest — the probe must never throw", async () => {
		server.use(
			sdkGraphqlHandler({
				// A resolver that itself throws models the server dying mid-request.
				CurrentUser: () => {
					throw new Error("connection reset")
				},
			}),
		)
		await expect(fetchCurrentUser()).resolves.toBeNull()

		// And the harder failure: the wire itself dies before any response.
		server.use(http.post(SDK_GRAPHQL_URL, () => HttpResponse.error()))
		await expect(fetchCurrentUser()).resolves.toBeNull()
	})

	it("swallows the 401 the org gives a guest instead of throwing", async () => {
		server.use(
			http.post(SDK_GRAPHQL_URL, () =>
				HttpResponse.json({ errors: [{ message: "unauthorized" }] }, { status: 401 }),
			),
		)
		await expect(fetchCurrentUser()).resolves.toBeNull()
	})

	it("honours the local Sign Out flag without touching the network", async () => {
		sessionStorage.setItem("garpportal:local-logged-out", "1")
		// No handlers registered: a network call would fail the strict MSW server.
		await expect(fetchCurrentUser()).resolves.toBeNull()
	})
})
