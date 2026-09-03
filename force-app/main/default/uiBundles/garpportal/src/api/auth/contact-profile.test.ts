import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	fetchContactProfileExtras,
	mapContactProfileExtras,
} from "@/api/auth/contact-profile"
import {
	SDK_GRAPHQL_URL,
	sdkGraphqlHandler,
} from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"

describe("mapContactProfileExtras", () => {
	it("prefers the member id, falling back to the legacy GARP id", () => {
		expect(
			mapContactProfileExtras({
				GARP_Member_ID__c: { value: " G-1 " },
				GARP_ID__c: { value: "OLD-1" },
			}),
		).toMatchObject({ garpId: "G-1" })

		expect(
			mapContactProfileExtras({
				GARP_Member_ID__c: { value: "  " },
				GARP_ID__c: { value: " OLD-1 " },
			}),
		).toMatchObject({ garpId: "OLD-1" })
	})

	it("maps a missing node to all-null extras", () => {
		expect(mapContactProfileExtras(null)).toEqual({
			garpId: null,
			photoUrl: null,
			fullName: null,
		})
	})

	it("trims photo and name, nulling blanks", () => {
		expect(
			mapContactProfileExtras({
				Photo_URL__c: { value: " /p.png " },
				Name: { value: "   " },
			}),
		).toEqual({ garpId: null, photoUrl: "/p.png", fullName: null })
	})
})

describe("fetchContactProfileExtras", () => {
	it("resolves null for a blank contact id without a request", async () => {
		await expect(fetchContactProfileExtras("   ")).resolves.toBeNull()
	})

	it("returns the mapped extras for a found Contact", async () => {
		server.use(
			sdkGraphqlHandler({
				ContactProfileExtras: (variables) => {
					expect(variables).toMatchObject({ contactId: "003xx1", first: 1 })
					return {
						data: {
							uiapi: {
								query: {
									Contact: {
										edges: [
											{
												node: {
													Id: "003xx1",
													GARP_Member_ID__c: { value: "G-9" },
													Photo_URL__c: { value: null },
													Name: { value: "Grace Hopper" },
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

		await expect(fetchContactProfileExtras(" 003xx1 ")).resolves.toEqual({
			garpId: "G-9",
			photoUrl: null,
			fullName: "Grace Hopper",
		})
	})

	it("resolves null on GraphQL errors — enrichment must never break login", async () => {
		server.use(
			sdkGraphqlHandler({
				ContactProfileExtras: () => ({ errors: [{ message: "FLS" }] }),
			}),
		)
		await expect(fetchContactProfileExtras("003xx1")).resolves.toBeNull()
	})

	it("resolves null on a transport failure — enrichment is best-effort", async () => {
		server.use(
			sdkGraphqlHandler({
				ContactProfileExtras: () => {
					throw new Error("connection reset")
				},
			}),
		)
		await expect(fetchContactProfileExtras("003xx1")).resolves.toBeNull()
	})

	it("resolves null when the wire itself dies", async () => {
		server.use(http.post(SDK_GRAPHQL_URL, () => HttpResponse.error()))
		await expect(fetchContactProfileExtras("003xx1")).resolves.toBeNull()
	})

	it("swallows the 401 the org gives a guest instead of throwing", async () => {
		server.use(
			http.post(SDK_GRAPHQL_URL, () =>
				HttpResponse.json({ errors: [{ message: "unauthorized" }] }, { status: 401 }),
			),
		)
		await expect(fetchContactProfileExtras("003xx1")).resolves.toBeNull()
	})

	/**
	 * A guest's 403 walks the SDK's CSRF-refresh retry (the wire sees the
	 * POST twice), then lands in the `onStatus[403]` no-op instead of a
	 * redirect — enrichment must swallow it exactly like the 401.
	 */
	it("swallows a 403 refusal after the SDK's one retry", async () => {
		let attempts = 0
		server.use(
			http.post(SDK_GRAPHQL_URL, () => {
				attempts += 1
				return HttpResponse.json(
					{ errors: [{ message: "forbidden" }] },
					{ status: 403 },
				)
			}),
		)
		await expect(fetchContactProfileExtras("003xx1")).resolves.toBeNull()
		expect(attempts).toBe(2)
	})

	it("resolves null when the SDK itself cannot even be constructed", async () => {
		// The SDK reads `globalThis.SFDC_ENV` while wiring its base path; a
		// throwing environment is the one failure its own guards cannot catch.
		Object.defineProperty(globalThis, "SFDC_ENV", {
			configurable: true,
			get() {
				throw new Error("environment exploded")
			},
		})
		try {
			await expect(fetchContactProfileExtras("003xx1")).resolves.toBeNull()
		} finally {
			delete (globalThis as { SFDC_ENV?: unknown }).SFDC_ENV
		}
	})

	it("resolves null when no Contact row comes back", async () => {
		server.use(
			sdkGraphqlHandler({
				ContactProfileExtras: () => ({
					data: { uiapi: { query: { Contact: { edges: [] } } } },
				}),
			}),
		)
		await expect(fetchContactProfileExtras("003xx1")).resolves.toBeNull()
	})
})
