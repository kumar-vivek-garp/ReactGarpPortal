import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	MemberPortalEnvelope,
	OstaIdInput,
	OstaResult,
	OstaView,
} from "@/api/osta/types"

const OSTA_PATH = "/services/apexrest/memberportal/osta"

/** The identity details on file (`GET osta`). */
export async function fetchOsta(): Promise<OstaView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(OSTA_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<OstaView>>(
		response,
		{
			unreachableMessage: "Unable to reach the identity service.",
			fallbackErrorMessage: "Unable to load your identity details.",
		},
	)

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Unable to load your identity details.",
		missingDataMessage: "No identity details were returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load your identity details."],
			status: data.statusCode,
		})
	}

	return data
}

/**
 * Saves the identity details (`POST osta`).
 *
 * Apex requires **all five** — type, location, number, expiry and a consent of
 * exactly `true` — and answers 501 "Missing required information" if any is
 * absent. They are checked here first so the member is told which one.
 *
 * `idNumber` must be the WHOLE number. Apex writes it to `OSTA_Full_ID__c` and
 * derives the displayed tail with `.right(5)`, so submitting the masked value
 * the read returns would truncate a real ID to five characters.
 *
 * The save also clears `OSTA_Collect_Info__c` and the server contact cache, so
 * anything reading the member's identity has to be refetched afterwards.
 */
export async function saveOsta(input: OstaIdInput): Promise<OstaResult> {
	const missing = (
		[
			["idType", "an ID type"],
			["idLocation", "the issuing country"],
			["idNumber", "your ID number"],
			["idExpireDate", "the expiry date"],
		] as const
	).find(([key]) => !input[key]?.trim())

	if (missing) {
		throw new AppError({
			messages: [`Please provide ${missing[1]}.`],
			status: 400,
		})
	}
	if (input.ostaConsent !== true) {
		throw new AppError({
			messages: ["Please confirm you consent to sharing these details."],
			status: 400,
		})
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(OSTA_PATH, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		body: JSON.stringify(input),
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<OstaResult>>(
		response,
		{
			unreachableMessage: "Unable to reach the identity service.",
			fallbackErrorMessage: "Your identity details could not be saved.",
		},
	)

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Your identity details could not be saved.",
		missingDataMessage: "No response was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [
				data.statusMessage?.trim() ||
					"Your identity details could not be saved.",
			],
			status: data.statusCode,
		})
	}

	return data
}
