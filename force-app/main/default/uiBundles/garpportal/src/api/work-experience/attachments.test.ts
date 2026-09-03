import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	deleteCvAttachment,
	fetchCvAttachments,
	uploadCvAttachment,
} from "@/api/work-experience/attachments"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const CV_ATTACHMENTS_PATH = "/services/apexrest/memberportal/cvAttachments"

describe("blank-id guards — no request ever leaves", () => {
	it("fetchCvAttachments refuses a blank experience id", async () => {
		await expect(fetchCvAttachments("   ")).rejects.toMatchObject({
			status: 400,
			messages: ["An experience id is required."],
		})
	})

	it("uploadCvAttachment refuses a blank experience id", async () => {
		await expect(
			uploadCvAttachment("   ", "cv.pdf", "Zm9v"),
		).rejects.toMatchObject({
			status: 400,
			messages: ["An experience id is required."],
		})
	})

	it("deleteCvAttachment refuses a blank attachment id", async () => {
		await expect(deleteCvAttachment("   ")).rejects.toMatchObject({
			status: 400,
			messages: ["An attachment id is required."],
		})
	})
})

describe("the 200-with-error envelope shape", () => {
	/**
	 * `AttachmentResult` reports its failure in `message`, never in the
	 * envelope — an inner non-200 must surface that field's own sentence.
	 */
	it("reads the failure from `data.message` inside an HTTP 200", async () => {
		server.use(
			http.get(CV_ATTACHMENTS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 404,
						message: "Work Experience not found",
						attachments: null,
					}),
				),
			),
		)

		await expect(fetchCvAttachments("a1Q")).rejects.toMatchObject({
			status: 404,
			messages: ["Work Experience not found"],
		})
	})

	it("falls back to its own sentence when `message` is blank", async () => {
		server.use(
			http.get(CV_ATTACHMENTS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 500,
						message: "  ",
						attachments: null,
					}),
				),
			),
		)

		await expect(fetchCvAttachments("a1Q")).rejects.toMatchObject({
			messages: ["Unable to load the files for this experience."],
		})
	})
})
