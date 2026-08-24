import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	memberPortalRefusalPayload,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CvAttachmentResult,
	MemberPortalEnvelope,
} from "@/api/work-experience/types"

const CV_ATTACHMENTS_PATH = "/services/apexrest/memberportal/cvAttachments"
const CV_ATTACHMENT_PATH = "/services/apexrest/memberportal/cvAttachment"
const CV_ATTACHMENT_DELETE_PATH =
	"/services/apexrest/memberportal/cvAttachmentDelete"

/**
 * Runs one attachment action and reads its error text from the right place.
 *
 * `AttachmentResult` names its message field `message`, but the router only
 * lifts a field called `statusMessage` into the envelope. So on any attachment
 * failure the envelope's `errorMessage` is **null** and the only description of
 * what went wrong — "Work Experience not found", "A file is required", "Error
 * uploading file" — is inside `data.message`. Falling back to the envelope here
 * would replace every one of those with the same generic sentence, which is
 * what the backend team's own client does.
 *
 * The HTTP status is still correct (404 / 500 / 501), so the refusal payload is
 * recovered the same way as everywhere else.
 */
async function attachmentRequest(
	path: string,
	init: RequestInit,
	fallback: string,
): Promise<CvAttachmentResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(path, init)

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<CvAttachmentResult>
	>(response, {
		unreachableMessage: "Unable to reach the work experience service.",
		fallbackErrorMessage: fallback,
	})

	if (!result.ok) {
		const refusal = memberPortalRefusalPayload<CvAttachmentResult>(result)
		throw new AppError({
			messages: [refusal?.message?.trim() || fallback],
			status: result.status,
		})
	}

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: fallback,
		missingDataMessage: "No attachment data was returned.",
		status: result.status,
	})

	// Defends the 200-with-error shape; the same `message` rule applies.
	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.message?.trim() || fallback],
			status: data.statusCode,
		})
	}

	return {
		...data,
		attachments: Array.isArray(data.attachments) ? data.attachments : [],
	}
}

const jsonPost = (body: unknown): RequestInit => ({
	method: "POST",
	headers: { "Content-Type": "application/json", Accept: "application/json" },
	body: JSON.stringify(body),
})

/** Files on one of the member's own experiences (`cvAttachments`). */
export async function fetchCvAttachments(
	experienceId: string,
): Promise<CvAttachmentResult> {
	const key = experienceId.trim()
	if (!key) {
		throw new AppError({
			messages: ["An experience id is required."],
			status: 400,
		})
	}

	return attachmentRequest(
		`${CV_ATTACHMENTS_PATH}?experienceId=${encodeURIComponent(key)}`,
		{ method: "GET", headers: { Accept: "application/json" } },
		"Unable to load the files for this experience.",
	)
}

/**
 * Uploads one file (`cvAttachment`).
 *
 * `fileText` is RAW base64 — no `data:` prefix; Apex hands it straight to
 * `EncodingUtil.base64Decode`. Size is not checked server-side at all: the
 * platform caps an Attachment body at 5 MB and base64 inflates by about a
 * third, so an oversized file surfaces as an opaque 500. Callers must apply
 * `CV_MAX_UPLOAD_BYTES` before reading the file.
 *
 * `attachments[0].size` comes back null here — the service returns the record
 * it just inserted rather than re-querying it, and `BodyLength` is only
 * populated by a read. Use the list response for sizes.
 */
export async function uploadCvAttachment(
	experienceId: string,
	fileName: string,
	fileText: string,
): Promise<CvAttachmentResult> {
	const key = experienceId.trim()
	const name = fileName.trim()
	if (!key) {
		throw new AppError({
			messages: ["An experience id is required."],
			status: 400,
		})
	}
	if (!name || !fileText) {
		throw new AppError({ messages: ["A file is required."], status: 400 })
	}

	return attachmentRequest(
		CV_ATTACHMENT_PATH,
		jsonPost({ experienceId: key, fileName: name, fileText }),
		"This file could not be uploaded.",
	)
}

/** Removes one file the member owns (`cvAttachmentDelete`). */
export async function deleteCvAttachment(
	attachmentId: string,
): Promise<CvAttachmentResult> {
	const key = attachmentId.trim()
	if (!key) {
		throw new AppError({
			messages: ["An attachment id is required."],
			status: 400,
		})
	}

	return attachmentRequest(
		CV_ATTACHMENT_DELETE_PATH,
		jsonPost({ attachmentId: key }),
		"This file could not be removed.",
	)
}
