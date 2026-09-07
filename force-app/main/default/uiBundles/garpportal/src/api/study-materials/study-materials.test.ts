import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import {
	fetchStudyMaterials,
	STUDY_MATERIALS_PATH,
} from "@/api/study-materials/study-materials"
import {
	memberPortalEnvelope,
	memberPortalError,
	memberPortalRefusal,
} from "@/testing/factories/envelope"
import {
	deniedStudyMaterials,
	ownedWithReg,
	studyMaterialsPayload,
} from "@/testing/factories/study-materials"
import { server } from "@/testing/msw/server"

describe("fetchStudyMaterials — the catalogue", () => {
	it("unwraps and normalizes the legacy buckets into programs", async () => {
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						studyMaterialsPayload({
							frmStudyMaterials: [ownedWithReg()],
							scrStudyMaterials: null,
						}),
					),
				),
			),
		)

		const view = await fetchStudyMaterials()
		expect(view.kind).toBe("ok")
		if (view.kind !== "ok") return
		expect(view.programs).toHaveLength(1)
		expect(view.programs[0]).toMatchObject({
			key: "frm",
			label: "Financial Risk Manager",
		})
		expect(view.programs[0]?.items[0]).toMatchObject({
			id: "FRM1H",
			title: "2026 FRM Exam Part I eBooks",
			// HTML is stripped from copy on the way through.
			description: "Four digital books covering Part I.",
			isOwned: true,
		})
	})
})

describe("fetchStudyMaterials — access denied", () => {
	it("resolves a 403 that still carries the payload as a denied view", async () => {
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(
					memberPortalRefusal(403, "Portal Access Denied", deniedStudyMaterials(403)),
					{ status: 403 },
				),
			),
		)

		await expect(fetchStudyMaterials()).resolves.toEqual({
			kind: "denied",
			statusCode: 403,
			message: "Portal Access Denied",
		})
	})

	it("treats a 401 the same way", async () => {
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(
					memberPortalRefusal(401, "Portal Access Denied", deniedStudyMaterials(401)),
					{ status: 401 },
				),
			),
		)

		await expect(fetchStudyMaterials()).resolves.toMatchObject({
			kind: "denied",
			statusCode: 401,
		})
	})

	it("still throws for a 403 with an EMPTY body — that is a dead session, not a refusal", async () => {
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(memberPortalError(403, "Session expired"), {
					status: 403,
				}),
			),
		)

		await expect(fetchStudyMaterials()).rejects.toMatchObject({
			messages: ["Session expired"],
		})
	})

	it("honours the refusal when the router mirrors it as HTTP 200", async () => {
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(deniedStudyMaterials(403))),
			),
		)

		await expect(fetchStudyMaterials()).resolves.toEqual({
			kind: "denied",
			statusCode: 403,
			message: "Portal Access Denied",
		})
	})
})

describe("fetchStudyMaterials — failures", () => {
	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Materials backend down"), {
					status: 500,
				}),
			),
		)

		const failure = fetchStudyMaterials()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Materials backend down"],
		})
	})

	it("throws on an inner non-200 that is not an access refusal", async () => {
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "Product not found",
						statusCode: 500,
						studyMaterialsInfo: null,
					}),
				),
			),
		)

		await expect(fetchStudyMaterials()).rejects.toMatchObject({
			messages: ["Product not found"],
			status: 500,
		})
	})
})
