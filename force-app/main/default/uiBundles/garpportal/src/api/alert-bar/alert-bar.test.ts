import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchAlertBar } from "@/api/alert-bar/alert-bar"
import { alertBarQueryOptions } from "@/api/alert-bar/query-options"
import type { AlertBarView } from "@/api/alert-bar/types"
import { AppError } from "@/api/client"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const ALERT_BAR_PATH = "/services/apexrest/memberportal/alertBar"

function alertBarView(overrides: Partial<AlertBarView> = {}): AlertBarView {
	return {
		statusMessage: null,
		statusCode: 200,
		examType: "FRM",
		examPart: "I",
		alertStatus: "Exam Unpaid",
		deadline: "2026-10-01",
		orderId: "006xx0000001",
		route: "Complete Payment",
		...overrides,
	}
}

const serve = (view: AlertBarView) =>
	http.get(ALERT_BAR_PATH, () =>
		HttpResponse.json(memberPortalEnvelope(view)),
	)

describe("fetchAlertBar", () => {
	it("returns the one live alert", async () => {
		const view = alertBarView()
		server.use(serve(view))
		await expect(fetchAlertBar()).resolves.toEqual(view)
	})

	it("resolves null for the common 'no alerts' answer", async () => {
		server.use(
			serve(alertBarView({ alertStatus: null, statusMessage: "No alerts found" })),
		)
		await expect(fetchAlertBar()).resolves.toBeNull()
	})

	it("resolves null for a 401 refusal that carries a payload", async () => {
		server.use(
			http.get(ALERT_BAR_PATH, () =>
				HttpResponse.json(
					{
						status: "Error",
						statusCode: 401,
						errorMessage: "Portal Access Denied",
						data: alertBarView({ statusCode: 401, alertStatus: null }),
					},
					{ status: 401 },
				),
			),
		)
		await expect(fetchAlertBar()).resolves.toBeNull()
	})

	it("resolves null for an inner refusal on an HTTP 200", async () => {
		server.use(
			serve(
				alertBarView({ statusCode: 401, statusMessage: "Portal Access Denied" }),
			),
		)
		await expect(fetchAlertBar()).resolves.toBeNull()
	})

	it("still throws for a failure with an empty body — a dead session", async () => {
		server.use(
			http.get(ALERT_BAR_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Session expired"), {
					status: 500,
				}),
			),
		)

		const failure = fetchAlertBar()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({ messages: ["Session expired"] })
	})
})

describe("alertBarQueryOptions", () => {
	it("must never toast over the page — chrome fails by not rendering", () => {
		expect(alertBarQueryOptions.meta?.toastError).toBe(false)
		expect(alertBarQueryOptions.queryKey).toEqual(["alert-bar", "view"])
	})
})
