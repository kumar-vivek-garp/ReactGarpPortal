import { createDataSDK, gql } from "@salesforce/platform-sdk"

import { AppError } from "@/api/client"

type AttachmentCreateResult = {
	uiapi?: {
		AttachmentCreate?: {
			Record?: { Id?: string } | null
		} | null
	} | null
}

type ContactPhotoUpdateResult = {
	uiapi?: {
		ContactUpdate?: {
			success?: boolean | null
			Record?: {
				Photo_URL__c?: { value?: string | null } | null
			} | null
		} | null
	} | null
}

const ATTACHMENT_CREATE_MUTATION = gql`
	mutation UploadProfilePhotoAttachment(
		$parentId: IdOrRef!
		$name: String!
		$contentType: String!
		$body: Base64!
	) {
		uiapi(input: { allOrNone: true }) {
			AttachmentCreate(
				input: {
					Attachment: {
						ParentId: $parentId
						Name: $name
						ContentType: $contentType
						Body: $body
						IsPrivate: false
					}
				}
			) {
				Record {
					Id
				}
			}
		}
	}
`

const SET_PHOTO_URL_MUTATION = gql`
	mutation SetContactPhotoUrl($contactId: IdOrRef!, $photoUrl: String) {
		uiapi(input: { allOrNone: true }) {
			ContactUpdate(
				input: { Id: $contactId, Contact: { Photo_URL__c: $photoUrl } }
			) {
				success
				Record {
					Photo_URL__c @optional {
						value
					}
				}
			}
		}
	}
`

function photoUrlFromAttachmentId(attachmentId: string): string {
	return `/servlet/servlet.FileDownload?file=${attachmentId}`
}

function contentTypeForFileName(fileName: string): string {
	const lower = fileName.toLowerCase()
	if (lower.endsWith(".png")) return "image/png"
	if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg"
	return "application/octet-stream"
}

/**
 * Uploads a profile photo as an Attachment on the Contact, then sets `Photo_URL__c`
 * to the legacy FileDownload servlet path.
 */
export async function uploadProfilePhoto(
	contactId: string,
	base64Body: string,
	fileName: string,
): Promise<string> {
	const trimmedId = contactId.trim()
	if (!trimmedId) {
		throw new AppError({ messages: ["Contact Id is required."] })
	}
	if (!base64Body.trim()) {
		throw new AppError({ messages: ["Photo data is required."] })
	}

	const sdk = await createDataSDK()
	const createResult = await sdk.graphql?.mutate<
		AttachmentCreateResult,
		{ parentId: string; name: string; contentType: string; body: string }
	>({
		mutation: ATTACHMENT_CREATE_MUTATION,
		variables: {
			parentId: trimmedId,
			name: fileName.trim() || "profile-photo.jpg",
			contentType: contentTypeForFileName(fileName),
			body: base64Body,
		},
	})

	if (createResult?.errors?.length) {
		throw new AppError({
			messages: createResult.errors.map((error) => error.message),
		})
	}

	const attachmentId =
		createResult?.data?.uiapi?.AttachmentCreate?.Record?.Id?.trim()
	if (!attachmentId) {
		throw new AppError({ messages: ["Photo upload did not return an attachment Id."] })
	}

	const photoUrl = photoUrlFromAttachmentId(attachmentId)
	await setContactPhotoUrl(trimmedId, photoUrl)
	return photoUrl
}

/** Clears `Contact.Photo_URL__c`. */
export async function removeProfilePhoto(contactId: string): Promise<void> {
	await setContactPhotoUrl(contactId, null)
}

async function setContactPhotoUrl(
	contactId: string,
	photoUrl: string | null,
): Promise<void> {
	const trimmedId = contactId.trim()
	if (!trimmedId) {
		throw new AppError({ messages: ["Contact Id is required."] })
	}

	const sdk = await createDataSDK()
	const result = await sdk.graphql?.mutate<
		ContactPhotoUpdateResult,
		{ contactId: string; photoUrl: string | null }
	>({
		mutation: SET_PHOTO_URL_MUTATION,
		variables: { contactId: trimmedId, photoUrl },
	})

	if (result?.errors?.length) {
		throw new AppError({
			messages: result.errors.map((error) => error.message),
		})
	}
}
