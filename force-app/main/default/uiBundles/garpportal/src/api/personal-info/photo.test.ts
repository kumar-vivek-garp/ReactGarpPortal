import { describe, expect, it } from "vitest"

import { removeProfilePhoto, uploadProfilePhoto } from "@/api/personal-info/photo"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"

type UploadVariables = {
	parentId: string
	name: string
	contentType: string
	body: string
}

type SetUrlVariables = { contactId: string; photoUrl: string | null }

function photoOrg({
	attachmentId = "00Pxx1",
}: { attachmentId?: string | null } = {}) {
	const uploads: UploadVariables[] = []
	const updates: SetUrlVariables[] = []
	const handler = sdkGraphqlHandler({
		UploadProfilePhotoAttachment: (variables) => {
			uploads.push(variables as UploadVariables)
			return {
				data: {
					uiapi: {
						AttachmentCreate: {
							Record: attachmentId ? { Id: attachmentId } : null,
						},
					},
				},
			}
		},
		SetContactPhotoUrl: (variables) => {
			updates.push(variables as SetUrlVariables)
			return { data: { uiapi: { ContactUpdate: { success: true } } } }
		},
	})
	return { uploads, updates, handler }
}

describe("uploadProfilePhoto", () => {
	it("refuses a blank contact id or empty photo before the network", async () => {
		await expect(uploadProfilePhoto("  ", "AAAA", "x.png")).rejects.toMatchObject({
			messages: ["Contact Id is required."],
		})
		await expect(uploadProfilePhoto("003xx1", "  ", "x.png")).rejects.toMatchObject({
			messages: ["Photo data is required."],
		})
	})

	it("creates the Attachment then points Photo_URL__c at the servlet", async () => {
		const org = photoOrg()
		server.use(org.handler)

		await expect(
			uploadProfilePhoto(" 003xx1 ", "QkFTRTY0", "portrait.PNG"),
		).resolves.toBe("/servlet/servlet.FileDownload?file=00Pxx1")

		expect(org.uploads).toEqual([
			{
				parentId: "003xx1",
				name: "portrait.PNG",
				contentType: "image/png",
				body: "QkFTRTY0",
			},
		])
		expect(org.updates).toEqual([
			{
				contactId: "003xx1",
				photoUrl: "/servlet/servlet.FileDownload?file=00Pxx1",
			},
		])
	})

	it("derives the content type from the extension, defaulting safely", async () => {
		const org = photoOrg()
		server.use(org.handler)

		await uploadProfilePhoto("003xx1", "QkFTRTY0", "me.jpeg")
		await uploadProfilePhoto("003xx1", "QkFTRTY0", "  ")
		expect(org.uploads.map((u) => u.contentType)).toEqual([
			"image/jpeg",
			"application/octet-stream",
		])
		// A blank name falls back to the default file name.
		expect(org.uploads[1].name).toBe("profile-photo.jpg")
	})

	it("throws when the create returns no attachment id", async () => {
		const org = photoOrg({ attachmentId: null })
		server.use(org.handler)

		await expect(uploadProfilePhoto("003xx1", "QkFTRTY0", "x.png")).rejects.toMatchObject({
			messages: ["Photo upload did not return an attachment Id."],
		})
		expect(org.updates).toEqual([])
	})

	it("throws the GraphQL error messages from the create", async () => {
		server.use(
			sdkGraphqlHandler({
				UploadProfilePhotoAttachment: () => ({
					errors: [{ message: "Attachment body too large" }],
				}),
			}),
		)

		await expect(uploadProfilePhoto("003xx1", "QkFTRTY0", "x.png")).rejects.toMatchObject({
			messages: ["Attachment body too large"],
		})
	})
})

describe("removeProfilePhoto", () => {
	it("clears Photo_URL__c with a null write", async () => {
		const org = photoOrg()
		server.use(org.handler)

		await removeProfilePhoto("003xx1")
		expect(org.updates).toEqual([{ contactId: "003xx1", photoUrl: null }])
	})

	it("throws the GraphQL error messages from the update", async () => {
		server.use(
			sdkGraphqlHandler({
				SetContactPhotoUrl: () => ({ errors: [{ message: "Row locked" }] }),
			}),
		)

		await expect(removeProfilePhoto("003xx1")).rejects.toMatchObject({
			messages: ["Row locked"],
		})
	})
})
