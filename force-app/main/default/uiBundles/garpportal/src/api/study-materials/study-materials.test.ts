import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { studyMaterialsQueryOptions } from "@/api/study-materials/query-options"
import { fetchStudyMaterials } from "@/api/study-materials/study-materials"
import type { ApexStudyMaterialsPayload } from "@/api/study-materials/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const STUDY_MATERIALS_PATH = "/services/apexrest/memberportal/studyMaterials"

const payload: ApexStudyMaterialsPayload = {
	statusMessage: null,
	statusCode: 200,
	studyMaterialsInfo: {
		frmStudyMaterials: [
			{
				title: "FRM Exam Part I eBooks",
				productCode: "FRM-P1-EB",
				shortDescription: "<p>Four digital books&nbsp;covering Part I.</p>",
				isOwned: true,
			},
		],
		scrStudyMaterials: null,
	},
}

describe("fetchStudyMaterials", () => {
	it("unwraps and normalizes the legacy buckets into the panel model", async () => {
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(payload)),
			),
		)

		const view = await fetchStudyMaterials()
		expect(view.programs).toHaveLength(1)
		expect(view.programs[0]).toMatchObject({
			key: "frm",
			label: "Financial Risk Manager",
		})
		expect(view.programs[0].materials[0]).toMatchObject({
			id: "FRM-P1-EB",
			title: "FRM Exam Part I eBooks",
		})
		// HTML is stripped from copy on the way through.
		expect(view.programs[0].materials[0].paragraphs[0]).toBe(
			"Four digital books covering Part I.",
		)
		expect(view.myEntitlements).toHaveLength(1)
	})

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
})

describe("studyMaterialsQueryOptions", () => {
	it("keys the catalogue and opts into toasting failures", () => {
		expect(studyMaterialsQueryOptions.queryKey).toEqual(["study-materials", "list"])
		expect(studyMaterialsQueryOptions.meta).toMatchObject({ toastError: true })
	})
})
