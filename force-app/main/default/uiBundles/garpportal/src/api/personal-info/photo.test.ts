import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { removeProfilePhoto, uploadProfilePhoto } from "@/api/personal-info/photo"
import { memberPortalError } from "@/testing/factories/envelope"
import {
	MEMBER_PHOTO_PATH,
	personalInfoWriteHandlers,
} from "@/testing/msw/handlers/personal-info"
import { server } from "@/testing/msw/server"

describe("uploadProfilePhoto", () => {
	it("refuses an empty body before it reaches the network", async () => {
		await expect(uploadProfilePhoto("  ", "me.jpg")).rejects.toMatchObject({
			messages: ["Photo data is required."],
		})
	})

	it("posts the file name and bare base64 payload, resolving the photo URL", async () => {
		const org = personalInfoWriteHandlers()
		server.use(...org.handlers)

		await expect(uploadProfilePhoto("Zm9v", " me.png ")).resolves.toBe(
			"/servlet/servlet.FileDownload?file=00PX0000000ATT",
		)
		expect(org.photoSpy.bodies).toEqual([{ fileName: "me.png", fileText: "Zm9v" }])
	})

	it("defaults the file name when none is given", async () => {
		const org = personalInfoWriteHandlers()
		server.use(...org.handlers)

		await uploadProfilePhoto("Zm9v", "")
		expect(org.photoSpy.bodies[0].fileName).toBe("profile-photo.jpg")
	})

	it("surfaces the service's own refusal", async () => {
		server.use(
			...personalInfoWriteHandlers({
				photoRespond: () => ({
					statusMessage: "The image could not be read.",
					statusCode: 501,
					photoUrl: null,
				}),
			}).handlers,
		)

		const failure = uploadProfilePhoto("not-base64", "me.jpg")
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["The image could not be read."],
		})
	})

	it("throws when a healthy answer carries no photo URL", async () => {
		server.use(
			...personalInfoWriteHandlers({
				photoRespond: () => ({
					statusMessage: "Success",
					statusCode: 200,
					photoUrl: " ",
				}),
			}).handlers,
		)

		await expect(uploadProfilePhoto("Zm9v", "me.jpg")).rejects.toMatchObject({
			messages: ["Photo upload did not return a photo URL."],
		})
	})

	it("surfaces a router-level refusal", async () => {
		server.use(
			http.post(MEMBER_PHOTO_PATH, () =>
				HttpResponse.json(memberPortalError(401, "Not authenticated."), {
					status: 401,
				}),
			),
		)

		await expect(uploadProfilePhoto("Zm9v", "me.jpg")).rejects.toMatchObject({
			messages: ["Not authenticated."],
		})
	})
})

describe("removeProfilePhoto", () => {
	it("posts an empty body and resolves", async () => {
		const org = personalInfoWriteHandlers()
		server.use(...org.handlers)

		await expect(removeProfilePhoto()).resolves.toBeUndefined()
		expect(org.photoRemoveSpy.hits).toBe(1)
	})

	it("surfaces the service's refusal", async () => {
		server.use(
			...personalInfoWriteHandlers({
				photoRemoveRespond: () => ({
					statusMessage: "No photo on file.",
					statusCode: 501,
					photoUrl: null,
				}),
			}).handlers,
		)

		await expect(removeProfilePhoto()).rejects.toMatchObject({
			messages: ["No photo on file."],
		})
	})
})
