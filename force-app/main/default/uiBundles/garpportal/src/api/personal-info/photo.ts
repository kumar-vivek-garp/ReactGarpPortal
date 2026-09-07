import { createDataSDK } from "@salesforce/platform-sdk"

import type { MemberPortalEnvelope } from "@/api/account/types"
import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { PhotoResult } from "@/api/personal-info/types"

const MEMBER_PHOTO_PATH = "/services/apexrest/memberportal/memberPhoto"
const MEMBER_PHOTO_REMOVE_PATH =
	"/services/apexrest/memberportal/memberPhotoRemove"

async function postPhoto(
	path: string,
	body: Record<string, string>,
	failure: string,
): Promise<PhotoResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(path, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify(body),
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<PhotoResult>>(
		response,
		{
			unreachableMessage: "Unable to reach the photo service.",
			fallbackErrorMessage: failure,
		},
	)

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: failure,
		missingDataMessage: "No response was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage?.trim() || failure],
			status: data.statusCode,
		})
	}

	return data
}

/**
 * Replaces the member's profile photo through Apex `GARP_Portal_PhotoService`,
 * which stores the bytes and points `Contact.Photo_URL__c` at them in one
 * call. `base64Body` is the bare payload — no `data:` prefix. Resolves the
 * new photo URL.
 */
export async function uploadProfilePhoto(
	base64Body: string,
	fileName: string,
): Promise<string> {
	if (!base64Body.trim()) {
		throw new AppError({ messages: ["Photo data is required."] })
	}

	const data = await postPhoto(
		MEMBER_PHOTO_PATH,
		{
			fileName: fileName.trim() || "profile-photo.jpg",
			fileText: base64Body,
		},
		"Your photo could not be saved.",
	)

	const photoUrl = data.photoUrl?.trim()
	if (!photoUrl) {
		throw new AppError({ messages: ["Photo upload did not return a photo URL."] })
	}
	return photoUrl
}

/** Deletes the stored photo and clears `Contact.Photo_URL__c`. */
export async function removeProfilePhoto(): Promise<void> {
	await postPhoto(MEMBER_PHOTO_REMOVE_PATH, {}, "Your photo could not be removed.")
}
