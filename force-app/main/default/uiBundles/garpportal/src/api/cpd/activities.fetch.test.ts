/**
 * The transport half of `fetchCpdActivities`, via MSW through the real SDK.
 * The query-string rules themselves are covered in `activities.test.ts`
 * (pure `buildActivitySearchParams` tests) — not repeated here.
 */
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchCpdActivities } from "@/api/cpd/activities"
import { cpdActivitiesQueryOptions } from "@/api/cpd/query-options"
import type { CpdActivity } from "@/api/cpd/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const ACTIVITIES_PATH = "/services/apexrest/memberportal/cpdActivities"

function cpdActivity(overrides: Partial<CpdActivity> = {}): CpdActivity {
	return {
		id: "a0Cxx1",
		title: "Climate Risk Webcast",
		description: null,
		location: null,
		sortDate: "2026-06-01",
		activityDate: "June 2026",
		activityType: "Webcast",
		activityTypeId: "a0Txx1",
		areasOfStudy: "Climate;Credit Risk",
		credits: 1,
		organization: "GARP",
		provider: "GARP",
		providerId: null,
		publication: null,
		url: null,
		...overrides,
	}
}

describe("fetchCpdActivities", () => {
	it("sends the built query string and fills missing facets with defaults", async () => {
		let search: URLSearchParams | undefined
		server.use(
			http.get(ACTIVITIES_PATH, ({ request }) => {
				search = new URL(request.url).searchParams
				return HttpResponse.json(
					memberPortalEnvelope({
						cpdActivities: [cpdActivity()],
						totalCount: 41,
					}),
				)
			}),
		)

		const view = await fetchCpdActivities({
			activityTypes: ["Webcast"],
			pageCurrent: 2,
		})

		expect(search?.get("activityTypes")).toBe("Webcast")
		expect(search?.get("pageCurrent")).toBe("2")
		expect(view).toEqual({
			sortOptions: [],
			activityTypes: [],
			areasOfStudy: [],
			providers: [],
			cpdActivities: [cpdActivity()],
			totalCount: 41,
		})
	})

	it("requests the bare path for an empty filter set", async () => {
		let url = ""
		server.use(
			http.get(ACTIVITIES_PATH, ({ request }) => {
				url = request.url
				return HttpResponse.json(memberPortalEnvelope({ totalCount: 0 }))
			}),
		)

		await expect(fetchCpdActivities()).resolves.toMatchObject({
			cpdActivities: [],
			totalCount: 0,
		})
		expect(url.includes("?")).toBe(false)
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.get(ACTIVITIES_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Catalogue down"), {
					status: 500,
				}),
			),
		)

		await expect(fetchCpdActivities()).rejects.toMatchObject({
			messages: ["Catalogue down"],
		})
	})
})

describe("cpdActivitiesQueryOptions", () => {
	it("keys by the whole filter object so paging is a cache miss", () => {
		const filters = { activityTypes: ["Webcast"], pageCurrent: 3 }
		const options = cpdActivitiesQueryOptions(filters)
		expect(options.queryKey).toEqual(["cpd", "activities", filters])
		expect(options.meta).toMatchObject({ toastError: true })
	})
})
