import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CpdClaimInput,
	CpdSaveResult,
	MemberPortalEnvelope,
} from "@/api/cpd/types"

const CPD_CLAIM_PATH = "/services/apexrest/memberportal/cpdClaim"
const CPD_CLAIM_DELETE_PATH = "/services/apexrest/memberportal/cpdClaimDelete"
const CPD_ATTEST_PATH = "/services/apexrest/memberportal/cpdAttest"

/**
 * Every CPD write answers HTTP 200 with envelope `status: "Success"` even when
 * it refused the write — `SaveResult` carries no `statusCode` for the envelope
 * to lift, so the only honest signal is its own `status` field. Without this
 * check, "Claim not found" / "Candidate Requirement not found" / "The activity
 * could not be saved." all disappear and the UI reports success.
 */
function assertWriteSucceeded(
	result: CpdSaveResult,
	fallbackMessage: string,
	status: number,
): CpdSaveResult {
	if (result.status !== "Success") {
		throw new AppError({
			messages: [result.msg?.trim() || fallbackMessage],
			status,
		})
	}
	return result
}

async function postCpdWrite(
	path: string,
	body: unknown,
	messages: { unreachable: string; fallback: string },
): Promise<CpdSaveResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(path, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		body: JSON.stringify(body),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<CpdSaveResult>
	>(response, {
		unreachableMessage: messages.unreachable,
		fallbackErrorMessage: messages.fallback,
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: messages.fallback,
		missingDataMessage: "No response was returned.",
		status: result.status,
	})

	return assertWriteSucceeded(data, messages.fallback, result.status)
}

/**
 * Creates or updates a CPD activity (`cpdClaim`).
 *
 * Apex always attaches the claim to the member's own active CPE requirement —
 * the client cannot choose the cycle — and resolves `claimId` against the
 * signed-in member before writing, so a mismatched id is refused rather than
 * silently ignored.
 */
export async function saveCpdClaim(
	input: CpdClaimInput,
): Promise<CpdSaveResult> {
	if (!input.activityType?.trim()) {
		throw new AppError({
			messages: ["An activity type is required."],
			status: 400,
		})
	}
	if (!input.dateOfCompletionString?.trim()) {
		throw new AppError({
			messages: ["A date of completion is required."],
			status: 400,
		})
	}

	return postCpdWrite(CPD_CLAIM_PATH, input, {
		unreachable: "Unable to reach the CPD service.",
		fallback: "The activity could not be saved.",
	})
}

/** Deletes one of the member's own pending activities (`cpdClaimDelete`). */
export async function deleteCpdClaim(claimId: string): Promise<CpdSaveResult> {
	const key = claimId.trim()
	if (!key) {
		throw new AppError({ messages: ["A claim id is required."], status: 400 })
	}

	return postCpdWrite(
		CPD_CLAIM_DELETE_PATH,
		{ claimId: key },
		{
			unreachable: "Unable to reach the CPD service.",
			fallback: "The activity could not be removed.",
		},
	)
}

/** Marks the member's cycle attested (`cpdAttest`), unlocking certificates. */
export async function attestCpdCycle(
	attestationId: string,
): Promise<CpdSaveResult> {
	const key = attestationId.trim()
	if (!key) {
		throw new AppError({
			messages: ["An attestation id is required."],
			status: 400,
		})
	}

	return postCpdWrite(
		CPD_ATTEST_PATH,
		{ attestationId: key },
		{
			unreachable: "Unable to reach the CPD service.",
			fallback: "The attestation could not be saved.",
		},
	)
}
