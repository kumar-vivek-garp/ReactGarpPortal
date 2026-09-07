import { http, HttpResponse } from "msw"

import type {
	AddressResult,
	AddressSubmission,
	PhotoResult,
} from "@/api/personal-info/types"

export const ADDRESSES_PATH = "/services/apexrest/memberportal/addresses"
export const MEMBER_PHOTO_PATH = "/services/apexrest/memberportal/memberPhoto"
export const MEMBER_PHOTO_REMOVE_PATH =
	"/services/apexrest/memberportal/memberPhotoRemove"

export type PhotoUpload = { fileName: string; fileText: string }

/**
 * What `GARP_Portal_API.respond` sends: the payload's own `statusCode` becomes
 * the HTTP status and, from 400 up, the envelope flips to Error with
 * `statusMessage` lifted into `errorMessage`.
 */
function respond<T extends { statusCode: number; statusMessage: string | null }>(
	payload: T,
) {
	const failed = payload.statusCode >= 400
	return HttpResponse.json(
		{
			status: failed ? "Error" : "Success",
			statusCode: payload.statusCode,
			errorMessage: failed ? payload.statusMessage : null,
			data: payload,
		},
		{ status: payload.statusCode },
	)
}

export type WriteSpy<TBody> = { hits: number; bodies: TBody[] }

/**
 * The Personal Information dialog's write surface: the address save and the
 * photo upload / remove actions, each with a spy on what was posted. The
 * responders return the payload the Apex service would; mirror `statusCode`
 * in the HTTP status the way `GARP_Portal_API.respond` does.
 */
export function personalInfoWriteHandlers({
	addressesRespond = () => ({
		statusMessage: "Success",
		statusCode: 200,
		appliedBillingToMailing: false,
	}),
	photoRespond = () => ({
		statusMessage: "Success",
		statusCode: 200,
		photoUrl: "/servlet/servlet.FileDownload?file=00PX0000000ATT",
	}),
	photoRemoveRespond = () => ({
		statusMessage: "Success",
		statusCode: 200,
		photoUrl: null,
	}),
}: {
	addressesRespond?: (body: AddressSubmission, hits: number) => AddressResult
	photoRespond?: (body: PhotoUpload, hits: number) => PhotoResult
	photoRemoveRespond?: (hits: number) => PhotoResult
} = {}) {
	const addressesSpy: WriteSpy<AddressSubmission> = { hits: 0, bodies: [] }
	const photoSpy: WriteSpy<PhotoUpload> = { hits: 0, bodies: [] }
	const photoRemoveSpy: WriteSpy<Record<string, never>> = { hits: 0, bodies: [] }

	const handlers = [
		http.post(ADDRESSES_PATH, async ({ request }) => {
			const body = (await request.json()) as AddressSubmission
			addressesSpy.hits += 1
			addressesSpy.bodies.push(body)
			return respond(addressesRespond(body, addressesSpy.hits))
		}),
		http.post(MEMBER_PHOTO_PATH, async ({ request }) => {
			const body = (await request.json()) as PhotoUpload
			photoSpy.hits += 1
			photoSpy.bodies.push(body)
			return respond(photoRespond(body, photoSpy.hits))
		}),
		http.post(MEMBER_PHOTO_REMOVE_PATH, () => {
			photoRemoveSpy.hits += 1
			photoRemoveSpy.bodies.push({})
			return respond(photoRemoveRespond(photoRemoveSpy.hits))
		}),
	]
	return { addressesSpy, photoSpy, photoRemoveSpy, handlers }
}
