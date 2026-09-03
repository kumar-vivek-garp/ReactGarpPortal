import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { CountryOption } from "@/api/personal-info/types"
import { PersonalInfoEditForm } from "@/components/organisms/personal-info-edit-form"
import { resizeProfilePhoto } from "@/lib/resize-profile-photo"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { personalInfoGraphqlResolvers } from "@/testing/factories/personal-info-graphql"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

// Not an HTTP boundary MSW could serve: the resizer needs canvas +
// createImageBitmap, which jsdom does not implement at all.
vi.mock("@/lib/resize-profile-photo", () => ({ resizeProfilePhoto: vi.fn() }))

const resizeMock = vi.mocked(resizeProfilePhoto)

const COUNTRIES: CountryOption[] = [
	{ label: "United States", value: "United States", phoneCode: "+1" },
]

function serveOrg(data = personalInfoEditData()) {
	const attachments: Array<Record<string, unknown>> = []
	const photoWrites: Array<Record<string, unknown>> = []
	server.use(
		sdkGraphqlHandler({
			...personalInfoGraphqlResolvers(data, COUNTRIES),
			UploadProfilePhotoAttachment: (variables) => {
				attachments.push(variables)
				return {
					data: {
						uiapi: { AttachmentCreate: { Record: { Id: "00P-att-9" } } },
					},
				}
			},
			SetContactPhotoUrl: (variables) => {
				photoWrites.push(variables)
				return { data: { uiapi: { ContactUpdate: { success: true } } } }
			},
		}),
	)
	return { attachments, photoWrites }
}

function renderForm() {
	return renderWithProviders(
		<PersonalInfoEditForm contactId="003-member" onSaved={vi.fn()} />,
	)
}

/** The picker input is sr-only with no label; the button is what users see. */
function fileInput() {
	return document.querySelector('input[type="file"]') as HTMLInputElement
}

const removeButton = () => screen.getByRole("button", { name: "Remove" })

describe("choosing a photo", () => {
	it("refuses a file over 2 MB before anything else happens", async () => {
		serveOrg()
		const user = userEvent.setup()
		renderForm()

		await screen.findByLabelText("First name")
		// The visible button only relays the click to the hidden input.
		await user.click(screen.getByRole("button", { name: "Upload photo" }))
		const big = new File(
			[new ArrayBuffer(2 * 1024 * 1024 + 1)],
			"huge.jpg",
			{ type: "image/jpeg" },
		)
		await user.upload(fileInput(), big)

		expect(
			await screen.findByText("File size should not exceed 2 MB."),
		).toBeInTheDocument()
		expect(resizeMock).not.toHaveBeenCalled()
	})

	it("refuses anything that is not a JPEG or PNG", async () => {
		serveOrg()
		// `accept` would filter the file before the guard; switch that off.
		const user = userEvent.setup({ applyAccept: false })
		renderForm()

		await screen.findByLabelText("First name")
		const doc = new File(["hello"], "cv.pdf", { type: "application/pdf" })
		await user.upload(fileInput(), doc)

		expect(
			await screen.findByText("Only JPEG and PNG files are allowed."),
		).toBeInTheDocument()
		expect(resizeMock).not.toHaveBeenCalled()
	})

	it("owns up when the photo cannot be prepared for upload", async () => {
		serveOrg()
		resizeMock.mockRejectedValueOnce(new Error("no canvas"))
		const user = userEvent.setup()
		renderForm()

		await screen.findByLabelText("First name")
		await user.upload(
			fileInput(),
			new File(["bytes"], "me.png", { type: "image/png" }),
		)

		expect(
			await screen.findByText("Unable to prepare the selected photo."),
		).toBeInTheDocument()
	})

	it("uploads the resized square and records the servlet URL", async () => {
		const org = serveOrg()
		resizeMock.mockResolvedValueOnce({
			base64Body: "Zm9v",
			dataUrl: "data:image/jpeg;base64,Zm9v",
			fileName: "profile-photo.jpg",
			contentType: "image/jpeg",
			width: 128,
			height: 128,
		})
		const user = userEvent.setup()
		renderForm()

		await screen.findByLabelText("First name")
		expect(removeButton()).toBeDisabled()
		await user.upload(
			fileInput(),
			new File(["bytes"], "me.jpg", { type: "image/jpeg" }),
		)

		await vi.waitFor(() => {
			expect(org.photoWrites).toHaveLength(1)
		})
		expect(org.attachments[0]).toMatchObject({
			parentId: "003-member",
			name: "profile-photo.jpg",
			contentType: "image/jpeg",
			body: "Zm9v",
		})
		expect(org.photoWrites[0]).toMatchObject({
			contactId: "003-member",
			photoUrl: "/servlet/servlet.FileDownload?file=00P-att-9",
		})
		// A photo now exists, so Remove wakes up.
		await vi.waitFor(() => {
			expect(removeButton()).toBeEnabled()
		})
	})

	it("falls back to the server photo when the upload itself fails", async () => {
		serveOrg()
		resizeMock.mockResolvedValueOnce({
			base64Body: "Zm9v",
			dataUrl: "data:image/jpeg;base64,Zm9v",
			fileName: "profile-photo.jpg",
			contentType: "image/jpeg",
			width: 128,
			height: 128,
		})
		server.use(
			sdkGraphqlHandler({
				...personalInfoGraphqlResolvers(personalInfoEditData(), COUNTRIES),
				UploadProfilePhotoAttachment: () => ({
					errors: [{ message: "Attachment refused" }],
				}),
			}),
		)
		const user = userEvent.setup()
		renderForm()

		await screen.findByLabelText("First name")
		await user.upload(
			fileInput(),
			new File(["bytes"], "me.jpg", { type: "image/jpeg" }),
		)

		// The optimistic preview is rolled back — nothing to remove.
		await vi.waitFor(() => {
			expect(
				screen.getByRole("button", { name: "Upload photo" }),
			).toBeEnabled()
		})
		expect(removeButton()).toBeDisabled()
	})
})

describe("removing a photo", () => {
	it("clears Contact.Photo_URL__c and locks Remove again", async () => {
		const org = serveOrg(personalInfoEditData({ photoUrl: "/photo.png" }))
		const user = userEvent.setup()
		renderForm()

		await screen.findByLabelText("First name")
		expect(removeButton()).toBeEnabled()
		await user.click(removeButton())

		await vi.waitFor(() => {
			expect(org.photoWrites).toHaveLength(1)
		})
		expect(org.photoWrites[0]).toMatchObject({
			contactId: "003-member",
			photoUrl: null,
		})
		// Once removed there is nothing left to remove.
		await vi.waitFor(() => {
			expect(removeButton()).toBeDisabled()
		})
	})
})
